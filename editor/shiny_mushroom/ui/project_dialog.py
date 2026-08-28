"""The dialogs a project is started from, and the one that builds its cartridge.

Four modals, and the reason they are together is that they are one flow. The
editor cannot draw a level until a reference cartridge has been sliced into
``smw/assets`` -- see :mod:`shiny_mushroom.setup` -- there is no point offering to
make a project before that, and a project is not usable until its own cartridge
has been assembled from the disassembly, those assets and its overlay. So the
first run asks for the cartridge, does the slicing, hands on to choosing or
naming a project, and builds it.

**The slow ones run on a thread.** Extracting is about a minute and a build about
half of one, and a modal that stops repainting for that long is indistinguishable
from one that has hung. Each therefore shows progress, disables its own buttons
and refuses to be dismissed until the job has ended rather than blocking, which
is also why they own workers at all: nothing else in the editor needs one, and
putting them in :mod:`shiny_mushroom.setup` or :mod:`shiny_mushroom.build` would
put Qt in modules that have none. Both are the same shape and are built out of
the same pair -- :class:`_Work` for the job and :class:`_Threaded` for the dialog
that runs it -- so the only thing either dialog states about threading is which
job it wants.
"""

from __future__ import annotations

from pathlib import Path

from PySide6.QtCore import QObject, Qt, QThread, Signal
from PySide6.QtGui import QColor, QPalette
from PySide6.QtWidgets import (
    QComboBox,
    QDialog,
    QDialogButtonBox,
    QFileDialog,
    QHBoxLayout,
    QLabel,
    QLineEdit,
    QListWidget,
    QListWidgetItem,
    QProgressBar,
    QPushButton,
    QStyle,
    QStyledItemDelegate,
    QVBoxLayout,
    QWidget,
)

from shiny_mushroom import APP_NAME
from shiny_mushroom.build import build
from shiny_mushroom.project import NAME_PATTERN, Project, projects_root, valid_name
from shiny_mushroom.setup import (
    SetupError,
    available_targets,
    inspect,
    prepare,
    ready_versions,
)
from shiny_mushroom.ui.dialogs import open_folder, selectable_label
from smw_tools.bases import BASES, DEFAULT_BASE, DEFAULT_TARGET, RomBase
from smw_tools.rom_versions import ROM_VERSIONS

#: The file dialog's filter, for every dialog in the app that asks for a
#: cartridge -- this one and the main window's Open. LoROM and HiROM images both
#: appear as ``.sfc`` or ``.smc``; the copier-headered ``.smc`` is listed because
#: that is what many dumps in the wild still are, not because anything strips
#: the header yet.
CART_FILTER = "SNES ROM images (*.sfc *.smc);;All files (*)"

#: What the name box says it wants, in the same words the rule is written in.
NAME_RULE = (
    "Lowercase letters, digits, '-' and '_', starting with a letter or digit. "
    "No spaces."
)


def default_target(base: RomBase, available: tuple[str, ...] | None = None) -> str:
    """Which of ``base``'s targets a new project is offered first.

    The default target where the base has it and its assets are there, and the
    first available one otherwise -- a base is not obliged to have a target of
    that name, and a release nobody has extracted cannot be built. ``sa1`` has
    exactly one, and it happens to be ``U``. With nothing available the
    default is still named, so the dialog has a row to show as unavailable.

    ``available`` is the list of targets with assets, which the dialog has
    already asked for; ``None`` asks again.
    """
    if available is None:
        available = available_targets(base)
    if DEFAULT_TARGET in available:
        return DEFAULT_TARGET
    if available:
        return available[0]
    if DEFAULT_TARGET in base.targets:
        return DEFAULT_TARGET
    return next(iter(base.targets))


def open_projects_folder() -> bool:
    """Show the projects folder in the desktop's file manager.

    Created first, because it is only made when the first project is: offering
    to open a folder and then opening nothing is worse than the folder being
    empty. Reports whether the handover worked, as :func:`~.dialogs.open_folder`
    does.
    """
    return open_folder(projects_root())


def target_unavailable(base: RomBase, target_id: str) -> str:
    """Why a project cannot be made for ``target_id`` yet, or an empty string.

    One case: its release's reference cartridge has not been extracted, so
    there is no graphics set for its build to read. The cure is a thing the
    person can go and get, which is why it is said rather than the row hidden.
    """
    if target_id in available_targets(base):
        return ""
    label = ROM_VERSIONS[target_id].label if target_id in ROM_VERSIONS else target_id
    return (
        f"No reference cartridge for {label} has been extracted. Add one "
        f"under File > Reference Cartridge..."
    )


def base_unavailable(base: RomBase) -> str:
    """Why a project cannot be made on ``base`` yet, or an empty string.

    One case today, and it is not a fault: a base built by running a third-party
    patch over the assembled ROM needs that patch's tree, which is the user's own
    checkout because it ships no licence this repository could redistribute --
    see :class:`~smw_tools.bases.PostBuildPatch`. Asked here rather than
    discovered at build time, so the answer is "this base needs something you
    have not got" and not "asar failed" half a minute in.
    """
    patch = base.patch
    if patch is not None and patch.locate() is None:
        return patch.missing_message()
    return ""


class _Work(QObject):
    """One long job, run off the UI thread and reported back by signal.

    The whole of what the two slow steps of this flow have in common: extracting
    a cartridge and assembling one are a minute and half a minute of blocking
    work, they report what they are doing rather than how far along they are,
    and either can fail with something the user has to read. Subclasses say what
    the job *is* by implementing :meth:`work`; everything about running it and
    reporting it is here.

    **Every exception is caught, because there is no caller left to catch it.**
    This runs at the end of a queued call on a thread of its own, so anything
    raised out of it would reach Qt's unhandled-exception path and be printed to
    a console a windowed build does not have.
    """

    progress = Signal(str)
    finished = Signal(object)
    failed = Signal(str)

    def work(self) -> object:
        """Do the job, reporting progress through :attr:`progress`."""
        raise NotImplementedError

    def run(self) -> None:
        try:
            result = self.work()
        except Exception as error:  # noqa: BLE001 - a thread reports everything
            self.failed.emit(str(error))
        else:
            self.finished.emit(result)


class _Threaded(QDialog):
    """A modal that owns one :class:`_Work`, the thread it runs on, and the
    three states the two of them can be in.

    Started and stopped in one place each, because the pair is what has to be
    right: a thread quit without being waited on outlives the dialog that owns
    it, and a worker dropped while its thread still runs is a signal delivered
    to a deleted object.

    The rest is what a job looks like: a status line carrying whatever it last
    said, an indeterminate bar while it runs, a result stored where the caller
    reads it, and a failure that stays on screen with the buttons back. A
    subclass says what the job is, where those two widgets sit among its own,
    and -- in :meth:`_failure_text` -- how a failure is worded.
    """

    def __init__(
        self,
        buttons: QDialogButtonBox.StandardButton,
        parent: QWidget | None = None,
    ) -> None:
        super().__init__(parent)
        self.setModal(True)
        self._thread: QThread | None = None
        self._worker: _Work | None = None
        #: What the job produced, once it has finished. What the caller reads
        #: back, and what makes these dialogs worth an answer at all. Not
        #: ``result``: ``QDialog`` already has a method of that name, and an
        #: attribute over it would make ``dialog.result()`` a type error.
        self.outcome: object | None = None

        self._status = selectable_label()
        self._progress = QProgressBar()
        # Indeterminate: both jobs report what they are doing, not how far
        # along they are, and a bar that invented a percentage would be lying.
        self._progress.setRange(0, 0)
        self._progress.setVisible(False)

        self._buttons = QDialogButtonBox(buttons)
        self._buttons.rejected.connect(self.reject)

    @property
    def running(self) -> bool:
        """Whether the job is on its thread at this moment."""
        return self._thread is not None

    def _run(self, worker: _Work) -> None:
        self._worker = worker
        self._thread = QThread(self)
        worker.moveToThread(self._thread)
        self._thread.started.connect(worker.run)
        worker.progress.connect(self._report)
        worker.finished.connect(self._finish)
        worker.failed.connect(self._fail)
        self._busy(True)
        self._thread.start()

    def _busy(self, busy: bool) -> None:
        """Say the job is running, or is not: the bar up, the buttons away."""
        self._progress.setVisible(busy)
        self._buttons.setEnabled(not busy)

    def _report(self, what: str) -> None:
        self._status.setText(what)

    def _finish(self, result: object) -> None:
        self.outcome = result
        self._stop()
        self.accept()

    def _fail(self, message: str) -> None:
        self._stop()
        self._busy(False)
        self._status.setText(self._failure_text(message))

    def _failure_text(self, message: str) -> str:
        """How a failure is worded: the job's own complaint, unless a subclass
        has a sentence to put in front of it."""
        return message

    def _stop(self) -> None:
        """Wind the thread up and let the worker go. Safe with neither."""
        if self._thread is not None:
            self._thread.quit()
            self._thread.wait()
            self._thread = None
        self._worker = None

    def reject(self) -> None:  # noqa: D102 - Qt override
        """Refuse to be dismissed while the job is running.

        Escape, the window's close button and any Cancel all end here, and none
        of them can stop the job: it is a minute of file writes or asar in a
        subprocess, with no answer to "stop" that leaves anything usable
        behind. Going anyway would let the thread run on with the dialog gone
        while the caller read the answer as "cancelled" -- half-extracted
        assets, which read as a corrupt checkout, or a retried build writing
        the same ROM a second time alongside the first.

        This is the whole mechanism: ``QDialog``'s own ``closeEvent`` calls
        ``reject`` and ignores the close when the dialog is still up
        afterwards, so the window manager is refused by the same guard. What it
        must never be is a window flag -- Qt recreates the window when one
        changes, which hides the dialog, and hiding a dialog is what ends
        ``exec()``.
        """
        if not self.running:
            super().reject()


class _Extractor(_Work):
    """Runs :func:`~shiny_mushroom.setup.prepare` off the UI thread."""

    def __init__(self, cart: Path, wanted: str | None = None) -> None:
        super().__init__()
        self._cart = cart
        self._wanted = wanted

    def work(self) -> object:
        return prepare(self._cart, self._wanted, on_progress=self.progress.emit)


class CartridgeDialog(_Threaded):
    """Ask for a reference cartridge and slice its assets out of it.

    The cartridge is **identified before anything is written**, so a hack or
    another game is refused in the moment it is chosen rather than after a
    minute of extracting -- and the label says which release it turned out to be,
    because that is the fact a checkout otherwise carries no evidence of.

    Any of the five releases is taken, and each one *adds* to what is on disk:
    a release's graphics have their own set, and the music and samples are
    the same in every cartridge. The dialog says which releases are already
    there, so extracting a second is a visible addition and not a mystery.
    ``wanted`` narrows it to one release -- for a project that needs that
    release's assets -- and every other is refused by name.
    """

    def __init__(
        self, parent: QWidget | None = None, wanted: str | None = None
    ) -> None:
        super().__init__(
            QDialogButtonBox.StandardButton.Ok | QDialogButtonBox.StandardButton.Cancel,
            parent,
        )
        self.setWindowTitle(f"{APP_NAME} - Reference Cartridge")
        self._cart: Path | None = None
        self._wanted = wanted

        which = (
            f"the {ROM_VERSIONS[wanted].label} release of Super Mario World"
            if wanted is not None and wanted in ROM_VERSIONS
            else "any release of Super Mario World"
        )
        self._explanation = QLabel(
            f"{APP_NAME} runs the game's own code, so it needs the graphics, "
            f"music and samples from a real cartridge. They are not "
            f"distributed with the editor.\n\n"
            f"Choose an unmodified ROM of {which}. It is read, never written."
        )
        self._explanation.setWordWrap(True)

        self._have = QLabel()
        self._have.setWordWrap(True)
        self._say_what_is_there()

        self._path_box = QLineEdit()
        self._path_box.setReadOnly(True)
        self._path_box.setPlaceholderText("No cartridge chosen")
        browse = QPushButton("Choose...")
        browse.clicked.connect(self._choose)

        chooser = QHBoxLayout()
        chooser.addWidget(self._path_box, 1)
        chooser.addWidget(browse)

        self._buttons.button(QDialogButtonBox.StandardButton.Ok).setText("Extract")
        # The editor cannot draw anything without this, so the way out of this
        # dialog is the way out of the app. Saying "Cancel" would suggest there
        # is an editor waiting behind it.
        self._buttons.button(QDialogButtonBox.StandardButton.Cancel).setText("Quit")
        self._buttons.accepted.connect(self._extract)
        self._ok().setEnabled(False)

        layout = QVBoxLayout(self)
        layout.addWidget(self._explanation)
        layout.addWidget(self._have)
        layout.addLayout(chooser)
        layout.addWidget(self._status)
        layout.addWidget(self._progress)
        layout.addWidget(self._buttons)

    @property
    def version(self) -> str | None:
        """The release that was extracted, once one has been."""
        return None if self.outcome is None else str(self.outcome)

    @property
    def wanted(self) -> str | None:
        """The one release this dialog will take, or ``None`` for any."""
        return self._wanted

    def _say_what_is_there(self) -> None:
        """Name the releases whose assets are already on disk."""
        have = ready_versions()
        if not have:
            self._have.setText("No cartridge has been extracted yet.")
            return
        named = ", ".join(f"{ROM_VERSIONS[one].label} ({one})" for one in have)
        self._have.setText(f"Already extracted: {named}.")

    def _ok(self):  # noqa: ANN201 - a QPushButton
        return self._buttons.button(QDialogButtonBox.StandardButton.Ok)

    def _choose(self) -> None:
        chosen, _ = QFileDialog.getOpenFileName(
            self, f"{APP_NAME} - Reference Cartridge", "", CART_FILTER
        )
        if chosen:
            self.set_cart(Path(chosen))

    def set_cart(self, cart: Path) -> None:
        """Take ``cart`` as the choice, saying at once whether it will do.

        Public so the flow can be driven without a file dialog -- which under
        Qt's offscreen platform is the only way to drive it at all.
        """
        self._path_box.setText(str(cart))
        try:
            version = inspect(cart, self._wanted)
        except SetupError as error:
            self._cart = None
            self._status.setText(str(error))
            self._ok().setEnabled(False)
            return
        self._cart = cart
        self._status.setText(
            f"Recognised as {ROM_VERSIONS[version].label} ({version}). "
            f"Ready to extract."
        )
        self._ok().setEnabled(True)

    def _extract(self) -> None:
        if self._cart is None or self.running:
            return
        self._run(_Extractor(self._cart, self._wanted))

    def _finish(self, result: object) -> None:
        # So a dialog shown again lists what this one added. It is about to
        # close, but the list is read off the disk and the cost is nothing.
        self._say_what_is_there()
        super()._finish(result)

    @classmethod
    def run(
        cls, parent: QWidget | None = None, wanted: str | None = None
    ) -> str | None:
        """Show the dialog; return the release extracted, or None if cancelled."""
        dialog = cls(parent, wanted)
        return dialog.version if dialog.exec() == QDialog.DialogCode.Accepted else None


class NameDialog(QDialog):
    """Ask what a new project should be called, and what to build it on.

    Named up front rather than created as ``new-shiny`` and renamed later,
    because the folder name **is** the project's identity -- see
    :class:`~shiny_mushroom.project.Project` -- so a rename is a move on disk
    and not a label change.

    **The ROM base is asked here for the same reason and a stronger one: a
    project cannot change it.** An overlay is written in its base's own paths, so
    moving one to another base is a migration rather than a setting, and there is
    nothing to offer later that would not be a lie. So it is chosen once, at the
    only moment it can be, and written into ``project.json``.

    **The target -- which release the project is built for -- is asked beside
    it, and is as fixed.** Every target of the chosen base is listed, and only
    the ones whose reference cartridge has been extracted can be picked: the
    others are shown greyed and say so, because a release missing from the list
    is indistinguishable from one the editor cannot build at all. A project
    made for a release reads that release's graphics set, so two projects on two
    releases coexist without either seeing the other's.

    The name rule is checked live and in the same words the box states it in. The
    model enforces it authoritatively; this is so a name that will be refused is
    refused before the button is pressed.
    """

    def __init__(
        self,
        suggested: str,
        taken: tuple[str, ...] = (),
        parent: QWidget | None = None,
    ) -> None:
        super().__init__(parent)
        self.setWindowTitle(f"{APP_NAME} - New Project")
        self.setModal(True)
        self._taken = set(taken)

        self._name = QLineEdit(suggested)
        self._name.selectAll()
        self._name.textChanged.connect(self._check)

        self._hint = QLabel(NAME_RULE)
        self._hint.setWordWrap(True)

        self._base = QComboBox()
        for base in BASES.values():
            self._base.addItem(f"{base.id} - {base.label}", base.id)
        self._base.setCurrentIndex(max(0, self._base.findData(DEFAULT_BASE)))
        self._base.currentIndexChanged.connect(self._check_base)

        self._target = QComboBox()
        self._target.currentIndexChanged.connect(self._check_base)

        self._base_hint = QLabel()
        self._base_hint.setWordWrap(True)

        self._buttons = QDialogButtonBox(
            QDialogButtonBox.StandardButton.Ok | QDialogButtonBox.StandardButton.Cancel
        )
        self._buttons.button(QDialogButtonBox.StandardButton.Ok).setText("Create")
        self._buttons.accepted.connect(self.accept)
        self._buttons.rejected.connect(self.reject)

        layout = QVBoxLayout(self)
        layout.addWidget(QLabel("Name your project. It can be renamed later."))
        layout.addWidget(self._name)
        layout.addWidget(self._hint)
        layout.addWidget(
            QLabel("Build it on this ROM base. This cannot be changed later.")
        )
        layout.addWidget(self._base)
        layout.addWidget(
            QLabel(
                "Build it for this release. Only releases with an extracted "
                "reference cartridge can be chosen."
            )
        )
        layout.addWidget(self._target)
        layout.addWidget(self._base_hint)
        layout.addWidget(self._buttons)
        self._offer_targets()
        self._check(suggested)

    @property
    def name(self) -> str:
        return self._name.text().strip()

    @property
    def base_id(self) -> str:
        """Which ROM base the project is to be built on."""
        return self._base.currentData() or DEFAULT_BASE

    @property
    def target_id(self) -> str:
        """Which of the base's targets -- which release -- it is built for."""
        return self._target.currentData() or default_target(BASES[self.base_id])

    def set_base(self, base_id: str) -> None:
        """Choose a base by id. Public so the flow can be driven without a click,
        which under Qt's offscreen platform is the only way to drive it."""
        index = self._base.findData(base_id)
        if index >= 0:
            self._base.setCurrentIndex(index)

    def set_target(self, target_id: str) -> None:
        """Choose a target by id, the same way. A target without assets is
        left where it is: the row is there to be read, not picked."""
        index = self._target.findData(target_id)
        if index >= 0 and self._target_available(index):
            self._target.setCurrentIndex(index)

    def _target_available(self, index: int) -> bool:
        item = self._target.model().item(index)
        return item is not None and bool(item.flags() & Qt.ItemFlag.ItemIsEnabled)

    def _offer_targets(self) -> None:
        """List the chosen base's targets, greying those without assets."""
        base = BASES[self.base_id]
        available = available_targets(base)
        self._target.blockSignals(True)
        self._target.clear()
        for target in base.targets.values():
            ready = target.id in available
            self._target.addItem(
                f"{target.id} - {target.label}"
                + ("" if ready else " (no reference cartridge extracted)"),
                target.id,
            )
            if not ready:
                item = self._target.model().item(self._target.count() - 1)
                item.setFlags(item.flags() & ~Qt.ItemFlag.ItemIsEnabled)
        self._target.setCurrentIndex(
            max(0, self._target.findData(default_target(base, available)))
        )
        self._target.blockSignals(False)

    def _check_base(self) -> None:
        if self.sender() is self._base:
            self._offer_targets()
        self._check(self._name.text())

    def _check(self, text: str) -> None:
        name = text.strip()
        if name in self._taken:
            problem = f"There is already a project called {name!r}."
        elif name and not valid_name(name):
            problem = (
                f"{name!r} cannot be a folder name on every platform. {NAME_RULE}"
                if NAME_PATTERN.match(name) is None
                else f"{name!r} is a name Windows reserves for a device."
            )
        else:
            problem = ""
        self._hint.setText(problem or NAME_RULE)

        base = BASES[self.base_id]
        # A base that cannot be built is shown and refused rather than hidden:
        # what it needs is a thing the person can go and get, and a base missing
        # from the list is indistinguishable from one this build never had. The
        # same for a target whose release has not been extracted.
        unavailable = base_unavailable(base) or target_unavailable(base, self.target_id)
        self._base_hint.setText(
            unavailable
            or f"Builds {base.id}/{self.target_id} - {base.label}, "
            f"{base.target(self.target_id).label}."
        )
        self._buttons.button(QDialogButtonBox.StandardButton.Ok).setEnabled(
            bool(name)
            and valid_name(name)
            and name not in self._taken
            and not unavailable
        )

    @classmethod
    def ask(
        cls,
        suggested: str,
        taken: tuple[str, ...] = (),
        parent: QWidget | None = None,
    ) -> tuple[str, str, str] | None:
        """Show the dialog; return ``(name, base_id, target_id)``, or None if
        cancelled."""
        dialog = cls(suggested, taken, parent)
        if dialog.exec() != QDialog.DialogCode.Accepted:
            return None
        return dialog.name, dialog.base_id, dialog.target_id


class _Builder(_Work):
    """Runs :func:`~shiny_mushroom.build.build` off the UI thread."""

    def __init__(self, project: Project) -> None:
        super().__init__()
        self._project = project

    def work(self) -> object:
        return build(self._project, on_progress=self.progress.emit)


class BuildDialog(_Threaded):
    """Assemble a project's cartridge, showing what it is doing.

    Shown whenever a project is opened, and **usually over in a second**: the
    build is skipped when nothing has moved since last time, which after the
    first one is the ordinary case. When there is real work it is half a minute
    of asar, which is why it is on a thread with its own progress rather than a
    frozen window.

    A failure is not dismissed automatically. asar's complaint is the only thing
    that says *why* a project will not build, and a dialog that vanished with it
    would leave someone with a cartridge that is simply missing.
    """

    def __init__(self, project: Project, parent: QWidget | None = None) -> None:
        super().__init__(QDialogButtonBox.StandardButton.Close, parent)
        self.setWindowTitle(f"{APP_NAME} - Building {project.name}")
        self._project = project
        self._status.setText("Starting...")

        layout = QVBoxLayout(self)
        layout.addWidget(QLabel(f"Building {project.name}'s cartridge."))
        layout.addWidget(self._status)
        layout.addWidget(self._progress)
        layout.addWidget(self._buttons)

    def start(self) -> None:
        """Begin. Separate from construction so a test can inspect first."""
        self._run(_Builder(self._project))

    def _failure_text(self, message: str) -> str:
        return f"The cartridge could not be built.\n\n{message}"

    @classmethod
    def run(cls, project: Project, parent: QWidget | None = None) -> object | None:
        """Build ``project``; return what it produced, or None if it failed."""
        dialog = cls(project, parent)
        dialog.start()
        return dialog.outcome if dialog.exec() == QDialog.DialogCode.Accepted else None


#: Where a row keeps the ``<base>/<target>`` it is to show, so the row's own
#: text stays the project's name and nothing has to parse it back out.
SPEC_ROLE = Qt.ItemDataRole.UserRole

#: How far the base sits in from the list's right edge.
SPEC_MARGIN = 8


class _SpecColumn(QStyledItemDelegate):
    """Paints each row's ROM base as a dim right-hand column.

    A second column rather than more text on the row, because a name and a base
    are different questions and a list of ragged ``name    base`` strings is
    unreadable the moment two names differ in length -- which is always. A
    ``QListWidget`` has one column, so the alignment is drawn rather than laid
    out; a table for two fields would bring headers, selection modes and a
    resize policy for a list that is a few rows long.
    """

    @staticmethod
    def _colour(option) -> QColor:
        """What to draw the base in, so it reads as secondary in every state.

        Three states and each needs its own answer. A **selected** row is
        painted over the highlight, where the placeholder grey is nearly
        invisible -- so it is the highlight's own text colour, faded, which is
        secondary against that background rather than against the window's. A
        **disabled** row is one whose base this build does not have, and takes
        the disabled text colour so both halves of the row say so together.
        Anything else is the ordinary placeholder grey.
        """
        palette = option.palette
        if option.state & QStyle.StateFlag.State_Selected:
            colour = QColor(palette.color(QPalette.ColorRole.HighlightedText))
            colour.setAlphaF(0.7)
            return colour
        if not option.state & QStyle.StateFlag.State_Enabled:
            return palette.color(QPalette.ColorGroup.Disabled, QPalette.ColorRole.Text)
        return palette.color(QPalette.ColorRole.PlaceholderText)

    def paint(self, painter, option, index) -> None:  # noqa: D102 - Qt override
        super().paint(painter, option, index)
        spec = index.data(SPEC_ROLE)
        if not spec:
            return
        painter.save()
        painter.setPen(self._colour(option))
        painter.drawText(
            option.rect.adjusted(0, 0, -SPEC_MARGIN, 0),
            Qt.AlignmentFlag.AlignRight | Qt.AlignmentFlag.AlignVCenter,
            spec,
        )
        painter.restore()


class ChooseProjectDialog(QDialog):
    """Pick which project to work in, or ask for a new one.

    Shown when setup finds projects already on disk. A returning person almost
    always wants the one they were last in, so it is preselected and Enter takes
    it -- but the whole list is there, because the alternative is remembering a
    name and typing it. Only a project this build can open is ever selected or
    answered with; the rest are listed, and say why they are not.

    There is deliberately **no way to answer "none"** other than the button that
    ends the session: a level edited with no project open is work with nowhere to
    go that looks exactly like work being kept, which is the state this whole
    flow exists to make unreachable.
    """

    def __init__(
        self,
        found: tuple[Project, ...],
        current: str | None = None,
        parent: QWidget | None = None,
    ) -> None:
        super().__init__(parent)
        self.setWindowTitle(f"{APP_NAME} - Choose a Project")
        self.setModal(True)
        #: The name chosen, once one has been.
        self.chosen: str | None = None
        #: Whether the New button was the answer instead.
        self.wants_new = False

        self._list = QListWidget()
        self._list.setItemDelegate(_SpecColumn(self._list))
        names = tuple(project.name for project in found)
        for project in found:
            # The base is shown because it decides what the project *is*: two
            # projects with the same levels in them build different cartridges
            # if they are on different bases, and nothing else in the list says
            # so. In the `<base>/<target>` spelling the command line uses, and
            # in a column of its own -- see :class:`_SpecColumn`.
            item = QListWidgetItem(project.name)
            item.setData(SPEC_ROLE, project.spec)
            if not project.buildable:
                # Named rather than dropped: a project made by a build that had
                # a base this one does not is still the person's work, and a
                # list it is simply missing from reads as data loss.
                item.setFlags(item.flags() & ~Qt.ItemFlag.ItemIsEnabled)
                item.setToolTip(
                    f"This build has no ROM base {project.base_id!r}, so "
                    f"{project.name} cannot be opened here."
                )
            self._list.addItem(item)
        self._list.setCurrentRow(self._start_on(names, current))
        self._list.itemDoubleClicked.connect(self.accept)

        new = QPushButton("New Project...")
        new.clicked.connect(self._new)

        # Opens the folder without answering the dialog: a project is an
        # ordinary folder, and the reasons to look in one -- copying a level in,
        # backing one up, seeing why a build failed -- are all reasons to have
        # this list still on screen afterwards.
        folder = QPushButton("Open Projects Folder")
        folder.setToolTip(str(projects_root()))
        folder.setAutoDefault(False)
        folder.clicked.connect(open_projects_folder)

        self._buttons = QDialogButtonBox(
            QDialogButtonBox.StandardButton.Ok | QDialogButtonBox.StandardButton.Cancel
        )
        self._buttons.button(QDialogButtonBox.StandardButton.Ok).setText("Open")
        # Named for what it does. This dialog cannot be dismissed into a usable
        # editor, so "Cancel" would be a lie about what the button is for.
        self._buttons.button(QDialogButtonBox.StandardButton.Cancel).setText("Quit")
        self._buttons.addButton(new, QDialogButtonBox.ButtonRole.ActionRole)
        # HelpRole rather than ActionRole, so every platform's layout puts it at
        # the far end away from Open and New -- it answers nothing, and a button
        # that does not is not one to land beside the two that do.
        self._buttons.addButton(folder, QDialogButtonBox.ButtonRole.HelpRole)
        self._buttons.accepted.connect(self.accept)
        self._buttons.rejected.connect(self.reject)
        self._list.currentRowChanged.connect(lambda _row: self._sync_open())
        self._sync_open()

        layout = QVBoxLayout(self)
        layout.addWidget(QLabel("Which project do you want to open?"))
        layout.addWidget(self._list)
        layout.addWidget(self._buttons)

    @staticmethod
    def _openable(item: QListWidgetItem | None) -> bool:
        """Whether ``item`` is a project this build can actually open."""
        return item is not None and bool(item.flags() & Qt.ItemFlag.ItemIsEnabled)

    def _start_on(self, names: tuple[str, ...], current: str | None) -> int:
        """Which row to open on: the one last worked in, the first that can be
        opened, or none at all.

        A disabled row is never landed on. ``setCurrentRow`` makes one current
        happily enough -- the flag stops it being clicked, not selected -- and
        the dialog would then come up with Enter armed over a project its own
        tooltip says cannot be opened here.
        """
        remembered = names.index(current) if current in names else -1
        if self._openable(self._list.item(remembered)):
            return remembered
        return next(
            (
                row
                for row in range(self._list.count())
                if self._openable(self._list.item(row))
            ),
            -1,
        )

    def _sync_open(self) -> None:
        self._buttons.button(QDialogButtonBox.StandardButton.Ok).setEnabled(
            self._openable(self._list.currentItem())
        )

    def _new(self) -> None:
        self.wants_new = True
        self.accept()

    def accept(self) -> None:  # noqa: D102 - Qt override
        if self.wants_new:
            super().accept()
            return
        item = self._list.currentItem()
        # Enter and a double click reach here without passing the Open button,
        # so the same rule is applied rather than assumed: a row this build
        # cannot open answers nothing, and the list stays up.
        if not self._openable(item):
            return
        self.chosen = item.text()
        super().accept()

    @classmethod
    def ask(
        cls,
        found: tuple[Project, ...],
        current: str | None = None,
        parent: QWidget | None = None,
    ) -> str | bool | None:
        """Show the dialog.

        Returns the project's name to open it, ``True`` to make a new one, and
        ``None`` when the answer was to quit instead.

        Takes the projects rather than their names because the row says which
        ROM base each is built on, and that is not derivable from a name.
        """
        dialog = cls(found, current, parent)
        if dialog.exec() != QDialog.DialogCode.Accepted:
            return None
        return True if dialog.wants_new else dialog.chosen


__all__ = [
    "CART_FILTER",
    "NAME_RULE",
    "SPEC_ROLE",
    "BuildDialog",
    "CartridgeDialog",
    "ChooseProjectDialog",
    "NameDialog",
    "base_unavailable",
    "default_target",
    "open_projects_folder",
    "target_unavailable",
]
