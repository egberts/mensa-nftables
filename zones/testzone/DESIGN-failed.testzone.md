Why this 'testzone' directory structure failed.

Using generic names like 'hooks', 'filters', 'family' fails.

No matter the directory hierarchy chosen, generic file names fails.

Because, identifiers (after table/chain/set/map) needs
to be made unique, preferably denoting the actual
4-tuple (family/type/hook/protocol).

I am not confident that 'nft' can handle variable names for an identifier.

But let's try it anyway