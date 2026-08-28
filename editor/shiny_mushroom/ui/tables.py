"""One look for every table in the editor.

Two dialogs show the game's records as rows -- the fixed-table editor over the
world map's tables (:mod:`shiny_mushroom.ui.table_editor`) and the Level Data
window (:mod:`shiny_mushroom.ui.level_data_dialog`) -- and this is what makes
them the same table. A view is handed to :func:`style_table` and comes back
looking like the others; nothing about *what* a table holds lives here.

Palette-only, like :mod:`shiny_mushroom.ui.theme`, and for the same reason: a
stylesheet on an item view takes over the drawing the platform style was doing
and has to re-describe it, per theme, forever. Everything below is either a
widget property Qt already honours or a colour **derived from the application
palette** -- so a theme switch re-derives it (:class:`_Restyled` watches for
one) and no colour is written down twice.

Two decisions carry the look.

**Rhythm instead of rules.** The grid is off and the rows alternate. A ruled
grid over rows of controls draws a box around every value and reads as graph
paper; banding separates rows with no ink at all, and the columns are already
separated by the controls standing in them.

**A selection tints, it never repaints.** Qt's own selection paints
``Highlight`` behind the cell and ``HighlightedText`` over it -- which works
only for text the view itself draws. A cell holding a *widget* (every cell of
the table editor) or text with a colour of its own (the level listing's links)
keeps its own ink over the new background, and full-strength blue behind a blue
link is a value the selection has hidden. So a styled view's ``Highlight`` is a
**wash** -- the accent blended most of the way into the surface -- and its
``HighlightedText`` is the ordinary text colour: the row is unmistakably picked
out, and nothing in it changes colour to say so.
"""

from __future__ import annotations

from PySide6.QtCore import QEvent, QObject, Qt
from PySide6.QtGui import QColor, QPalette
from PySide6.QtWidgets import (
    QAbstractItemView,
    QApplication,
    QLabel,
    QStyledItemDelegate,
    QStyleOptionViewItem,
    QTableView,
    QWidget,
)

#: How far a cell's contents sit from the column boundary, which is what keeps
#: a value off its neighbour and two neighbouring controls off each other's
#: edge. Horizontal only: a row is exactly as tall as the tallest thing in it,
#: because the rows are the table and space between them is space not spent on
#: them.
CELL_PADDING = 6

#: How much of the surface is left in a selected row: the accent is blended
#: this far *into* ``Base`` rather than laid over it. Far enough that ordinary
#: text keeps its contrast, near enough that the row still reads as picked.
SELECTION_WASH = 0.26

#: How far a note is greyed toward the surface behind it. A table's
#: explanatory paragraph is context for the rows, not a row.
NOTE_GREY = 0.38


def _blended(over: QColor, under: QColor, amount: float) -> QColor:
    """``over`` mixed ``amount`` of the way onto ``under``, opaque.

    Opaque rather than an alpha brush: an item view's selection is painted by
    the style, and not every style composites a translucent ``Highlight`` the
    same way -- while every one of them fills with a solid colour identically.
    """
    return QColor(
        *(
            round(below + (above - below) * amount)
            for above, below in (
                (over.red(), under.red()),
                (over.green(), under.green()),
                (over.blue(), under.blue()),
            )
        )
    )


def selection_wash(palette: QPalette | None = None) -> QColor:
    """The colour a selected row is filled with -- see the module docstring."""
    palette = palette or QApplication.palette()
    return _blended(
        palette.color(QPalette.ColorRole.Highlight),
        palette.color(QPalette.ColorRole.Base),
        SELECTION_WASH,
    )


def note_ink(palette: QPalette | None = None) -> QColor:
    """The colour a table's explanatory note is written in."""
    palette = palette or QApplication.palette()
    return _blended(
        palette.color(QPalette.ColorRole.Window),
        palette.color(QPalette.ColorRole.WindowText),
        NOTE_GREY,
    )


def table_palette(palette: QPalette | None = None) -> QPalette:
    """A view's palette: the selection washed rather than inverted.

    **Partial**, and that is the whole of how a table follows a theme switch.
    A palette carries which of its roles were set deliberately, and a widget
    resolves those itself and inherits the rest -- so setting only these two
    leaves the surface, the ink and the banding the application's, and leaves
    Qt telling the view when they change. A view handed a *whole* copy of the
    palette stops inheriting anything, and Qt stops telling it anything.
    """
    palette = palette or QApplication.palette()
    out = QPalette()
    wash = selection_wash(palette)
    for group in (QPalette.ColorGroup.Active, QPalette.ColorGroup.Inactive):
        out.setColor(group, QPalette.ColorRole.Highlight, wash)
        out.setColor(
            group,
            QPalette.ColorRole.HighlightedText,
            palette.color(group, QPalette.ColorRole.Text),
        )
    return out


#: The events a widget hears a theme switch through. All three, because which
#: of them arrives is not something to depend on: a switch changes the style as
#: well as the palette (see :func:`~shiny_mushroom.ui.theme.apply_theme`), and
#: which roles a widget resolves for itself decides what Qt bothers to tell it.
_PALETTE_CHANGED = (
    QEvent.Type.ApplicationPaletteChange,
    QEvent.Type.PaletteChange,
    QEvent.Type.StyleChange,
)


class _Restyled(QObject):
    """Re-derives a widget's colours when the application palette changes.

    Guarded against itself: setting a widget's palette sends it a
    ``PaletteChange`` synchronously, which is one of the events this watches
    for, so an unguarded handler would re-enter until the stack ran out.
    """

    def __init__(self, widget: QWidget, restyle) -> None:  # noqa: ANN001 - a callable
        super().__init__(widget)
        self._restyle = restyle
        self._restyling = False
        widget.installEventFilter(self)

    def eventFilter(  # noqa: N802 - Qt override
        self, watched: QObject, event: QEvent
    ) -> bool:
        if event.type() in _PALETTE_CHANGED and not self._restyling:
            self._restyling = True
            try:
                self._restyle(watched)
            finally:
                self._restyling = False
        return False


class PaddedCells(QStyledItemDelegate):
    """Cells with room either side of what is in them.

    Item views measure a cell to fit its contents exactly and stand a control
    across the whole of it, so two columns' values end up shoulder to shoulder
    and two spin boxes share an edge. A cell asks for the padding in its width
    and a control is placed inside it -- but what is *painted* keeps the whole
    rectangle, so a selected row's wash runs edge to edge instead of breaking
    into one patch per column. The height is untouched: see
    :data:`CELL_PADDING`.
    """

    def sizeHint(  # noqa: N802 - Qt override
        self, option: QStyleOptionViewItem, index: object
    ) -> object:
        hint = super().sizeHint(option, index)
        hint.setWidth(hint.width() + 2 * CELL_PADDING)
        return hint

    def updateEditorGeometry(  # noqa: N802 - Qt override
        self, editor: QWidget, option: QStyleOptionViewItem, index: object
    ) -> None:
        editor.setGeometry(option.rect.adjusted(CELL_PADDING, 0, -CELL_PADDING, 0))


def style_table(view: QTableView) -> None:
    """Give ``view`` the editor's table look, now and after a theme switch.

    Idempotent, and safe to call before the view has a model: everything set
    here is a property of the view rather than of what is in it.
    """
    view.setAlternatingRowColors(True)
    view.setShowGrid(False)
    view.setWordWrap(False)
    view.setCornerButtonEnabled(False)
    view.horizontalHeader().setHighlightSections(False)
    # The leftover width goes to nothing rather than to whichever column
    # happens to be last: a number box stretched across half the dialog is
    # not a wider value, only a wider box.
    view.horizontalHeader().setStretchLastSection(False)
    view.setVerticalScrollMode(QAbstractItemView.ScrollMode.ScrollPerPixel)
    _restyle_table(view)
    _Restyled(view, _restyle_table)


def _restyle_table(view: QTableView) -> None:
    view.setPalette(table_palette())


def widen_widget_column(view: QTableView, column: int) -> None:
    """Give ``column`` a cell's padding, for a column whose cells are widgets.

    A resize-to-contents pass measures an index widget at its own size hint and
    stops there, and :class:`PaddedCells` then stands that widget *inside* the
    cell's padding -- so a column sized by the pass alone is a padding's worth
    too narrow and the widget elides what it is showing. Called after the pass.
    """
    view.setColumnWidth(column, view.columnWidth(column) + 2 * CELL_PADDING)


def style_note(label: QLabel) -> None:
    """Write ``label`` as a table's note: wrapped, and quieter than its rows."""
    label.setWordWrap(True)
    label.setTextFormat(Qt.TextFormat.PlainText)
    _restyle_note(label)
    _Restyled(label, _restyle_note)


def _restyle_note(label: QLabel) -> None:
    # Partial, for :func:`table_palette`'s reason: the one role, and the rest
    # of the label still the theme's.
    palette = QPalette()
    palette.setColor(QPalette.ColorRole.WindowText, note_ink())
    label.setPalette(palette)
