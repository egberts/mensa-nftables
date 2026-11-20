Zone-to-Device

The simplest mapping of the M:N zones/devices; the zone has parental scope.

Called by 3-bindings/zones/zones-<family>-<type>-<hook>.table_block file.
Calls: 3-binding/zones/*/<family>-<type>-<hook>.table_block

Fans out to devices for each zones.

This is the part where multiple base chains may attach to the same hook; 
this is the part that is unavoidable, despite mensa-nftables design
attempt to maintain a singular base chain per hook.

