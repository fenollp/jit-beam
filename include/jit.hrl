%% Copyright © 2019 Pierre Fenoll ‹pierrefenoll@gmail.com›
%% See LICENSE for licensing information.
%% -*- coding: utf-8 -*-
-ifndef(JIT_HRL).
-define(JIT_HRL, true).

-define(JIT_INCR(NClauses, Ix)
       ,(fun () ->
                 PDKey = jit_cref,
                 Fun = fun ?MODULE:?FUNCTION_NAME/?FUNCTION_ARITY,
                 CRef =
                     case erlang:get(PDKey) of
                         undefined ->
                             C = jit_state:maybe_create_then_get_cref(Fun, NClauses),
                             undefined = erlang:put(PDKey, C),
                             C;
                         C -> C
                     end,
                 ok = counters:add(CRef, Ix, 1)
         end)()).

-endif.
