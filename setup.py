from setuptools import setup, find_packages

setup(
    name='slither-analyzer',
    description='Slither is a Solidity static analysis framework written in Python 3.',
    url='https://github.com/crytic/slither',
    author='Trail of Bits',
    version='0.6.7',
    packages=find_packages(),
    python_requires='>=3.6',
    install_requires=['prettytable>=0.7.2',
                      'pysha3>=1.0.2',
                      'crytic-compile>=0.1.4'],
#    dependency_links=['git+https://github.com/crytic/crytic-compile.git@master#egg=crytic-compile'],
    license='AGPL-3.0',
    long_description=open('README.md').read(),
    entry_points={
        'console_scripts': [
            'slither = slither.__main__:main',
            'slither-check-upgradeability = slither.tools.upgradeability.__main__:main',
            'slither-find-paths = slither.tools.possible_paths.__main__:main',
            'slither-simil = slither.tools.similarity.__main__:main',
            'slither-flat = slither.tools.flattening.__main__:main',
            'slither-format = slither.tools.slither_format.__main__:main'
        ]
    }
)
