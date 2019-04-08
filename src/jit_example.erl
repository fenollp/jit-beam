%% Copyright © 2019 Pierre Fenoll ‹pierrefenoll@gmail.com›
%% See LICENSE for licensing information.
%% -*- coding: utf-8 -*-
-module(jit_example).

-export([fib/1]).

fib(0) -> 1;
fib(1) -> 1;
fib(2) -> 1;
fib(N) when is_integer(N), N > 2 ->
    fib(N-1) + fib(N-2).
