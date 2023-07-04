from ..ir.element import Element
from ..ir.type import BoolType, STRING_TYPE, BOOL_TYPE, OBJECT_TYPE


class Expr(Element):
    """
    Class representing an expression in the language
    """


class TupleExpr(Expr):
    def __init__(self, vals, ty):
        super().__init__(ty)
        self.values = vals

    def __repr__(self):
        return f"TupleExpr({','.join(map(str, self.values))})"

    @property
    def children(self):
        return self.values


#
# class Var(Expr):
#     def __init__(self, v):
#         super().__init__()
#         self.name = v
#
#     def pretty_str(self):
#         return self.name
#
#     def __str__(self):
#         return f"VAR({self.name})"
#
#     def __repr__(self):
#         return f"Var({self.name})"


class CommandLineArgument(Expr):
    """
    Argument to the specification from the command line ($1, $2, ...)
    """

    def __init__(self, n):
        super().__init__(STRING_TYPE)
        self.num = n

    def __repr__(self):
        return f"CommandLineArgument({self.num})"

    @property
    def children(self):
        return ()


class BoolExpr(Expr):
    def __init__(self):
        super().__init__(BOOL_TYPE)

    @property
    def children(self):
        return ()


class And(BoolExpr):
    def __init__(self, lhs, rhs):
        super().__init__()
        self.lhs = lhs
        self.rhs = rhs

    def pretty_str(self):
        return f"({self.lhs.pretty_str()} && {self.rhs.pretty_str()})"

    def __str__(self):
        return f"({self.lhs} && {self.rhs})"

    def __repr__(self):
        return f"And({self.lhs} && {self.rhs})"

    @property
    def children(self):
        return [self.lhs, self.rhs]


class Or(BoolExpr):
    def __init__(self, lhs, rhs):
        super().__init__()
        self.lhs = lhs
        self.rhs = rhs

    def pretty_str(self):
        return f"({self.lhs.pretty_str()} || {self.rhs.pretty_str()})"

    def __str__(self):
        return f"({self.lhs} || {self.rhs})"

    def __repr__(self):
        return f"Or({self.lhs} || {self.rhs})"

    @property
    def children(self):
        return [self.lhs, self.rhs]


class CompareExpr(BoolExpr):
    def __init__(self, comparison, lhs, rhs):
        super().__init__()
        self.comparison = comparison
        self.lhs = lhs
        self.rhs = rhs

    def pretty_str(self):
        return f"{self.lhs.pretty_str()} {self.comparison} {self.rhs.pretty_str()}"

    def __str__(self):
        return f"{self.lhs} {self.comparison} {self.rhs}"

    def __repr__(self):
        return f"CompareExpr({self.lhs} {self.comparison} {self.rhs})"

    @property
    def children(self):
        return [self.lhs, self.rhs]


class IsIn(BoolExpr):
    def __init__(self, lhs, rhs):
        super().__init__()
        self.lhs = lhs
        self.rhs = rhs

    def pretty_str(self):
        return f"{self.lhs.pretty_str()} in {self.rhs.pretty_str()}"

    def __repr__(self):
        return f"IsIn({self.lhs}, {self.rhs})"

    @property
    def children(self):
        return [self.lhs, self.rhs]


class New(Expr):
    def __init__(self, ty):
        super().__init__(OBJECT_TYPE)

        assert ty is not None
        self.objtype = ty

    def __repr__(self):
        return f"New({self.objtype})"

    @property
    def children(self):
        return [self.objtype]


class IfExpr(Expr):
    "if `cond` { `true_stmts` } [else { `false_stmts` }]"

    def __init__(self, cond, true_stmts, false_stmts=None):
        super().__init__(None)
        assert isinstance(cond, Expr), cond
        # assert isinstance(cond._type(), BoolType), cond
        self.cond = cond
        self.true_stmts = true_stmts
        self.false_stmts = false_stmts

    def __repr__(self):
        return f"IfExpr({self.cond}, {self.true_stmts}, {self.false_stmts})"

    @property
    def children(self):
        return self.true_stmts.statements + (self.false_stmts or [])


class MethodCall(Expr):
    def __init__(self, lhs, rhs, params):
        super().__init__(None)
        self.lhs = lhs
        self.rhs = rhs
        self.params = params

    # def pretty_str(self):
    #     return f"({self.lhs.pretty_str()} && {self.rhs.pretty_str()})"

    def __repr__(self):
        return f"MethodCall({self.lhs}, {self.rhs}, {self.params})"

    @property
    def children(self):
        return self.params or ()
