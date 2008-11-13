%% ``The contents of this file are subject to the Erlang Public License,
%% Version 1.1, (the "License"); you may not use this file except in
%% compliance with the License. You should have received a copy of the
%% Erlang Public License along with this software. If not, it can be
%% retrieved via the world wide web at http://www.erlang.org/.
%%
%% Software distributed under the License is distributed on an "AS IS"
%% basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
%% the License for the specific language governing rights and limitations
%% under the License.
%%
%% The Initial Developer of the Original Code is Ericsson Utvecklings AB.
%% Portions created by Ericsson are Copyright 1999, Ericsson Utvecklings
%% AB. All Rights Reserved.''
%%
%%     $Id$
%%

%% Purpose: Main supervisor in CRYPTO application.

-module(adv_crypto_sup).

-behaviour(supervisor).

-export([start_link/0, init/1]).

start_link() ->
    supervisor:start_link({local, adv_crypto_sup}, adv_crypto_sup, []).


%% init([])
%% Returns: {ok,  {SupFlags,  [ChildSpec]}}
%%
init([]) ->
    Child = {adv_crypto_server, {adv_crypto_server, start_link, []},
	      permanent, 2000, worker, [adv_crypto_server]},
    {ok, {{one_for_all, 10, 3600}, [Child]}}.

