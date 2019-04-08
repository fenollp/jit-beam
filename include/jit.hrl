%% Copyright © 2019 Pierre Fenoll ‹pierrefenoll@gmail.com›
%% See LICENSE for licensing information.
%% -*- coding: utf-8 -*-
-ifndef(JIT_HRL).
-define(JIT_HRL, true).

-define(JIT_INCR(Ix)
       ,(fun () ->
                 PDKey = jit_cref,
                 Fun = fun ?MODULE:?FUNCTION_NAME/?FUNCTION_ARITY,
                 CRef =
                     case erlang:get(PDKey) of
                         undefined ->
                             CRef = jit_state:maybe_create_then_get_cref(Fun),
                             undefined = erlang:put(PDKey, CRef),
                             CRef;
                         CRef -> CRef
                     end,
                 ok = counters:add(CRef, Ix, 1)
         end)()).

-endif.
