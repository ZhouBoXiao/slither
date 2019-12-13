
from .variable_declaration import VariableDeclarationSolc
from slither.core.variables.state_variable import StateVariable

class StateVariableSolc(VariableDeclarationSolc, StateVariable):
    def __str__(self):
        res = '{0} {1};'.format(self.type, self.name)
        return res
