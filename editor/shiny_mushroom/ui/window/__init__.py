"""The main window's sections, one module each.

:class:`~shiny_mushroom.ui.main_window.MainWindow` is assembled from the
mixins here rather than from delegates, because no section of it owns private
state: the level, the project, the mode and the two documents are read and
written across every part of the window, so an object with its own state and a
narrow interface would need that interface invented first, and would be a
mixin with a back-reference in the meantime. A mixin says what the shape
actually is -- one object, its methods grouped by subject -- and each module
here is one subject.

A mixin declares no state of its own. Every attribute it touches is
``MainWindow``'s, set in ``MainWindow.__init__``, which stays the one place
the window's state is declared and described.
"""
