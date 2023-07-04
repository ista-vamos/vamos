from ..ir.expr import Expr


class Constant(Expr):
    def __init__(self, c, ty):
        super().__init__(ty)
        self.value = c

    def pretty_str(self):
        return f"{self.value} : {self.type() or ''}"

    def __str__(self):
        return f"CONST({self.value} : {self.type() or ''})"

    def __repr__(self):
        return f"Constant({self.value} : {self.type() or ''})"

    def __eq__(self, other):
        return self.value == other.value

    @property
    def children(self):
        return ()
