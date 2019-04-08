# jit

Full-Erlang JIT for BEAM languages

## Build

```
rebar3 compile
```

## Hack

```
# Is jit_example:fib/1 clauses ordering optimal?
rebar3 shell
1> jit_example:fib(12).
... wrt=cref status=created fn="fun jit_example:fib/1"
144
... wrt=counted suboptimal=true info_size=4 info_memory=352 fn="fun jit_example:fib/1" data=[0,55,89,143]
```

## What this does

1. reorder clauses based on usage frequency
