import sys
from slither.slither import Slither

if len(sys.argv) != 2:
    print('python functions_called.py functions_called.sol')
    exit(-1)

# Init slither
slither = Slither(sys.argv[1])

# Get the contract
# contract = slither.get_contract_from_name('Locker')
# print(contract)
print('\n'.join(map(lambda x: str(x), slither.pragma_directives)))
for contract in slither.contracts:
    print (str(contract) + '\n')

for function in contract.functions:
    # print(function.is_compact_ast())

    function.analyze_content()
    function.analyze_params()

# Get the variable
# entry_point = contract.get_function_from_signature('entry_point()')
#
# all_calls = entry_point.all_internal_calls()
#
# all_calls_formated = [f.canonical_name for f in all_calls]

# Print the result
# print('From entry_point the functions reached are {}'.format(all_calls_formated))
