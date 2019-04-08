%% Copyright © 2019 Pierre Fenoll ‹pierrefenoll@gmail.com›
%% See LICENSE for licensing information.
%% -*- coding: utf-8 -*-
-module(jit_example).

-include_lib("jit/include/jit.hrl").

-export([fib/1]).

fib(0) ->
    ?JIT_INCR(1),
    1;
fib(1) ->
    ?JIT_INCR(2),
    1;
fib(2) ->
    ?JIT_INCR(3),
    1;
fib(N) when is_integer(N), N > 2 ->
    ?JIT_INCR(4),
    fib(N-1) + fib(N-2).
