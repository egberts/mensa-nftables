Trying out a new design

  1 - types
    2 - hooks
      3 - devices
        4 - base chain
          5 - zone
            6 - inter-zone
              7 - rules

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

devices
===
To cut this down further, we have devices (network interfaces); they are nominally 2 to 5, depending on PC platform usage (workstation, router, VMs/containers, data center).


base chain
===
Now hooks must be made, base chains needs declaring.  Some base chains have 'device', prior layer provided this

zone
===
Now, zones can be established.

- a zone may have 1 or more devices
- a device may split into two zones (either overlapping or strict segregated)

inter-zone
===
This pesky zone-to-zone ruleset that I've been chasing.

rules
===
This is the easiest part.  A template rules subdirectory will contain all known rules and place them into their appropriate 3-tuple (family-type-hook) subdirectory.  This 3-tuple is chosen to ensure that a certain rule cannot be used by other 3-tuple.

