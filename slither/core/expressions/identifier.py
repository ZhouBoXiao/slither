from slither.core.expressions.expression_typed import ExpressionTyped


class Identifier(ExpressionTyped):

    def __init__(self, value):
        super(Identifier, self).__init__()
        self._value = value

    @property
    def value(self):
        return self._value

    def __str__(self):
        if type(self._value).__name__ == 'SolidityFunction':
            return str(self._value)
        return str(self._value.name)
