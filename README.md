
I think I finally perfected the framework of the nft/nftables where it has the following attributes:

* FASTEST (minimal nf_tables kernel IR code)
* PORTABLE, only nft script language
* EXTENSIBLE, by protocol (rename a file to add/disable)
* EXTENSIBLE, by interface (rename a file to add/disable)
* PRIORITIZED correctly
* no rule-generation preprocessor
* no compiler, and
* no external firewall-management framework.
* state-less policy or connection tracking
* shared regular chain, with conntrack handling the reply direction automatically.
* dispatch lookup using `map`/`vmap` for interfaces, layer 4 protocols, and (TODO layer 7 protocols).

Philosophy
====

The filesystem represents the policy architecture; `nftables` remains the execution engine.

'nft' tool is all you need.

And top-level directory name represent the binding between zone, family, chain type, chain hook, and layer-4 protocol.




Downside is the rules are infuriatingly oppressive by the virtue of these multipliers:

* in BOTH directions
* for each of 9 Linux network hooks
* for ant number of zones that you set (red, dmz, green; public, dmz, private).
* for any and all interfaces
* and for each interface types

And this framework licks them all into a single file for your simple editing.

This requires:

* familiarize of ephemeral port numbering
* corresponding rules to allow reply/responses
* intimacy of all network protocols

This is not a Sniffer that can monitor traffic; only the 'nft' add ruleset approach.

This gets you more than compliance with Common Core, DoD, CISecurity, PMCIA, HIPAA and other common cycbersecurity standards for networked firewall.

Configuration Tool (TODO)
====
Need a `nft-common-configure.sh` to create the `nft-common.sh`

Tweaking rules
====
This gives you the desired activation model:

Operation	Result

* Create .rule file	Enable rule
* Delete .rule file	Disable rule
* Rename .rule to .disabled	Disable rule
* Rename .disabled to .rule	Enable rule
* Create another matching file	Extend ruleset

