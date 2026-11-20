DESIGN of src/ subdirectories

  1 - types
  2 - hooks
  3 - bindings
  4 - template-rules

types
===
Family/type is the simplest combo.

By using the simpliest combo family\_spec and base chain types; we have 6 families and 3 chain types; but only 12 valid combos.

This is chosen to provide easier editing of rules per directory; you think protocol, zone/interface.

Majority of rule efforts would be focused on the 'filter' type and 'inet' family combo ... or 'inet-filter'.

hooks
===
Next is to narrow down the combos is the hooks; of the 7 hooks:

 - ingress
 - prerouting
 - input
 - forward
 - output
 - postrouting
 - egress

But there are only 41 valid combos.  Most common is inet-filter-input and inet-filter-output.

template-rules
===
This is the easiest part.  A template rules subdirectory will contain all known rules and place them into their appropriate 3-tuple (family-type-hook) subdirectory.  This 3-tuple is chosen to ensure that a certain rule cannot be used by other 3-tuple.

