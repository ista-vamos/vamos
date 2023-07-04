from ..ir.element import Element
from ..ir.type import EventType


class Program(Element):
    def __init__(self, events, imports, stmts):
        super().__init__(None)
        self.events = events
        self.imports = imports
        self.statements = stmts

    def __getitem__(self, item):
        return self.statements[item]

    def __repr__(self):
        return "Program(...)"

    @property
    def children(self):
        return self.statements


class Statement(Element):
    def __init__(self):
        super().__init__(None)

    @property
    def children(self):
        return ()


class StatementList(Element):
    def __init__(self, stmts):
        super().__init__(None)
        self.statements = stmts

    def __getitem__(self, item):
        return self.statements[item]

    @property
    def children(self):
        return self.statements

    def __repr__(self):
        s = str(self.statements)
        if len(s) > 40:
            return f"StatementList({s[:40]} ...)"
        return f"StatementList({s})"


class Import(Statement):
    def __init__(self, name):
        super().__init__()
        self.module = name

    def __repr__(self):
        return f"Import({self.module})"

    @property
    def children(self):
        return ()


class RunCommand(Statement):
    def __init__(self, cmd):
        super().__init__()
        self.cmd = cmd

    @property
    def children(self):
        return ()


class Yield(Statement):
    def __init__(self, events, trace):
        super().__init__()
        self.events = events
        self.trace = trace

    def __repr__(self):
        return f"Yield({self.events}, {self.trace})"

    @property
    def children(self):
        return self.events + [self.trace]


class Let(Statement):
    """
    Bind a name: let `name` = `obj`
    """

    def __init__(self, name, obj):
        super().__init__()

        self.name = name
        self.obj = obj

    def __repr__(self):
        return f"Let({self.name}, {self.obj})"

    @property
    def children(self):
        return ()


class ForEach(Statement):
    """
    foreach `val` in `iterable` { }
    """

    def __init__(self, val, iterable, stmts):
        super().__init__()
        self.value = val
        self.iterable = iterable
        self.stmts = stmts

    def __getitem__(self, item):
        return self.stmts[item]

    def __repr__(self):
        return f"ForEach({self.value} in {self.iterable} do {self.stmts})"

    @property
    def children(self):
        return self.stmts


class Continue(Statement):
    @property
    def children(self):
        return ()

    def __repr__(self):
        return "Continue"


class Break(Statement):
    @property
    def children(self):
        return ()

    def __repr__(self):
        return "Break"


class OutputDecl(Statement):
    def __init__(self, trace, out):
        super().__init__()
        self.trace = trace
        self.out = out

    @property
    def children(self):
        return ()

    def __repr__(self):
        return f"OutputDecl({self.trace}, {self.out})"


class Event(Element):
    def __init__(self, name, params):
        super().__init__(EventType(name))
        self.name = name
        self.params = params

    def __repr__(self):
        return f"Event({self.name}, {self.params})"

    @property
    def children(self):
        return self.params or ()
