from slither.core.source_mapping.source_mapping import SourceMapping
from slither.core.children.child_contract import ChildContract


class Enum(ChildContract, SourceMapping):
    def __init__(self, name, canonical_name, values):
        self._name = name
        self._canonical_name = canonical_name
        self._values = values

    @property
    def canonical_name(self):
        return self._canonical_name

    @property
    def name(self):
        return self._name

    @property
    def values(self):
        return self._values

    def is_declared_by(self, contract):
        """
        Check if the element is declared by the contract
        :param contract:
        :return:
        """
        return self.contract == contract

    def __str__(self):
        # return self.name
        return "enum %s { %s }\n" % (self.name, ",".join(map(lambda x: x, self.values)))
