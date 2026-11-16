
Uses a three-level composition model. The file extension defines the syntactic context in which the file's contents are valid.

| Extension | Content scope | Intended execution |
|---|---|---|
| `.rule` | Inside a chain {} block | Included by a chain |
| `.chain` | Inside a table {} block | Included by a table |
| `.nft` |Standalone nftables script | Directly executable |

There are three important consequences:

1. Directory names are organizational, not syntactic. A directory does not establish an nftables parsing context; the file extension does.
2. Include paths are project-root-relative. This gives the entire project a consistent path-resolution convention, independent of the location of the including file.
3. Standalone .nft files are independently testable. Each can be passed directly to nft -f or syntax-checked with nft -c -f.
I would preserve this distinction as a fundamental design rule:

File extension determines inclusion context; directory hierarchy determines functional organization.

That is considerably simpler than trying to make directory nesting dictate nftables syntax.
