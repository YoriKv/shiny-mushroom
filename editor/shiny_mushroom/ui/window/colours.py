"""The game's colours: the palette document, and every edit to it.

A palette edit is the one kind of edit here that is not about the level on
the canvas. Every palette in the game is one file
(:mod:`shiny_mushroom.palettes`), so a colour changed for one level is
changed for every level that reads the same run -- and the document
therefore belongs to the project rather than to the level, survives every
level switch and every trip to the world map, and carries an undo stack of
its own.

The picture follows without the emulator being asked again. The renderers
colour everything out of the CGRAM the snapshot was captured with, so an
edit reaches the screen by rewriting the entries that source it
(:func:`shiny_mushroom.palette_map.recolored`) -- a redraw rather than a
level load. Which entries those are is the loader modelled and then
**checked against the capture**, so a colour the model cannot account for
is shown as not editable here rather than edited into the wrong place.

Where each colour on screen came from -- the reading the paragraph above calls
checking the model against the capture -- is answered in
:mod:`shiny_mushroom.ui.main_window` itself, beside the capture it is made
from. What is here is the document, the edits, and what the picture and the
panel do about one.
"""

from __future__ import annotations

from shiny_mushroom import cart_patches, level_palettes, palette_map, palettes
from shiny_mushroom import features as switches
from shiny_mushroom.build import features_wanted
from shiny_mushroom.edit import History
from shiny_mushroom.hexnum import hexnum
from shiny_mushroom.level_palettes import LevelPalettes, PaletteDocument
from shiny_mushroom.palettes import Palette, PaletteError
from shiny_mushroom.project import ProjectError
from shiny_mushroom.ui.palette_dock import LEVEL_TITLE, MAP_TITLE
from shiny_mushroom.ui.palette_grid import Swatch
from shiny_mushroom.ui.window.modes import EditorMode
from smw_tools.features import LEVEL_CUSTOM_PALETTES, FeatureError
from smw_tools.rom_sizes import ROM_SIZES

__all__ = ["NOT_FROM_THE_FILE", "Colours"]

# Said of a colour the palette file does not back: colour 0 of every row,
# which the loader forces black; colour 1, which is a literal in the game's
# code; a colour an animation rewrites every frame; and every colour of a
# screen whose palette load this editor does not model.
NOT_FROM_THE_FILE = "not from the palette file"


class Colours:
    """:class:`~shiny_mushroom.ui.main_window.MainWindow`'s palette half."""

    @property
    def _palette_document(self) -> PaletteDocument:
        """The panel's whole document: the shared file's edits beside the
        custom level palettes, as one value the history can hold."""
        return PaletteDocument(self._palette, self._level_palettes)

    @property
    def _palette_unsaved(self) -> bool:
        """Whether the colours differ from what the project has written."""
        return self._project is not None and (
            self._palette_document != self._palette_history.base
        )

    def _editing_palettes(self) -> bool:
        """Whether the colours are what the Edit rows and Ctrl+S mean.

        The surface last worked in, tracked rather than read off the keyboard
        focus. Focus would be the natural question -- and in practice this
        answers it, because picking a colour is the gesture that focuses the
        panel and a gesture on the canvas is what takes the focus away. It is
        tracked because a *state* can be exercised: no windowing system gives a
        headless run a focused widget, so a rule written against
        ``focusWidget`` would be a rule no test could reach.
        """
        return self._palette_active

    def _entered_palettes(self, offset: object) -> None:
        """A colour was picked: the palettes are the document being worked in."""
        self._palette_active = offset is not None
        if self._palette_active:
            self._graphics_active = False
        self.sync_edit_actions()

    def _palette_shown(self, on: bool) -> None:
        if not on:
            self._left_palettes()

    def _left_palettes(self, *_: object) -> None:
        """A gesture on the canvas: the level or the map is again -- and not
        the graphics files either."""
        if not (self._palette_active or self._graphics_active):
            return
        self._palette_active = False
        self._graphics_active = False
        self.sync_edit_actions()

    def _read_palette(self) -> None:
        """Take the open project's colours as the document, undo stack and all.

        The base is the **disassembly's** file, so putting a colour back means
        the game's own colour and not whatever was saved last; the project's
        saved file is read as the changes to it. A project without one opens as
        no changes, which is the same document.
        """
        self._palette_base = None
        held = PaletteDocument()
        if self._project is not None:
            try:
                self._palette_base = self._project.stock_palette()
                held = PaletteDocument(
                    Palette.between(self._palette_base, self._project.palette()),
                    LevelPalettes.of(self._project.level_palettes()),
                )
            except (ProjectError, PaletteError, OSError) as error:
                self._palette_base = None
                self._status_message(f"The palettes could not be read: {error}", 8000)
        self._palette = held.shared
        self._level_palettes = held.levels
        self._palette_history = History(held)
        self._palette_pending = False
        self._palette_timer.stop()
        self._remeasure_palette()
        self._compute_provenance()
        self._show_palette()

    def _read_rom_palette(self) -> None:
        """Read the palette document out of the cartridge on the canvas.

        Three tables, gathered from wherever this target put each of them
        (:func:`~shiny_mushroom.cart_patches.palette_document`), in the order
        the document lays them out.

        What the capture's colours actually came from, which is not always what
        the project has saved: a colour saved but not yet built is in the
        overlay and not in this image. Measuring the document against **this**
        is what makes the preview right in the gap between the two.
        """
        self._rom_palette = cart_patches.palette_document(self._rom, self._addresses)

    def _palette_edits(self, under: bytes | None = None) -> dict[int, int]:
        """What the document changes about the palette file ``under``.

        The cartridge's own by default. A recolour writes these onto a capture
        taken under that same file, so the baseline has to be the one the
        capture was made with -- otherwise an edit already baked into the
        capture is written over it a second time, or one that is not there is
        left off.
        """
        blob = self._rom_palette if under is None else under
        if self._palette_base is None or blob is None:
            return {}
        try:
            return palettes.differences(blob, self._palette.image(self._palette_base))
        except PaletteError:
            return {}

    def _remeasure_palette(self) -> None:
        """Re-measure the document against both baselines.

        The level's own palette joins the capture-side measure under its
        virtual offsets: what the blob changes about the scene actually
        captured, whatever that capture was booted with -- a capture already
        wearing the blob diffs to nothing, one booted before any build diffs
        everywhere the custom palette departs from stock. The world map's
        measure carries no level part, because no submap wears one.
        """
        self._palette_over_rom = self._palette_edits()
        self._palette_over_capture = (
            self._palette_edits(self._capture_palette) | self._level_palette_diffs()
        )

    def _level_palette_diffs(self) -> dict[int, int]:
        """What the captured level's own palette changes about its capture,
        keyed by virtual offset -- empty while it wears the game's colours."""
        if self._captured_level is None or self._captured_cgram is None:
            return {}
        blob = self._level_palettes.get(self._captured_level)
        if blob is None:
            return {}
        return level_palettes.scene_diffs(
            self._captured_level,
            blob,
            self._captured_cgram,
            max(self._captured_backdrop or 0, 0),
        )

    # -- changing a colour ----------------------------------------------------

    def _with_color(
        self, held: PaletteDocument, offset: int, value: int
    ) -> PaletteDocument:
        """``held`` with the colour at ``offset`` set -- whichever half of the
        document the offset addresses."""
        owner = level_palettes.holder(offset)
        if owner is None:
            return held.with_shared(held.shared.with_color(offset, value))
        level, byte = owner
        try:
            return held.with_levels(held.levels.with_color(level, byte, value))
        except PaletteError:
            # A pick raced the untick: the swatch named a palette the document
            # no longer holds. Nothing to write it into.
            return held

    def _preview_color(self, offset: int, value: int) -> None:
        """A colour being dragged towards in the picker: show it, record
        nothing, and repaint no faster than :data:`PALETTE_PREVIEW_MS`."""
        document = self._palette_document
        held = self._with_color(document, offset, value)
        if held is document:
            return
        self._palette = held.shared
        self._level_palettes = held.levels
        self._palette_pending = True
        if not self._palette_timer.isActive():
            self._flush_palette_preview()

    def _flush_palette_preview(self) -> None:
        if not self._palette_pending:
            return
        self._palette_pending = False
        self._palette_changed(previewing=True)
        self._palette_timer.start()

    def _commit_color(self, offset: int, value: int) -> None:
        """The picker was accepted: one undo step, whatever the drag did.

        Built from the **last committed** palette rather than from the preview,
        so a drag that wandered and came back to the colour it started on
        records nothing at all.
        """
        held = self._palette_history.level
        # A colour picked back to the game's own is not an edit but the removal
        # of one -- the same rule the overlay keeps, where a palette file equal
        # to the disassembly's is taken out rather than written as a copy of
        # it. Only the shared file has a "game's own" to fall back to: a level
        # palette is custom throughout, so every value there is simply stored.
        if (
            level_palettes.holder(offset) is None
            and self._palette_base is not None
            and value == palettes.color(self._palette_base, offset)
        ):
            self._commit_palette(held.with_shared(held.shared.without([offset])))
        else:
            self._commit_palette(self._with_color(held, offset, value))

    def _cancel_color(self, offset: int) -> None:
        """The picker was cancelled: put the colour back, recording nothing."""
        self._show_palette_document(self._palette_history.level)

    def _reset_color(self, offset: int) -> None:
        """Put one colour back -- one undo step.

        For the shared file that means the game's own colour. A level palette
        has no game's own -- the blob is custom throughout -- so there the
        colour goes back to what the **project saved**, and a palette the
        project has never saved has nothing to put back and says so.
        """
        held = self._palette_history.level
        owner = level_palettes.holder(offset)
        if owner is None:
            self._commit_palette(held.with_shared(held.shared.without([offset])))
            return
        level, byte = owner
        saved = self._palette_history.base.levels.get(level)
        if saved is None or held.levels.get(level) is None:
            self._status_message(
                "This level's palette has not been saved yet, so there is no "
                "saved colour to put back.",
                6000,
            )
            return
        self._commit_palette(
            self._with_color(held, offset, palettes.unpack(saved, byte, 0))
        )

    def _reset_colors(self) -> None:
        """Put every shared colour back -- one undo step.

        The shared file only: the level palettes are whole custom blobs with
        no stock to return to, and their affordance is the tick. Wiping them
        under a button about the file's colours would throw work away that
        the button never named.
        """
        held = self._palette_history.level
        self._commit_palette(held.with_shared(held.shared.cleared()))

    def _walk_palette(self, back: bool) -> None:
        """One step along the palette's own undo stack."""
        if not (self._palette_history.undo() if back else self._palette_history.redo()):
            return
        self._show_palette_document(self._palette_history.level)

    def _commit_palette(self, held: PaletteDocument) -> None:
        """Make ``held`` the document, as one undo step, and show it.

        A palette operation with nothing to do hands back the document it was
        given, and `History.commit` recognises that by identity -- so a drag
        that wandered and came back records no step, and the redraw below is
        the only thing that happens.
        """
        self._palette_history.commit(held)
        self._show_palette_document(held)

    def _show_palette_document(self, held: PaletteDocument) -> None:
        """Make ``held`` the document and follow it, recording nothing."""
        self._palette = held.shared
        self._level_palettes = held.levels
        self._palette_changed()

    def _want_feature(self, feature_id: str) -> bool:
        """Offer the feature the flow at hand is about to rely on, and say
        whether the way is clear.

        A no-op when the project already wants it. Otherwise the person is
        asked first: the flow needs the feature, but throwing the switch is a
        project setting that changes what the next build makes -- and can grow
        the cartridge -- which is more than the gesture that got here said it
        would do. A yes runs the same switch the Features dialog throws --
        limits checked, the cartridge grown to the size the feature needs --
        with the refusal said here, at the flow that needed it, rather than in
        a dialog nobody had open.

        And it ends where :meth:`edit_features` ends: the cartridge rebuilt
        and reopened, so the switch is *in* it rather than owed -- a switched
        feature is a change to the code, which nothing can preview in place.
        Unsaved work the person keeps, or a failed build, leaves the build
        owed like any other, said so on the status line. The reopen drops the
        canvas level until the reload lands, so a caller that still needs the
        outgoing scene reads it before asking.
        """
        project = self._project
        if project is None:
            return False
        if feature_id in features_wanted(project):
            return True
        found = switches.feature(feature_id)
        label = found.name
        grows = (
            f" The cartridge grows to {found.needs.label}."
            if found.needs is not None
            and ROM_SIZES[project.rom_size_id].size < found.needs.size
            else ""
        )
        if not self._confirm(
            f"This needs the {label} feature. Turn it on?",
            f"{found.summary}. Turning it on rebuilds the cartridge.{grows}",
        ):
            return False
        try:
            done = switches.enable(project, feature_id)
        except switches.FeatureBlocked as error:
            self._alert(
                f"{label} cannot be turned on.",
                detail=" ".join(
                    f"{limit.reason} {limit.remedy}".strip() for limit in error.limits
                ),
            )
            return False
        except (FeatureError, ProjectError, OSError) as error:
            self._alert(f"{label} could not be turned on.", detail=str(error))
            return False
        self._project = done.project
        self.sync_project_menu()
        said = "; ".join(done.notes) if done.notes else ""
        turned = f"{label} turned on{': ' + said if said else ''}"
        if self._may_discard() and self.use_project(done.project):
            self._status_message(f"{turned}.", 8000)
        else:
            self._status_message(
                f"{turned} -- in the cartridge at the next build.", 8000
            )
        return True

    def _custom_palette_toggled(self, on: bool) -> None:
        """The per-level tick was thrown: dress the level, or undress it.

        Ticking copies the scene on screen -- recoloured edits and all --
        into a palette of the level's own, which is the promise the panel
        makes: what you see is what the level now wears, and every edit from
        here touches only it. Unticking takes the blob out again; both are
        one undo step on the panel's own stack, so a slip is Ctrl+Z.

        The blob reaches the cartridge through the level-custom-palettes
        feature, so the first tick offers to turn it on -- the same migration
        the Features dialog runs, cartridge growth, rebuild and all, so the
        built image carries the feature's labels and a test run can patch the
        blob straight in -- and a no, like a refusal, puts the tick back to
        what the document says rather than leaving it promising something the
        save would refuse.
        """
        if (
            self._project is None
            or self._snapshot is None
            or self._mode is EditorMode.WORLD
        ):
            self._show_palette()
            return
        level = self._snapshot.level
        held = self._palette_history.level
        if not on:
            self._palette_active = True
            self._commit_palette(held.with_levels(held.levels.without(level)))
            return
        if held.levels.get(level) is not None:
            self._show_palette()
            return
        # The level bank's room with the level streams packed into it, or
        # the format's ceiling for a cartridge with no project behind it.
        capacity = (
            self._project.level_palette_capacity()
            if self._project is not None
            else level_palettes.CAPACITY
        )
        if len(held.levels.levels) >= capacity:
            self._show_palette()
            self._alert(
                f"All {capacity} custom level palette slots in the level "
                f"bank are worn.",
                detail="Untick a level that no longer needs its own colours, "
                "or take level data back out of the bank.",
            )
            return
        # The scene is copied out before the feature is asked for: a yes
        # rebuilds and reopens the cartridge, which drops the snapshot until
        # the level reloads, and what the tick promises is the scene that was
        # on screen when it was thrown.
        blob = level_palettes.from_scene(
            self._snapshot.cgram, self._snapshot.back_area_color
        )
        if not self._want_feature(LEVEL_CUSTOM_PALETTES.id):
            self._show_palette()
            return
        self._palette_active = True
        # Re-read rather than the document from before the ask: the reopen a
        # yes runs starts a fresh palette document, and committing the old one
        # onto it would resurrect whatever the reopen just discarded.
        held = self._palette_history.level
        self._commit_palette(held.with_levels(held.levels.with_palette(level, blob)))

    def save_palettes(self) -> bool:
        """Write the game's colours into the project, reporting success."""
        if not self._have_somewhere_to_save():
            return False
        if self._palette_base is None:
            return False
        try:
            self._project.save_palette(self._palette.image(self._palette_base))
            # The fragments the build assembles ride the same save -- see
            # Project.save_level_palettes.
            self._project.save_level_palettes(self._level_palettes.as_mapping)
        except (ProjectError, PaletteError, OSError) as error:
            self._alert("The palettes could not be saved.", detail=str(error))
            return False
        self._palette_history.saved()
        self._status_message("Colours saved", 4000)
        self.sync_save_rows()
        self._update_title()
        return True

    def revert_palettes(self) -> None:
        """Take the project's colours back out of the overlay."""
        if self._project is None:
            return
        try:
            self._project.revert_palette()
        except (ProjectError, OSError) as error:
            self._alert("The palettes could not be reverted.", detail=str(error))
            return
        self._read_palette()
        self._palette_changed()
        # `_palette_changed` syncs the Edit rows; Save and Revert are named
        # and armed on their own -- a row left stale here is a live shortcut
        # for something already done.
        self.sync_save_rows()
        self._status_message("Colours put back", 4000)

    def _discard_palettes(self) -> None:
        """Take the colours back to what the project last saved.

        The in-memory half of :meth:`revert_palettes`: nothing in the project
        moves, the held document goes back to the history's base, and the
        history goes with it -- what was discarded is not waiting on Ctrl+Z.
        """
        held = self._palette_history.base
        self._palette_history = History(held)
        self._show_palette_document(held)
        # `_palette_changed` syncs the Edit rows; Save and Revert are named
        # and armed on their own, exactly as in :meth:`revert_palettes`.
        self.sync_save_rows()

    # -- keeping the picture and the panel in step ----------------------------

    def _palette_changed(self, previewing: bool = False) -> None:
        """The document moved: recolour what is on screen, and say so.

        ``previewing`` is a frame of a picker drag rather than a finished pick.
        **The picture follows either way; the offers wait for the release.**
        Each of the three modes draws a library of small pictures beside its
        canvas -- the level's background tiles, the map's tiles and sprites
        and 8x8 sheet, the Map16 sheet's 1024 chars -- and every one of them
        costs more than the picture does while nobody is looking at it. They
        are all held back under the same flag, and every one of them catches
        up on the finished pick.
        """
        # Provenance first: a step that ticked a level into its own palette,
        # or out of one, changes where every colour on screen comes from.
        self._compute_provenance()
        self._remeasure_palette()
        if self._snapshot is not None:
            recoloured = self._recoloured(self._snapshot)
            if recoloured is not self._snapshot:
                self._snapshot = recoloured
                self._capture_changed(offers=not previewing)
        if self._world.ready and self._world.snapshot is not None:
            self._world.recolour(
                self._recoloured_submaps(self._world.snapshot), offers=not previewing
            )
        if self._mode is EditorMode.MAP16 and self._map16.ready:
            # The sheet is drawn from the level's capture, which the block
            # above just recoloured: the mode re-reads it through the same
            # per-tileset door it always draws through. Held back to the
            # sheet alone while a picker drag previews, like the map's
            # offers: the 1024-char picker is the expensive half.
            self._map16.recolour(offers=not previewing)
        self._show_palette()
        self.sync_edit_actions()
        self._update_title()

    def _show_palette(self) -> None:
        """Offer the panel the colours on screen and the colours in the file."""
        world = self._world_colours_on_canvas()
        swatches, backdrop = self._scene_swatches()
        self._world_palette_shown = self._world.palette_index
        # The first tab is named for what it is showing, since it shows a
        # level's colours over a level and a world map's over a map.
        self.palette_dock.set_scene_title(MAP_TITLE if world else LEVEL_TITLE)
        if self._graphics_files is not None:
            # The colours of whatever is **on the canvas**, not of the last
            # level: over the world map the sheet should be drawn in the
            # framed submap's, which is the same rule the panel above follows.
            self._graphics_files.show_colours(
                self._canvas_cgram(), self._held_palette_blob()
            )
        self.palette_dock.set_scene(swatches, backdrop)
        self.palette_dock.set_sets(self._set_swatches())
        self.palette_dock.set_unsaved(self._palette_unsaved)
        self.palette_dock.set_custom(
            self._level_palettes.get(self._snapshot.level) is not None
            if self._mode is EditorMode.LEVEL
            and self._snapshot is not None
            and self._project is not None
            else None
        )
        # The world map's tile palette places under one of the eight background
        # rows, so the strip under its control is that row's sixteen colours --
        # the same swatches, sliced.
        rows = palette_map.ROWS // 2
        self.tile_palette.set_palette_rows(
            [
                swatches[n * palette_map.ROW : (n + 1) * palette_map.ROW]
                for n in range(rows)
            ]
            if world and len(swatches) >= rows * palette_map.ROW
            else []
        )
        # The Map16 dock's strip shows the arming palette row's colours as
        # the level draws them: the first eight CGRAM rows, one per row a
        # layer 2 word can name.
        self.map16_panel.set_palette_rows(
            tuple(
                tuple(swatches[n * palette_map.ROW : (n + 1) * palette_map.ROW])
                for n in range(rows)
            )
            if self._mode is EditorMode.MAP16
            and len(swatches) >= rows * palette_map.ROW
            else ()
        )

    def _world_colours_on_canvas(self) -> bool:
        """Whether the picture on the canvas is drawn in the world map's
        colours: the map itself, or one of its stamp sheets in the Map16
        environment."""
        return self._mode is EditorMode.WORLD or (
            self._mode is EditorMode.MAP16 and self._map16.on_stamps
        )

    def _canvas_cgram(self) -> bytes | None:
        """The CGRAM the picture on the canvas is drawn from, or ``None``
        where nothing is on it.

        The world map's framed submap where the map holds the canvas, and the
        level's otherwise -- the Map16 sheet included, since it is drawn in
        the open level's own colours.
        """
        if self._world_colours_on_canvas():
            snapshot = self._world.snapshot
            if snapshot is None:
                return None
            cgrams = self._world.palette_cgrams
            index = min(max(self._world.palette_index, 0), len(cgrams) - 1)
            return cgrams[index] if cgrams else snapshot.cgram
        return self._snapshot.cgram if self._snapshot is not None else None

    def _held_palette_blob(self) -> bytes | None:
        """The palette file as the editor **holds** it, or ``None`` where
        there is no document to image. What every other view of the colours
        reads, so a window that reads the saved file instead would be the
        one place an unsaved edit does not show."""
        if self._palette_base is None:
            return None
        try:
            return self._palette.image(self._palette_base)
        except PaletteError:
            return None

    def _scene_swatches(self):  # noqa: ANN202 - swatches and a backdrop
        """CGRAM as the console holds it for what is on the canvas, with the
        backdrop beside it."""
        if self._world_colours_on_canvas():
            return self._world_swatches()
        if self._snapshot is None or self._captured_cgram is None:
            return [], None
        backdrop = None
        if self._backdrop_offset is not None:
            backdrop = Swatch(
                self._snapshot.back_area_color,
                self._backdrop_offset,
                self._describe(self._backdrop_offset, "Back area colour"),
            )
        elif self._snapshot is not None:
            backdrop = Swatch(self._snapshot.back_area_color, None, NOT_FROM_THE_FILE)
        return self._cgram_swatches(self._snapshot.cgram, self._provenance), backdrop

    def _world_swatches(self):  # noqa: ANN202 - swatches and a backdrop
        """The submap the world bar is showing, under its own palette."""
        cgrams = self._world.palette_cgrams
        index = self._world.palette_index
        if not cgrams or not 0 <= index < len(cgrams):
            return [], None
        found = self._world_provenance
        prov = found[index] if index < len(found) else None
        return self._cgram_swatches(cgrams[index], prov), None

    def _cgram_swatches(self, cgram: bytes, provenance) -> list[Swatch]:  # noqa: ANN001
        """One swatch per CGRAM colour, saying where it came from.

        A colour with no offset is one the palette file does not back: the
        forced black of colour 0, the two literals the loader writes into
        colour 1 of every row, a colour an animation rewrites every frame, or a
        screen whose palette load this editor does not model.
        """
        out: list[Swatch] = []
        for index in range(palette_map.CGRAM_COLORS):
            row, column = divmod(index, palette_map.ROW)
            # Black past the end of a short capture -- a synthetic snapshot --
            # which is a swatch to draw rather than an exception out of a paint.
            value = max(palette_map.cgram_color(cgram, index), 0)
            where = f"Row {row:X}, colour {column:X}"
            offset = (
                provenance[index]
                if provenance is not None and provenance[index] != palette_map.UNMAPPED
                else None
            )
            if offset is None:
                out.append(Swatch(value, None, f"{where} -- {NOT_FROM_THE_FILE}"))
            else:
                out.append(Swatch(value, offset, self._describe(offset, where)))
        return out

    def _set_swatches(self):  # noqa: ANN202 - titled strips of swatches
        """The palette file's named runs, as the catalog names them."""
        regions = palettes.catalog()
        if not regions or self._palette_base is None:
            return []
        try:
            blob = self._palette.image(self._palette_base)
        except PaletteError:
            return []
        return [
            (
                region.title,
                [
                    Swatch(
                        palettes.color(blob, offset),
                        offset,
                        f"{region.title}, colour {n} -- {hexnum(offset, 4)}{said}",
                    )
                    for n, offset in enumerate(region.offsets())
                ],
            )
            for region, said in (
                # The catalog knows things about a run that its colours cannot
                # show -- that these eight are the `?`-block pulse, that a
                # colour changed in the cleared area sets may not survive a
                # round trip through Lunar Magic. The swatch is where somebody
                # is already looking when they want to know.
                (region, f" -- {region.note}" if region.note else "")
                for region in regions
            )
        ]

    def _describe(self, offset: int, where: str) -> str:
        """One colour, said in full: where it is on screen and what run of the
        file it comes out of."""
        owner = level_palettes.holder(offset)
        if owner is not None:
            level, _ = owner
            return f"{where} -- level {hexnum(level, 3)}'s own palette"
        region = palettes.region_at(palettes.catalog(), offset)
        if region is None:
            return f"{where} -- {hexnum(offset, 4)}"
        said = f" -- {region.note}" if region.note else ""
        return f"{where} -- {hexnum(offset, 4)} -- {region.title}{said}"

    def _header_colours(self, key: str, setting: int) -> tuple[int, ...]:
        """What a header field's palette setting looks like.

        Handed to the header dialog so a set can be picked by eye rather than
        by number -- "which of eight backgrounds" is a decision about what the
        level looks like, and finding out afterwards costs a level load. As the
        **document** has them, so a colour changed and not yet saved shows here
        too.
        """
        if self._palette_base is None:
            return ()
        try:
            blob = self._palette.image(self._palette_base)
            if key == "back_area_color":
                start, count = palette_map.back_area_offset(setting), 1
            else:
                start, count = palette_map.header_set(key, setting)
        except PaletteError:
            return ()
        return palettes.colors(blob, start, count)

    def show_palette_offset(self, offset: int) -> None:
        """Raise the palette panel on one colour of the file -- what a swatch
        strip elsewhere in the window opens."""
        self.palette_dock.setVisible(True)
        self.palette_dock.raise_()
        self.palette_dock.show_offset(offset)
