%% Copyright © 2019 Pierre Fenoll ‹pierrefenoll@gmail.com›
%% See LICENSE for licensing information.
%% -*- coding: utf-8 -*-
-module(jit_state).
-behaviour(gen_server).

-include_lib("kernel/include/logger.hrl").

-export([start_link/0]).
-export([maybe_create_then_get_cref/2]).
-export([init/1, terminate/2, code_change/3
        ,handle_info/2, handle_call/3, handle_cast/2
        ]).

-define(COUNTERS_OPTIONS, [write_concurrency]).
-define(TICK, jit_tick).
-define(TICK_MS, timer:seconds(5)).
-record(s, {tick :: timer:tref()
           ,counters = #{} :: #{module() => counters:counters_ref()}
           }).

start_link() ->
    gen_server:start({local,?MODULE}, ?MODULE, [], []).


maybe_create_then_get_cref(Fun, NClauses)
  when is_function(Fun), is_integer(NClauses), NClauses > 0 ->
    {type,external} = erlang:fun_info(Fun, type),
    gen_server:call(?MODULE, {?FUNCTION_NAME,Fun,NClauses}).


init([]) ->
    {ok,Ticker} = timer:send_interval(?TICK_MS, ?MODULE, ?TICK),
    State = #s{tick = Ticker},
    {ok,State}.

code_change(_OldVsn, State, _Extra) -> {ok,State}.

terminate(_Reason, _State) ->
    ?LOG_INFO(#{reason=>_Reason, state=>_State}).


%% TODO: a way to drop crefs (on module unload?)
handle_cast(_Msg, State) ->
    ?LOG_ERROR(#{unhandled=>_Msg}),
    {noreply,State}.


handle_call({maybe_create_then_get_cref,Fun,NClauses}, _From, State=#s{counters = Counters}) ->
    case maps:get(Fun, Counters, nil) of
        nil ->
            CRef = counters:new(NClauses, ?COUNTERS_OPTIONS),
            NewCounters = maps:put(Fun, {NClauses,CRef}, Counters),
            NewState = State#s{counters = NewCounters},
            ?LOG_INFO(#{wrt=>cref, fn=>Fun, status=>created}),
            {reply,CRef,NewState};
        {_NClauses,CRef} ->
            %% Happens when caller process dictionary is pristine
            ?LOG_INFO(#{wrt=>cref, fn=>Fun, status=>read}),
            {reply,CRef,State}
    end;

handle_call(_Msg, _From, State) ->
    ?LOG_ERROR(#{unhandled=>_Msg, from=>_From}),
    {noreply,State}.


handle_info(?TICK, State=#s{counters = Counters}) ->
    _ = [begin
             Counts = [counters:get(CRef,I) || I <- lists:seq(1,NClauses)],
             IsClausesOrderOptimal =
                 %% TODO: trigger recompilation & reloading
                 Counts == lists:reverse(lists:sort(Counts)),
             ?LOG_INFO(#{wrt=>counted, fn=>Fun, data=>Counts
                        ,info=>counters:info(CRef)
                        ,suboptimal=>not IsClausesOrderOptimal})
         end
         || {Fun,{NClauses,CRef}} <- maps:to_list(Counters)
        ],
    {noreply,State};

handle_info(_Msg, State) ->
    ?LOG_ERROR(#{unhandled=>_Msg}),
    {noreply,State}.
