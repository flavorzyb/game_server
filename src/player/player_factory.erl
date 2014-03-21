%% The MIT License (MIT)
%%
%% Copyright (c) 2014-2024
%% Savin Max <mafei.198@gmail.com>
%%
%% Permission is hereby granted, free of charge, to any person obtaining a copy
%% of this software and associated documentation files (the "Software"), to deal
%% in the Software without restriction, including without limitation the rights
%% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
%% copies of the Software, and to permit persons to whom the Software is
%% furnished to do so, subject to the following conditions:
%%
%% The above copyright notice and this permission notice shall be included in all
%% copies or substantial portions of the Software.
%%
%% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
%% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
%% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
%% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
%% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
%% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
%% SOFTWARE.


-module(player_factory).

-behaviour(gen_server).

%% API
-export([start_link/0,
         shutdown_players/0,
         start_player/1]).

%% gen_server callbacks
-export([init/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2,
         code_change/3]).

-define(TAB, ?MODULE).
-define(WORKING, 0).
-define(SHUTDOWN, 1).
-define(TERMINATE, 2).


-include("include/gproc_macros.hrl").

-record(state, {status}).

%%%===================================================================
%%% API
%%%===================================================================

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

-spec(start_player(PlayerID::binary()) -> {ok, pid()}).
start_player(PlayerID) ->
    gen_server:call(?MODULE, {start_player, PlayerID}).

shutdown_players() ->
    gen_server:cast(?MODULE, shutdown_players).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

init([]) ->
    {ok, #state{status=?WORKING}}.

handle_call({start_player, PlayerID}, _From, State=#state{status=Status}) ->
    case Status =:= ?WORKING of
        true ->
            Result = case ?GET_PID({player, PlayerID}) of
                undefined ->
                    player_sup:start_child([PlayerID]);
                Pid ->
                    {ok, Pid}
            end,
            {reply, Result, State};
        false ->
            {reply, undefined, State}
    end.

handle_cast(shutdown_players, State) ->
    Children = supervisor:which_children(player_sup),
    start_shutdown_children(Children),
    {noreply, State#state{status=?SHUTDOWN}};
handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info({finished_shutdown, _From}, State=#state{status=?TERMINATE}) ->
    {noreply, State};
handle_info({finished_shutdown, _From}, State=#state{status=?SHUTDOWN}) ->
    NewState = case shutdown_next() of
                   shutdown_finished ->
                       notify_shutdown_finished(),
                       State#state{status=?TERMINATE};
                   _ -> State
               end,
    {noreply, NewState};
handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
shutdown_next() ->
    case get({player, children}) of
        [] -> shutdown_finished;
        [Child|T] ->
            put({player, children}, T),
            shutdown(Child)
    end.

start_shutdown_children([]) -> notify_shutdown_finished();
start_shutdown_children(Children) ->
    CpuAmount = erlang:system_info(schedulers_online),
    shutdown(Children, CpuAmount * 2).

shutdown([], _Amount) ->
    put({player, children}, []);
shutdown(Children, 0) ->
    put({player, children}, Children);
shutdown([Child|Children], Amount) ->
    error_logger:info_msg("Amount: ~p~n", [Amount]),
    shutdown(Child),
    shutdown(Children, Amount - 1).

shutdown(_Child={_Name, Pid, _Type, _Modules}) ->
    Pid ! {shutdown, self()}.

notify_shutdown_finished() ->
    game_server ! {finished_shutdown_players, self()}.
