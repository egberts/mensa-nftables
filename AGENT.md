Below is a reorganized, implementation-oriented `AGENT.md`. It preserves your architectural philosophy and design goals while making the document useful as a set of instructions for an AI coding agent working on the project.

I've also clarified the distinction between architectural requirements, implementation conventions, operational behavior, and future TODOs.

Writing

# AGENT.md

# nft-common — Filesystem-Driven nftables Firewall Framework

## 1\. Project Overview

This project implements a modular, filesystem-driven firewall architecture using native Linux `nftables`.

The filesystem represents the firewall policy architecture. `nftables` remains the sole ruleset execution engine.

The fundamental philosophy is:

> The filesystem defines policy composition; nftables defines policy execution.

The `nft` command-line tool is the only required firewall-management interface.

The framework must avoid introducing an additional rule-generation language, compiler, preprocessor, or external firewall-management framework.

### 1.1 Architectural Objectives

The framework is designed around the following objectives:

- **FASTEST:** Minimize generated `nf_tables` kernel intermediate representation (IR) and unnecessary rule evaluation.
- **PORTABLE:** Use native nftables script syntax as the policy language.
- **EXTENSIBLE BY PROTOCOL:** Add or disable protocol-specific policy by creating, deleting, or renaming files.
- **EXTENSIBLE BY INTERFACE:** Add or disable interface-specific policy using the same filesystem operations.
- **CORRECT PRIORITIZATION:** Preserve correct ordering of hooks, chains, rules, and policy evaluation.
- **NO PREPROCESSOR:** Do not introduce a rule-generation preprocessor.
- **NO COMPILER:** Do not introduce a custom policy compiler.
- **NO EXTERNAL FIREWALL FRAMEWORK:** Use nftables directly.
- **STATELESS OR STATEFUL:** Support both stateless policy and connection-tracking-based policy.
- **SHARED REGULAR CHAINS:** Prefer shared regular chains where practical, allowing conntrack to handle reply-direction state automatically.
- **MAP-BASED DISPATCH:** Use nftables `map` and `vmap` for efficient dispatch based on interfaces, Layer 4 protocols, and eventually Layer 7 protocols.

Performance is a primary architectural concern. Avoid unnecessary rules, duplicate expressions, excessive chain traversal, and redundant policy evaluation.

Do not sacrifice correctness or security for marginal performance improvements.

---

## 2\. Core Philosophy

### 2.1 Filesystem as Policy Architecture

The directory hierarchy represents the logical composition of firewall policy.

Top-level directory names represent the binding between:

- Network zone
- Address family
- Chain type
- Netfilter hook
- Layer 4 protocol

The filesystem should make policy organization understandable without requiring a separate configuration language.

Policy activation and deactivation should be controlled through ordinary filesystem operations.

### 2.2 Native nftables Is the Policy Language

All firewall rules must be expressed using native nftables syntax.

The framework must not introduce:

- Custom rule syntax
- Rule-generation preprocessing
- A custom compiler
- An intermediate policy language
- An external firewall-management framework

Shell scripts may assemble, validate, load, or manage nftables scripts, but they must not become an alternative firewall policy language.

### 2.3 Explicit Composition

The architecture uses a three-level composition model:

1. `.rule` files provide rules inside chains.
2. `.chain` files provide chain definitions inside tables.
3. `.nft` files provide standalone nftables scripts.

The file extension determines the syntactic context.

The directory hierarchy determines functional organization.

**Fundamental design rule:**

> File extension determines inclusion context; directory hierarchy determines functional organization.

Directory nesting must never be used to infer nftables parsing context.

---

## 3\. Firewall Policy Composition

### 3.1 File Extensions

| Extension | Content scope | Intended execution |
| --- | --- | --- |
| `.rule` | Inside a `chain {}` block | Included by a chain |
| `.chain` | Inside a `table {}` block | Included by a table |
| `.nft` | Standalone nftables script | Directly executable |

#### `.rule`

Contains nftables statements valid inside an existing chain.

A `.rule` file must not introduce a table or chain declaration.

#### `.chain`

Contains chain definitions valid inside an existing table.

A `.chain` file may define regular chains and base chains as appropriate to its architectural role.

#### `.nft`

Contains a complete, independently executable nftables script.

Standalone scripts must be testable using:

bash

```bash
nft -c -f path/to/file.nft
```

And executable using:

bash

```bash
nft -f path/to/file.nft
```

### 3.2 Include Path Convention

All include paths are project-root-relative.

This convention provides consistent path resolution regardless of the location of the including file.

Do not introduce include paths that depend on the current working directory or the directory containing the included file.

Every include must resolve to an intentional project-root-relative path.

### 3.3 File Activation Model

The filesystem controls policy activation.

| Operation | Result |
| --- | --- |
| Create a `.rule` file | Enable rule |
| Delete a `.rule` file | Disable rule |
| Rename `.rule` to `.disabled` | Disable rule |
| Rename `.disabled` to `.rule` | Enable rule |
| Create another matching file | Extend ruleset |

The same activation principle should apply to other composable policy files where appropriate.

The build and loading process must include only files with recognized active extensions.

Disabled files must never be included accidentally.

---

## 4\. Firewall Architecture

### 4.1 Network Zones

The framework must support an arbitrary number of network zones.

Example zone models include:

- `red`, `dmz`, `green`
- `public`, `dmz`, `private`
- Other administrator-defined zone names

Zones represent logical network trust boundaries.

Zone definitions must not be hardcoded into the policy engine.

The filesystem should make it possible to extend the architecture by introducing additional zone-specific policy.

### 4.2 Network Interfaces

Interfaces are associated with logical zones.

Interface-specific policy must be independently extensible.

Adding or disabling an interface binding should require filesystem changes rather than modifications to a central rule-generation program.

Use nftables maps or verdict maps where appropriate to dispatch traffic based on interface identity.

### 4.3 Address Families

The architecture must accommodate:

- `ip`
- `ip6`
- `inet`
- `arp`
- `bridge`
- `netdev`

Each family must use only the chain types, hooks, and expressions supported by that family.

Do not assume that all families support identical hooks or protocol expressions.

### 4.4 Chain Types and Hooks

Chain type and hook selection must be explicit.

The architecture must account for all applicable Netfilter hooks:

- prerouting
- input
- forward
- output
- postrouting
- ingress
- egress, where supported

Hook availability depends on the relevant address family and chain type.

Priority values must be selected deliberately, taking into account:

- Kernel processing order
- Conntrack attachment
- NAT processing
- Packet mangling
- Routing decisions
- Other registered Netfilter operations

Never assume that a hook name alone determines execution order.

### 4.5 Protocol Dispatch

Protocol-specific policy should be separated into independently manageable files.

Layer 4 dispatch should use native nftables maps or verdict maps wherever this reduces unnecessary rule evaluation.

Initial protocol support includes:

- TCP
- UDP
- ICMP
- ICMPv6
- IGMP

Additional protocols should be supported through the same filesystem composition model.

Layer 7 protocol dispatch is a future enhancement.

Do not implement Layer 7 classification by assuming that nftables maps can identify application protocols without an appropriate classification mechanism.

---

## 5\. Connection Tracking and Directionality

### 5.1 Stateful and Stateless Policy

The framework must support two policy models:

**Stateless policy**

Explicitly evaluates packets in both directions.

The administrator is responsible for defining the corresponding rules required for request and response traffic.

**Stateful policy**

Uses conntrack to recognize established connections and their reply direction.

Where appropriate, use a shared regular chain to avoid duplicating equivalent policy for both directions.

### 5.2 Reply-Direction Handling

Connection tracking should handle the reply direction automatically where the policy model permits it.

Use connection states deliberately.

Typical conntrack states include:

- `new`
- `established`
- `related`
- `invalid`
- `untracked`

Do not assume that conntrack automatically permits all reply traffic.

The firewall must explicitly define which states are accepted and under which conditions.

### 5.3 Ephemeral Ports

Correct policy design requires familiarity with ephemeral port allocation.

For TCP and UDP, distinguish between:

- Client source ports
- Server destination ports
- Server source ports in responses
- Client destination ports in responses

Do not write response rules based on arbitrary assumptions about ephemeral port ranges.

Use conntrack state and connection direction when possible instead of duplicating fragile port-range rules.

Any explicitly configured ephemeral port range must reflect the actual operating-system configuration and application requirements.

---

## 6\. Performance and Rule Evaluation

Performance is a core design requirement.

The architecture aims to minimize:

- Number of generated nftables expressions
- Number of rules evaluated per packet
- Duplicate rule definitions
- Unnecessary chain traversal
- Repeated protocol matching
- Redundant interface matching
- Unnecessary branching

### 6.1 Map-Based Dispatch

Use `map` and `vmap` for efficient classification and dispatch.

Intended dispatch dimensions include:

- Network interfaces
- Layer 4 protocols
- Zone membership
- Zone-to-zone relationships
- Future Layer 7 classifications

Prefer a single classification or dispatch operation over repeatedly evaluating equivalent conditions across many rules.

However, validate that the selected map design is compatible with the required nftables data types and verdict semantics.

### 6.2 Shared Regular Chains

Shared regular chains should reduce duplication.

Common policy should be defined once and reached through explicit dispatch rather than copied into every interface-specific or protocol-specific chain.

### 6.3 Minimal Kernel Ruleset

The framework should produce the smallest practical ruleset while retaining:

- Correct hook priorities
- Correct connection tracking
- Correct packet directionality
- Correct zone isolation
- Explicit default-deny behavior where required
- Predictable policy ordering

Measure performance rather than assuming that fewer source files or fewer lines automatically produce a faster kernel ruleset.

---

## 7\. Complexity and Policy Coverage

The framework addresses the combinatorial complexity of firewall policy.

Policy requirements can multiply across:

- Both traffic directions
- All applicable Netfilter hooks
- An arbitrary number of zones
- All configured network interfaces
- Different interface types
- Address families
- Layer 4 protocols
- Chain types and priorities

The architecture consolidates these dimensions into a filesystem-driven composition model.

The goal is to make an otherwise overwhelming policy matrix manageable through a consistent collection of independently editable files.

Administrators should be able to modify a specific policy without manually editing a monolithic firewall ruleset.

---

## 8\. Limitations and Operational Boundaries

This framework is an nftables ruleset management approach.

It is not a packet sniffer.

It does not provide:

- Passive packet capture
- Network traffic monitoring
- Protocol inspection independent of firewall evaluation
- Automatic application discovery
- Automatic policy generation
- Automatic security compliance certification

The framework installs and evaluates firewall rules through nftables.

It should not be represented as a replacement for IDS, IPS, network monitoring, or packet-analysis systems.

### 8.1 Protocol Knowledge

Correct firewall policy requires understanding the protocols being filtered.

In particular, developers and administrators must understand:

- Protocol directionality
- Connection establishment
- Response traffic
- Ephemeral ports
- Related connections
- Fragmentation
- ICMP and ICMPv6 behavior
- NAT interactions
- Routing behavior
- Conntrack state transitions

Do not assume that a rule permitting a request automatically permits its response unless the connection-tracking policy explicitly accounts for it.

---

## 9\. Directory Hierarchy

The project uses the following initial directory architecture.

text

```text
.
├── build/
├── distro/
├── doc/
├── Makefile
├── src/
│   ├── family/
│   ├── type/
│   ├── filter/
│   ├── hook/
│   ├── bindings/
│   │   ├── zone/
│   │   ├── interface/
│   │   └── zone-to-zone/
│   └── template-rules/
│       ├── arp-filter-input/
│       ├── arp-filter-output/
│       ├── bridge-filter-forward/
│       ├── bridge-filter-input/
│       ├── bridge-filter-output/
│       ├── bridge-filter-postrouting/
│       ├── bridge-filter-prerouting/
│       ├── inet-filter-forward-icmp/
│       ├── inet-filter-forward-igmp/
│       ├── inet-filter-forward-tcp/
│       ├── inet-filter-forward-udp/
│       ├── inet-filter-ingress/
│       ├── inet-filter-input-icmp/
│       ├── inet-filter-input-igmp/
│       ├── inet-filter-input-tcp/
│       ├── inet-filter-input-udp/
│       ├── inet-filter-output-icmp/
│       ├── inet-filter-output_raw-udp/
│       ├── inet-filter-output-tcp/
│       ├── inet-filter-output-udp/
│       ├── inet-filter-postrouting/
│       ├── inet-filter-prerouting_raw-udp/
│       ├── inet-filter-prerouting-tcp/
│       ├── inet-filter-prerouting-udp/
│       ├── inet-nat-input/
│       ├── inet-nat-output/
│       ├── inet-nat-postrouting/
│       ├── inet-nat-prerouting/
│       ├── inet-route-output/
│       ├── ip6-filter-forward/
│       ├── ip6-filter-input-icmp/
│       ├── ip6-filter-input-igmp/
│       ├── ip6-filter-input-tcp/
│       ├── ip6-filter-input-udp/
│       ├── ip6-filter-output-icmp/
│       ├── ip6-filter-output_raw-udp/
│       ├── ip6-filter-output-tcp/
│       ├── ip6-filter-output-udp/
│       ├── ip6-filter-postrouting/
│       ├── ip6-filter-prerouting_raw-udp/
│       ├── ip6-filter-prerouting-tcp/
│       ├── ip6-filter-prerouting-udp/
│       ├── ip6-nat-input/
│       ├── ip6-nat-output/
│       ├── ip6-nat-postrouting/
│       ├── ip6-nat-prerouting/
│       ├── ip6-route-output/
│       ├── ip-filter-forward/
│       ├── ip-filter-input-icmp/
│       ├── ip-filter-input-igmp/
│       ├── ip-filter-input-tcp/
│       ├── ip-filter-input-udp/
│       ├── ip-filter-output-icmp/
│       ├── ip-filter-output_raw-udp/
│       ├── ip-filter-output-tcp/
│       ├── ip-filter-postrouting/
│       ├── ip-filter-prerouting_raw-udp/
│       ├── ip-filter-prerouting-tcp/
│       ├── ip-filter-prerouting-udp/
│       ├── ip-nat-input/
│       ├── ip-nat-output/
│       ├── ip-nat-postrouting/
│       ├── ip-nat-prerouting/
│       ├── ip-route-output/
│       ├── netdev-filter-egress/
│       └── netdev-filter-ingress/
└── tools/
```

The listed directories represent the initial policy organization.

Do not assume that every directory must contain an active policy file.

Only applicable and intentionally enabled policy should be composed into the resulting ruleset.

---

## 10\. Configuration Tool (TODO)

A configuration utility is planned:

text

```text
nft-common-configure.sh
```

Its primary responsibility is to create:

text

```text
nft-common.sh
```

The configuration utility should establish the filesystem bindings and configuration required by the framework.

### 10.1 Design Constraints

The configuration utility must:

- Respect the filesystem-driven architecture.
- Avoid introducing another firewall policy language.
- Avoid compiling or translating policy rules.
- Preserve native nftables syntax.
- Support administrator-defined zones.
- Support administrator-defined interfaces.
- Respect file activation and deactivation conventions.
- Generate predictable configuration.
- Avoid silently overwriting administrator changes.

The generated shell script should orchestrate ruleset assembly, validation, and loading rather than implement firewall policy logic.

---

## 11\. Development Guidelines for AI Agents

When modifying this repository, follow these requirements.

### 11.1 Preserve the Architecture

Do not redesign the project around:

- A centralized firewall configuration database
- YAML or JSON policy descriptions
- A custom rule-generation language
- A custom compiler
- An external firewall-management framework
- A large monolithic ruleset

The filesystem and native nftables scripts are the architecture.

### 11.2 Prefer Native nftables

Before implementing custom logic, determine whether nftables already provides the required functionality through:

- Sets
- Maps
- Verdict maps
- Concatenations
- Named counters
- Regular chains
- Conntrack expressions
- Native include directives

Prefer native functionality.

### 11.3 Preserve File Semantics

Never mix syntactic contexts.

- `.rule` files contain chain-level statements.
- `.chain` files contain table-level chain definitions.
- `.nft` files are standalone nftables scripts.

Do not use directory nesting to determine parsing context.

### 11.4 Preserve Activation Semantics

Never load `.disabled` files as active policy.

Adding or removing a matching policy file must have the expected effect on the resulting ruleset.

Do not require a custom compiler or database update just to enable or disable an individual rule.

### 11.5 Validate Changes

Before considering an implementation complete:

1. Check the syntax of affected standalone nftables scripts.
2. Validate the complete assembled ruleset.
3. Verify include-path resolution.
4. Verify active and disabled file selection.
5. Verify chain types and hook compatibility.
6. Verify hook priorities.
7. Verify conntrack behavior.
8. Verify request and reply traffic.
9. Check for duplicate or unreachable rules.
10. Review the resulting ruleset for unnecessary expressions and chain traversal.

Use syntax-only validation where possible:

bash

```bash
nft -c -f ruleset.nft
```

Do not apply firewall changes to a production system as part of ordinary development testing.

Prefer isolated network namespaces, virtual machines, or dedicated test environments.

### 11.6 Security Requirements

Firewall changes must be treated as security-sensitive.

- Preserve default-deny behavior where required.
- Do not introduce implicit broad ACCEPT rules.
- Do not bypass zone isolation.
- Do not assume conntrack state alone is sufficient authorization.
- Do not accidentally expose management interfaces.
- Do not change hook priorities without understanding their consequences.
- Do not silently discard unsupported protocols.
- Do not introduce policy changes that weaken existing behavior without explicitly documenting them.

### 11.7 Documentation

When introducing a new policy category or changing composition behavior, update the relevant documentation.

Document:

- Its directory location
- Its file extension
- Its inclusion context
- Its activation semantics
- Its expected packet-processing behavior
- Any hook or priority dependencies

---

## 12\. Future Work

The following items are planned but not yet implemented or finalized.

| Item | Description | Status |
| --- | --- | --- |
| Configuration utility | Implement `nft-common-configure.sh` | TODO |
| Generated orchestrator | Generate `nft-common.sh` | TODO |
| Layer 7 dispatch | Investigate application-protocol classification integration | TODO |
| Performance analysis | Measure resulting kernel ruleset and packet evaluation cost | TODO |
| Test infrastructure | Build isolated nftables validation and integration tests | TODO |
| Documentation | Complete protocol and hook reference documentation | TODO |

---

## 13\. Guiding Principle

The ultimate objective is to make complex firewall policy manageable without making the firewall implementation complex.

The filesystem provides modularity.

Native nftables provides execution.

Maps and verdict maps provide efficient dispatch.

Conntrack provides connection-state awareness.

Regular chains provide policy reuse.

File extensions provide explicit composition semantics.

No custom compiler, preprocessor, or external firewall-management framework is necessary.

**The filesystem is the policy architecture. nftables is the firewall engine. The****`nft`****tool is the interface.**

## Important architectural points preserved

I made a few deliberate clarifications while rewriting:

1. Nine hooks: The framework should account for all applicable hooks, rather than assume every family supports all nine. Hook availability depends on the family and chain type.
2. Conntrack: Conntrack recognizes reply traffic, but does not automatically authorize it. The ruleset still needs explicit state-acceptance policy.
3. Layer 7: This remains a TODO because nftables maps alone do not perform application-layer protocol identification.
4. Performance: Minimal kernel IR is retained as a goal, but actual performance should be validated against the resulting ruleset.
5. File composition: The `.rule`, `.chain`, and `.nft` distinctions are treated as architectural invariants, not merely organizational preferences.


Writing

---

## 14\. `.rule` File Naming Convention

Every `.rule` file must follow a consistent, machine-readable naming convention:

text

```text
<sequence>-<application>-<transport>-<port>-<direction>-<role>-<verdict>.rule
```

### 14.1 Filename Components

Example:

text

```text
010-ssh-tcp-022-out-rep-accept.rule
```

| Component | Value | Meaning |
| --- | --- | --- |
| Sequence | `010` | Administrator-assigned rule ordering |
| Application | `ssh` | SSH application/service |
| Transport | `tcp` | TCP transport protocol |
| Port | `022` | SSH service port |
| Direction | `out` | Outbound traffic |
| Role | `rep` | Server reply |
| Verdict | `accept` | Accept packet |

The filename provides a compact description of the rule's intent without requiring the administrator to inspect its contents.

### 14.2 Sequence Number

The sequence number determines administrator-assigned ordering within the applicable policy context.

Use zero-padded numeric values to preserve predictable lexical ordering.

Examples:

text

```text
010-ssh-tcp-022-in-req-accept.rule
020-ssh-tcp-022-out-rep-accept.rule
030-http-tcp-080-in-req-accept.rule
040-http-tcp-080-out-rep-accept.rule
```

Sequence numbers must not be interpreted as nftables hook priorities. They determine policy-file ordering within the composition architecture.

### 14.3 Direction and Traffic Role

Direction and role are independent attributes.

| Attribute | Request | Reply |
| --- | --- | --- |
| Direction | `in` | `out` |
| Role | `req` | `rep` |
| Traffic direction | Remote-to-local | Local-to-remote |

For the purposes of this naming convention:

- `in` means traffic traveling from the remote endpoint toward the local endpoint.
- `out` means traffic traveling from the local endpoint toward the remote endpoint.
- `req` identifies request or initiating traffic.
- `rep` identifies corresponding response traffic.

These values describe the policy's endpoint perspective, not necessarily the Netfilter hook.

### 14.4 Verdict

The verdict identifies the intended nftables rule outcome.

Use native nftables verdict terminology, including:

- `accept`
- `drop`
- `reject`

Do not introduce custom verdict names when nftables already provides the required semantics.

---

## 15\. nftables Rule Comments

Every actionable `.rule` statement should include an informative nftables comment.

Comments must describe the traffic being matched, using a consistent vocabulary.

### 15.1 SSH Example

Remote-to-local SSH request:

nft

```nft
tcp dport 22 counter accept comment "Remote-to-local SSH/TCP/22 request"
```

Corresponding local-to-remote SSH reply:

nft

```nft
tcp sport 22 counter accept comment "Local-to-remote SSH/TCP/22 reply"
```

### 15.2 Comment Grammar

Use the following comment structure:

text

```text
<direction> <application>/<transport>/<port> <request-or-reply>
```

Examples:

text

```text
Remote-to-local SSH/TCP/22 request
Local-to-remote SSH/TCP/22 reply
Remote-to-local HTTP/TCP/80 request
Local-to-remote HTTP/TCP/80 reply
```

### 15.3 Commenting Principles

Follow these conventions:

1. Describe traffic direction explicitly.
2. Identify the application or service.
3. Identify the transport protocol.
4. Identify the relevant service port.
5. Identify whether the traffic is a request or reply.
6. Keep comments concise and consistent.
7. Do not duplicate information unnecessarily.

**Do not include****`Allow`****or****`Accept`****in the comment.** The nftables verdict already communicates the action.

Likewise, do not substitute `input` or `output` for endpoint direction. Hook and chain context already provide the Netfilter processing location.

The comment should explain what the packet represents, not repeat the syntax of the rule.

### 15.4 Naming and Comment Consistency

The filename, nftables expression, and comment must describe the same policy.

For example:

| Attribute | Request | Reply |
| --- | --- | --- |
| Filename direction | `in` | `out` |
| Filename role | `req` | `rep` |
| Application | `ssh` | `ssh` |
| Transport | `tcp` | `tcp` |
| Port | `022` | `022` |
| Comment direction | Remote-to-local | Local-to-remote |
| Comment role | Request | Reply |

Do not allow filenames and comments to contradict the actual packet match.

The port field in the filename identifies the application service port. It does not necessarily identify the packet's source or destination port.

For example:

- A request commonly matches `tcp dport 22`.
- A reply commonly matches `tcp sport 22`.

The actual nftables expression must reflect the direction and connection model being implemented.

### 15.5 Guiding Principle

The filename identifies the policy.

The nftables expression implements the policy.

The comment explains the traffic.

All three must remain consistent.
