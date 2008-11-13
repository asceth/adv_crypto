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

%% Purpose: Provide cryptographic algorithms.

-module(adv_crypto_server).

-behaviour(gen_server).

-export([start_link/0,client_port/0]).

%% Internal exports, call-back functions.
-export([init/1,handle_call/3,handle_cast/2,handle_info/2,code_change/3,
         terminate/2]).

%%% --------------------------------------------------------
%%% Interface Functions.
%%% --------------------------------------------------------

start_link() ->
  gen_server:start_link({local, adv_crypto_server}, adv_crypto_server, [], []).

init([]) ->
  process_flag(trap_exit, true),
  erl_ddll:start(),
  PrivDir = case code:priv_dir(adv_crypto) of
              {error, bad_name} ->
                Dir = filename:dirname(?FILE),
                filename:join([Dir, "..", "priv"]);
              Path ->
                Path
            end,
  LibDir1 = filename:join([PrivDir, "lib"]),
  LibDir =
    case erl_ddll:load_driver(LibDir1, adv_crypto_drv) of
	    ok -> LibDir1;
	    {error,_} ->
        LibDir2 =
          filename:join(LibDir1,
                        erlang:system_info(system_architecture)),
        erl_ddll:load_driver(LibDir2, adv_crypto_drv),
        LibDir2
    end,
  Cmd = "adv_crypto_drv elibcrypto " ++ filename:join([LibDir, "elibcrypto"]),

  open_ports(Cmd,size(port_names())).

open_ports(_,0) ->
  {ok, []};
open_ports(Cmd,N) ->
  Port = open_port({spawn, Cmd}, []),
  %% check that driver is loaded, linked and working
  %% since adv_crypto_drv links towards libcrypto, this is a good thing
  %% since libcrypto is known to be bad with backwards compatibility
  case catch port_control(Port, 0, []) of
    {'EXIT', _} ->
	    {stop, nodriver};
    _ ->
	    register(element(N,port_names()), Port),
	    open_ports(Cmd,N-1)
  end.

port_names() ->
  { adv_crypto_drv01, adv_crypto_drv02, adv_crypto_drv03, adv_crypto_drv04,
    adv_crypto_drv05, adv_crypto_drv06, adv_crypto_drv07, adv_crypto_drv08,
    adv_crypto_drv09, adv_crypto_drv10, adv_crypto_drv11, adv_crypto_drv12,
    adv_crypto_drv13, adv_crypto_drv14, adv_crypto_drv15, adv_crypto_drv16 }.

client_port() ->
  element(erlang:system_info(scheduler_id) rem size(port_names()) + 1,
          port_names()).


%%% --------------------------------------------------------
%%% The call-back functions.
%%% --------------------------------------------------------

handle_call(_, _, State) ->
  {noreply, State}.

handle_cast(_, State) ->
  {noreply, State}.

handle_info({'EXIT', Pid, _Reason}, State) when is_pid(Pid) ->
  {noreply, State};

handle_info({'EXIT', Port, Reason}, State) when is_port(Port) ->
  {stop, {port_died, Reason}, State};
handle_info(_, State) ->
  {noreply, State}.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

terminate(_Reason, _State) ->
  close_ports(size(port_names())).

close_ports(0) ->
  ok;
close_ports(N) ->
  element(N,port_names()) ! {self(), close},
  close_ports(N-1).


