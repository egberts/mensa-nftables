
== \*.rule ==
======

<sequence>-<application>-<transport>-<port>-<direction>-<role>-<verdict>.rule

Example:
010-ssh-tcp-022-out-rep-accept.rule

Component	Value	Meaning
Sequence	010	Administrator-assigned rule ordering
Application	ssh	SSH service
Transport	tcp	TCP transport protocol
Port	022	SSH service port
Direction	out	Outbound
Role	rep	Server reply
Verdict	accept	Accept packet


'nft comment'
====
SSH example:
tcp dport 22 counter accept comment "Remote-to-local SSH/TCP/22 request"


The corresponding server reply:
tcp sport 22 counter accept comment "Local-to-remote SSH/TCP/22 reply"


This gives you a compact, consistent vocabulary:
Attribute	Request	Reply
Direction	Remote-to-local	Local-to-remote
Application	SSH	SSH
Transport	TCP	TCP
Port	22	22
Traffic role	Request	Reply

I would use this comment grammar:

<direction> <application>/<transport>/<port> <request-or-reply>

One deliberate choice: omit "Allow" or "Accept" from the comment. The nftables verdict already communicates that. Likewise, input and output are available from the chain hierarchy, but the explicit endpoint direction

File type convention
===

* `.nft` - the standalone `nft` script
* `.table` - table declaration
* `.table_block` - statements for use within a table block (surrounded by curly brace delimiters)
* `.chain` - declaration of a regular chain
* `.base_chain` - declaration of a base chain
* `.rule` - rule statements for use within a chain block
