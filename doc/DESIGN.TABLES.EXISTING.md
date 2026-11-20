To verify that such a family/hook exist in kernel, we can later
distinguish two sources of truth:

| Source | Responsibility
|---|---|
| Kernel architecture | Defines legitimate combinations
| Runtime validation | Confirms availability on the target system


Your types/ and hooks/ directories should represent the
kernel architecture, not the currently loaded modules on
one particular machine.

Runtime validation should detect missing kernel
capabilities rather than silently change the
architecture.

One important distinction: regular chains do not have a
chain type or hook. This compatibility matrix concerns
base chains.