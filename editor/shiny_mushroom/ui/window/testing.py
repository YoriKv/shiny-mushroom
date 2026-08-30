"""Testing it: the test runs, what they carry, and the window they use.

Test > Level plays what is on the canvas and Test > World Map walks the map,
both in the one play window (:mod:`shiny_mushroom.ui.play_window`) -- a second
emulator in a second process, so the picture on the canvas stays where it is.

Two rows are the odd ones out and are here for the name they share. File > Test
ROM builds the project's cartridge and hands the file to whatever emulator the
person has set (:mod:`shiny_mushroom.external_emulator`); Test Level Externally
sends a Lua warp with it, so a Mesen starts where the canvas is
(:mod:`shiny_mushroom.mesen_lua`). Neither patches anything, because the editor
did not start that program: both carry what has been *saved*.

**The emulator is booted before anybody asks for a run.** It is started when a
cartridge's first level lands on the canvas
(:meth:`Testing.ready_play_session`) and lives here rather than in the window,
so pressing Test Level asks a machine already at the title screen for a level
-- two tenths of a second -- instead of starting a process and booting a cart
for three seconds behind a black screen. Closing the window leaves it standing;
what ends it is the cartridge changing, which is :meth:`Testing._close_play`
and the three doors that call it.

**This is the seam an in-memory edit crosses.** Nothing the editor changes is
written to a file for a test run; the run gets it by patching the emulator's
own copy of the cartridge -- see :meth:`Testing.test_patches` for the kinds of
edit that ride, and what is said when one of them cannot.

Not a test module: pytest collects ``test_*.py`` and ``*_test.py`` alone, and
``testpaths`` names ``editor/tests`` rather than the package.
"""

from __future__ import annotations

from collections.abc import Mapping, Sequence
from pathlib import Path

from shiny_mushroom import cart_patches
from shiny_mushroom.addresses import LAYOUT_LAYER1_VERTICAL
from shiny_mushroom.build import rom_path
from shiny_mushroom.edit import Level
from shiny_mushroom.external_emulator import LaunchError, is_mesen, launch
from shiny_mushroom.hexnum import hexnum
from shiny_mushroom.mesen_lua import SCRIPT_NAME, level_script, overworld_script
from shiny_mushroom.overworld import (
    DEFAULT_SPAWN,
    WorldSpawn,
    cell_at,
    save_tables,
    spawn_for_cell,
)
from shiny_mushroom.project import scanning_once
from shiny_mushroom.rom_patches import entrance_patch, initial_level_flags
from shiny_mushroom.ui.controls_dialog import ControlsDialog
from shiny_mushroom.ui.play import PlayController
from shiny_mushroom.ui.play_window import OverworldRun, PlayWindow
from shiny_mushroom.ui.project_dialog import BuildDialog
from shiny_mushroom.ui.settings_dialog import external_emulator
from shiny_mushroom.ui.window.modes import EditorMode
from shiny_mushroom.ui.window.parts import DISASSEMBLY, LEVEL_PARTS

__all__ = ["Testing"]


class Testing:
    """:class:`~shiny_mushroom.ui.main_window.MainWindow`'s test-run half."""

    def test_level(self) -> None:
        """Play what is on the canvas, edits and all, in its own window.

        A second emulator in a second process, so the picture on the canvas
        stays where it is and a crash while testing costs the test rather than
        the session, in the one window :meth:`_show_play` keeps.

        The action follows the mode -- over the world map it is "Test World
        Map" and runs :meth:`test_world_map` instead, so one shortcut tests
        whatever is being edited.

        **A run that would not be the level on the canvas says so first.** A
        stream with nowhere to go stops the run the way it stops a save
        (:meth:`_alert`); anything else the image could not be made to carry
        is said and then run, since the rest of the level still is the
        canvas's -- :meth:`_warn_unpatched`.
        """
        if self._mode is EditorMode.WORLD:
            self.test_world_map()
            return
        if self._snapshot is None or self._path is None:
            return
        try:
            patches = self.test_patches()
        except ValueError as error:
            self._alert(
                f"Level {hexnum(self._snapshot.level, 3)} could not be built into a "
                f"test run, so none was started.",
                detail=f"{error}. Only a build can place a stream this long; "
                f"the run would have played the cartridge's own level.",
            )
            return
        self._warn_unpatched()
        self._show_play(self._snapshot.level, patches)

    def edit_controls(self) -> None:
        """What drives the test window's pad, and the offer to import a set.

        A preference of the person's rather than the project's, so it needs no
        cartridge and asks about none. A run that is already up is told to take
        the new bindings rather than being left on the ones it opened with:
        somebody who has just imported their controller wants to try it in the
        window they imported it for.
        """
        if ControlsDialog(self).exec() and self._play is not None:
            self._play.reload_controls()

    def test_world_map(self) -> None:
        """Walk the world map, edits, marked completions and spawn included.

        The same window and worker a level test uses, asked for the other kind
        of run: the game is booted straight onto the map with a fabricated
        save whose tables :func:`~shiny_mushroom.overworld.save_tables`
        derives from the marks, standing where the middle-click marker says.

        The run carries the level document too, so it is refused and warned
        about on exactly the terms :meth:`test_level` gives.
        """
        if self._path is None:
            return
        try:
            run = self._overworld_run()
        except ValueError as error:
            self._alert(
                "The world map could not be built into a test run, so none "
                "was started.",
                detail=f"{error}. The run carries the canvas level as well as "
                f"the map, and only a build can place a stream this long.",
            )
            return
        if run is None:
            self.statusBar().showMessage("The world map is still loading.", 4000)
            return
        self._warn_unpatched()
        self._show_play(None, None, overworld=run)

    def test_rom(self) -> None:
        """Build the project's cartridge and open it, at its title screen.

        File's row, because it tests no document in particular: it is the
        cartridge, run. What lands in the emulator is the file
        :meth:`export_rom` would copy -- the ordinary build, skipped when
        nothing has moved -- so there is nothing here that could disagree with
        what the project produces.

        The run is of what has been *saved*: a build reads the project's
        overlay off disk, so the unsaved-work question an export asks is asked
        here, on the same terms.
        """
        self._run_externally(warp=False)

    def test_level_external(self) -> None:
        """Build the cartridge and open it *where the canvas is*.

        :meth:`test_rom`'s run with the one thing an emulator the editor
        merely launched cannot normally be asked for: a starting point. Mesen
        takes a Lua script on its command line and runs it against the machine,
        so the same warp the editor's own test window drives from Python is
        written out as a script and handed over with the cartridge --
        :mod:`shiny_mushroom.mesen_lua`. The row follows the mode the way Test
        Level does: the level on the canvas, or the world map.

        **Dead unless the emulator on file is a Mesen**, because the warp is
        the whole of what this adds to the row above it -- see
        :meth:`~shiny_mushroom.ui.main_window.MainWindow._sync_rom_size_menu`,
        which greys it. Called anyway -- a shortcut is not the only way in --
        it says which of the two is missing.

        A warp that cannot be *written* is a different matter, and not a run
        that does not happen: the cartridge is still the project's and it still
        opens. What is lost is where it starts, which the status line says.
        """
        self._run_externally(warp=True)

    def _run_externally(self, *, warp: bool) -> None:
        """Both external runs: build, hand the cartridge over, say what happened.

        One method because they differ in one thing -- whether a warp script
        goes with the cartridge -- and agree on everything that can refuse
        them: a project to build, an emulator to open it in, work that would
        not be in the build, and an assembly that failed.
        """
        project = self._project
        if project is None or not project.buildable:
            self._alert(
                "There is no project to test.",
                detail="An external test run opens a project's built "
                "cartridge; File > New Project makes one.",
            )
            return
        emulator = external_emulator()
        if emulator is None:
            self._alert(
                "No external emulator is set.",
                detail="File > Settings names the emulator these rows open the "
                "built cartridge in.",
            )
            return
        if warp and not is_mesen(emulator):
            self._alert(
                f"{emulator.name} cannot be told where to start.",
                detail="Only Mesen runs a script the editor writes for it, "
                "which is what a warp is. File > Test ROM opens the same "
                "cartridge at its title screen.",
            )
            return
        if not self._may_export():
            return
        if BuildDialog.run(project, self) is None:
            # Nothing to add: the dialog is still up with asar's complaint on
            # it, which is the only thing that says why there is no cartridge.
            return
        cartridge = rom_path(project)
        script, where = (
            self._warp_script(cartridge)
            if warp
            else (None, "it starts at the title screen.")
        )
        try:
            launch(emulator, cartridge, script)
        except LaunchError as error:
            self._alert(
                f"{emulator.name} could not be started.",
                detail=f"{error} File > Settings is where the emulator is set.",
            )
            return
        self.statusBar().showMessage(
            f"Opened {cartridge.name} in {emulator.name} - "
            + (f"warping to {where}." if script is not None else where),
            8000,
        )

    def _warp_script(self, cartridge: Path) -> tuple[Path | None, str]:
        """The Lua warp for this run, and what the status line should say.

        ``(None, reason)`` whenever there is not going to be one -- a document
        that has not arrived yet, a level whose request needs a branch this
        cartridge no longer has, a file that could not be written. Each of
        those is a run that still happens, so the reason is worded to finish
        "Opened <cart> in <emulator> - ".

        The script is written beside the built cartridge and rewritten by every
        run: it is a product of the build in the same sense the ROM is, and
        keeping one per project is what stops a folder of stale warps.
        """
        try:
            text = self._warp_lua()
        except (ValueError, OSError) as error:
            # :class:`BranchNotTheGames` among them, and the cartridge that
            # could not be read for it: neither is a reason to hold the run
            # back, so both are said and then launched past.
            return None, f"it starts at the title screen: {error}."
        if text is None:
            return None, "it starts at the title screen."
        script = cartridge.with_name(SCRIPT_NAME)
        try:
            script.write_text(text, newline="\n")
        except OSError as error:
            return None, (
                f"it starts at the title screen: {SCRIPT_NAME} could not be "
                f"written ({error.strerror or error})."
            )
        return script, self._warp_label()

    def _warp_lua(self) -> str | None:
        """The script for whichever document is being edited, or None for one
        that is not up yet -- a cartridge still opening, a map still loading."""
        if self._mode is EditorMode.WORLD:
            state = self._overworld_save_state()
            if state is None:
                return None
            spawn, settings, flags = state
            return overworld_script(
                spawn.submap,
                spawn.x,
                spawn.y,
                settings,
                flags,
                where=self._addresses,
            )
        if self._snapshot is None:
            return None
        # The built cartridge rather than the image on the canvas: the build
        # that just ran may have moved the branch the request needs, and it is
        # the file the emulator is about to open that has to be asked about.
        return level_script(
            self._snapshot.level,
            rom_path(self._project).read_bytes(),
            where=self._addresses,
        )

    def _warp_label(self) -> str:
        """What the run warps to, as the status line says it."""
        if self._mode is EditorMode.WORLD:
            return "the world map"
        assert self._snapshot is not None
        return f"level {hexnum(self._snapshot.level, 3)}"

    def _warn_unpatched(self) -> None:
        """Say, before a run opens, what it will not be showing.

        The save's counterpart, and the reason this is a modal rather than
        only the status line and the test window's standing notice: an edit
        that cannot reach the image is told with the numbers when it is
        *saved*, and somebody who has just been refused a save and then sees
        a test run come up quietly reads the run as agreeing with the canvas.
        It does not, and the two answers have to be as loud as each other.

        Said every time, for the same reason the save says it every time: the
        run is about to be wrong in a way nothing in the picture shows.
        """
        parts = self._skipped_parts()
        if not parts:
            return
        self._alert(
            "This test run will not show everything the editor is holding.",
            detail=f"It shows the cartridge's own {' and '.join(parts)}: the "
            f"canvas has outgrown the room the built image gives it, or "
            f"names a label only a build can resolve. Save and rebuild, then "
            f"open the built image. Everything else in the run is as the "
            f"editor has it.",
        )

    def _show_play(
        self,
        level: int | None,
        patches: Mapping[int, bytes] | None,
        overworld: OverworldRun | None = None,
    ) -> None:
        """Put a run up in the play window, building one only if there is none.

        The window is reused where there is one, and it is told the run afresh
        every time: the canvas may have moved on since it was opened, and
        restarting a level nobody is looking at would be worse than not
        reusing it. Either kind of run goes through here, so which cartridge
        the run is made on is said once.

        And what the run could **not** be made to carry is said once here too
        -- both callers have just gathered their patches, so
        :meth:`_note_skipped` holds the reading either kind of run needs.
        """
        if self._path is None:
            return
        if self._play is not None:
            if overworld is None:
                self._play.test(level, patches)
            else:
                self._play.test_overworld(overworld)
            self._play.set_notice(*self._play_notice())
            self._play.raise_()
            self._play.activateWindow()
            return
        session = self.ready_play_session()
        if session is None:
            return
        self._play = PlayWindow(
            session, self._path, level, patches, self, overworld=overworld
        )
        self._play.set_notice(*self._play_notice())
        self._play.closed.connect(self._forget_play)
        self._play.show()

    def ready_play_session(self) -> PlayController | None:
        """The booted emulator a test run is asked of, started if it is not up.

        Called when a cartridge's first level lands as well as by
        :meth:`_show_play`, and that is the point of it: the process, the core,
        the ROM and the cart's own boot to the title screen are three of the
        three and a bit seconds a first run used to cost, they have nothing to
        do with which level is asked for, and they can all be paid while
        somebody is looking at their level rather than at a black screen.

        ``None`` without a cartridge, which is the one state in which there is
        nothing to boot. A boot that fails is not reported here -- see
        :meth:`~shiny_mushroom.ui.play.PlayController._boot`.
        """
        if self._path is None:
            return None
        if self._session is None:
            self._session = PlayController(
                self._path,
                base_id=self._base_id,
                target_id=self._target_id,
                role_addresses=self._role_addresses,
                features=self._features,
                role_counts=self._role_counts,
            )
            self._session.failed.connect(self._play_session_failed)
            self._session.boot()
        return self._session

    def _play_session_failed(self, _message: str) -> None:
        """Drop a session that has reported a failure.

        The window says what went wrong and closes -- see
        :meth:`~shiny_mushroom.ui.play_window.PlayWindow._failed` -- and this
        is the other half: a play worker is never retried, so the session
        behind that failure must not be the one the next run is asked of. The
        next run builds a fresh one and pays the boot, which is the honest
        price of a crash.
        """
        self._drop_play_session()

    def _drop_play_session(self) -> None:
        """Shut the test emulator down, if there is one. Safe with none."""
        session, self._session = self._session, None
        if session is not None:
            session.shutdown()
            session.deleteLater()

    def _play_notice(self) -> tuple[str, str]:
        """What the test window says this run is not showing, and why.

        Empty when everything the editor holds reached the image. The parts
        are whatever the gatherers just skipped -- see :meth:`_note_skipped`
        -- and the reason is one for all of them: the edit no longer fits the
        room the built image gives it, and only a build re-places it.

        :data:`DISASSEMBLY` is filed among them because it is the same reading
        -- a build is owed -- but it is not a skipped part and does not take
        their words: nothing outgrew anything, the cartridge is simply older
        than the source it was built from. It is said only when there is no
        skipped part to say instead, which is the more immediate of the two.
        """
        parts = [part for part in self._skipped_parts() if part != DISASSEMBLY]
        if parts:
            return (
                f"Showing the cartridge's {' and '.join(parts)}",
                f"The {' and '.join(parts)} on the canvas no longer fits the "
                f"run of ROM the built image gives it, so it cannot be patched "
                f"in. Save and rebuild, then open the built image.",
            )
        if DISASSEMBLY in self._skipped:
            return (
                "Showing a cartridge built before the disassembly moved",
                "The disassembly has changed since this cartridge was built, "
                "so this is the older build running. Project > Rebuild (F5) "
                "builds it against the source in hand.",
            )
        return "", ""

    def _overworld_save_state(self) -> tuple[WorldSpawn, bytes, bytes] | None:
        """Where the map run starts and the save tables it starts with.

        The half of a world-map run that is about the *map* rather than about
        the cartridge, so both runs that need it can ask: the emulator the
        editor owns, whose run also carries patches, and the external one,
        whose cartridge already has the project's saved edits in it.

        The tables come from the **document** -- the marks are cell-keyed, the
        translevel scan is recomputed, and the event and direction rows are the
        document's own where it carries them, so a repointed or edited table
        means the map as edited; the capture answers only where the document
        has no part. ``None`` before there is a map to answer for.
        """
        snapshot = self._world.snapshot
        if self._rom is None or snapshot is None or not self._world.ready:
            return None
        settings, flags = save_tables(
            self._world.document.tiles,
            self._world.document.level_events or snapshot.level_events,
            self._world.document.directions or snapshot.level_directions,
            initial_level_flags(self._rom, where=self._addresses),
            self._world.completed,
        )
        if self._world.test_spawn is not None:
            spawn = spawn_for_cell(*cell_at(self._world.test_spawn))
        else:
            spawn = DEFAULT_SPAWN
        return spawn, settings, flags

    def _overworld_run(self) -> OverworldRun | None:
        """Everything a world-map test run is made of, or None without a map.

        The save tables come from the *document* -- the marks are cell-keyed,
        the translevel scan is recomputed, and the event and direction rows
        are the document's own where it carries them, so a repointed or
        edited table means the map as edited; the capture answers only where
        the document has no part. The patches carry the level document too --
        its Layer 2 pointer riding along, exactly as a direct test run carries
        it -- but without its entrance override: a level entered from the map
        should show its edits, through its own front door.
        """
        state = self._overworld_save_state()
        if state is None:
            return None
        spawn, settings, flags = state
        patches = (
            self._layer2_pointer_patch()
            | self._level_document_patch()
            | self._world_map_patch()
            | self._palette_patch()
            | self._level_palette_patch()
        )
        # The overworld loads graphics too, so the project's edited files
        # ride the way they do on a level load -- placed off whatever the
        # patches above already claim of the free space.
        patches |= cart_patches.saved_graphics_patch(
            self._project,
            self._rom,
            self._addresses,
            self._status_message,
            taken=[range(at, at + len(run)) for at, run in patches.items()],
        )
        return OverworldRun(
            submap=spawn.submap,
            x=spawn.x,
            y=spawn.y,
            tile_settings=settings,
            event_flags=flags,
            patches=patches,
        )

    def test_patches(self) -> dict[int, bytes]:
        """The cartridge edits that make a test run show what the editor holds.

        **This is the seam an in-memory edit crosses.** Nothing the editor
        changes is written to a file; a test run gets it by patching the
        emulator's own copy of the cartridge, which costs a level load rather
        than an assembler pass. Every future kind of edit joins here.

        Three kinds today. The **level document**, and which of its two halves
        moved decides how:

        - **A stream that has changed** takes the header with it, in one
          :func:`~shiny_mushroom.rom_patches.level_patch` call, because a stream
          that has *grown* has to be relocated and the header is what points at
          it. The two cannot be patched independently once that is on the table.
        - **A header on its own** -- a header edit, or a header the project has
          saved -- is five bytes at a known offset, so it can never disturb what
          comes after and needs none of the relocation machinery. Which also
          means it still works on a cartridge that machinery cannot read.

        The streams are compared against the **cartridge's own** -- see
        :func:`~shiny_mushroom.cart_patches.level_document_patch` -- so a level
        the project has saved but the build has not yet re-placed is carried
        too, not only the edit still in hand.

        The **test start**, which is here rather than being written into the
        running game because SMW has no in-level teleport: moving the player
        moves him and nothing else, and the level is streamed into VRAM as the
        camera scrolls, so the screen keeps whatever the scroll code had already
        put there. Patching the entrance instead makes the loader build the
        level around the new start, which gets the camera, the terrain and the
        level's sprites right because none of it is being second-guessed. See
        :func:`~shiny_mushroom.rom_patches.entrance_patch`.

        And the **world map** -- see :meth:`_world_map_patch`. Beating the
        level being tested walks out onto the overworld, and it has to be the
        overworld the editor holds, unsaved edits included.
        """
        if self._snapshot is None or self._rom is None or self._doc is None:
            return {}
        if not self._addressable:
            return {}
        # One reading of the project's overlay for the whole gather: what is
        # edited, what is packed and which files the project adds are each
        # asked for by more than one arm below, and none of it can change
        # while one patch set is being built.
        with scanning_once():
            return self._test_patches()

    def _test_patches(self) -> dict[int, bytes]:
        """:meth:`test_patches`' body, inside its one reading of the overlay."""
        assert self._snapshot is not None and self._rom is not None
        # The project's saved graphics and Map16 tables first: they belong to
        # no document, and a refresh that left them out would show the edit
        # over the cartridge's stock tiles. The graphics may relocate, so what
        # they claim is kept off the document's own relocation.
        patches = self._saved_assets_patch()
        # The Layer 2 pointer rides along: a repoint is a *saved* project
        # fact, but the test window boots the ROM as it was last built.
        patches |= self._layer2_pointer_patch() | self._level_document_patch(
            taken=cart_patches.claimed(patches)
        )
        start = self._test_start_for()
        if start is not None:
            patches |= entrance_patch(
                self._rom,
                self._snapshot.level,
                start,
                vertical=bool(self._snapshot.screen_mode & LAYOUT_LAYER1_VERTICAL),
                where=self._addresses,
            )
        # The third kind of edit at this seam: walking out of the level lands
        # on the overworld, and it has to be the overworld the editor holds.
        patches |= self._world_map_patch()
        # And the fourth: the colours. The canvas gets them by recolouring the
        # capture, which a running game cannot do -- it has to boot an image
        # already wearing them.
        patches |= self._palette_patch()
        # The level's own palette rides the same way -- over the blob a build
        # already placed, where there is one.
        patches |= self._level_palette_patch()
        return patches

    def _saved_assets_patch(self) -> dict[int, bytes]:
        """The project's saved graphics and Map16 tables, over the image."""
        return cart_patches.saved_assets_patch(
            self._project,
            self._rom,
            self._addresses,
            self._build_symbols(),
            self._status_message,
        )

    def _level_document_patch(
        self, doc: Level | None = None, taken: Sequence[range] = ()
    ) -> dict[int, bytes]:
        """The level document's half of the seam: the stream-and-header or
        header-only patch :meth:`test_patches` documents, and nothing else --
        no entrance override, which is why a world-map run can share it.

        ``doc`` stands in for the held document where a caller has one the
        window has not committed -- a repoint's reload, carrying the header
        the same dialog edited."""
        if self._snapshot is None:
            return {}
        return cart_patches.level_document_patch(
            doc if doc is not None else self._doc,
            self._history,
            self._rom,
            self._snapshot.level,
            self._addresses,
            self._status_message,
            lambda parts: self._note_skipped(LEVEL_PARTS, parts),
            has_background=bool(self._snapshot.layer2_background),
            taken=taken,
        )

    def _forget_play(self) -> None:
        """Let the closed window go, and keep the emulator it was showing.

        The session is the editor's, not the window's: it is still booted, it
        still holds the savestate the last run left, and the next Test Level
        is a restore rather than a boot. :meth:`_drop_play_session` is what
        ends it, and only the cartridge changing calls that.
        """
        play, self._play = self._play, None
        if play is not None:
            play.deleteLater()

    def _close_play(self) -> None:
        """Shut the test window and its emulator down. Safe with neither.

        Called at the doors where the cartridge stops being the cartridge --
        opened, closed, or the window itself going away. The session boots one
        image and patches that image for every run, so a cartridge that has
        been replaced or rebuilt is a session that has to go with it.
        """
        if self._play is not None:
            self._play.close()
        self._drop_play_session()
