testing 1, 2, 3

I think I finally perfected the framework of the nft/nftables where it has the following attributes:

* FASTEST (minimal nf_tables kernel IR code)
* PORTABLE, only nft script language
* EXTENSIBLE, by protocol (rename a file to add/disable)
* EXTENSIBLE, by interface (rename a file to add/disable)
* PRIORITIZED correctly


'nft' tool is all you need.

No preprocessor required, no compiler needed, no prompting, no guesswork.


Downside is the rules are infuriatingly oppressive by the virtue of these multipliers:

* in BOTH directions
* for each of 9 Linux network hooks
* for each zone that you set (red, dmz, green; public, dmz, private).
* for each interface
* and for each interface types

And this framework licks them all into a single file for your simple editing.

This requires:

* familiarize of ephemeral port numbering
* corresponding rules to allow reply/responses
* intimacy of all network protocols

This is not a Sniffer that can monitor traffic; only the 'nft' add ruleset approach.

This gets you more than compliance with Common Core, DoD, CISecurity, PMCIA, HIPAA and other common cycbersecurity standards for networked firewall.
