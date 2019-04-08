%% Copyright © 2019 Pierre Fenoll ‹pierrefenoll@gmail.com›
%% See LICENSE for licensing information.
%% -*- coding: utf-8 -*-
-module(jit_sup).
-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).
-define(WORKER(Name, Mod, Args)
       ,#{id => Name
         ,start => {Mod, start_link, Args}
         ,restart => permanent
         ,shutdown => 5 * 1000
         ,type => worker
         ,modules => [Mod]
         }).

%% API functions

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

init([]) ->
    Children = [?WORKER(jit_state, jit_state, [])
               ],

    SupFlags = #{strategy => one_for_all
                ,intensity => 3
                ,period => 5
                },
    {ok, {SupFlags, Children}}.
