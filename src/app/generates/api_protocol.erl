%%%===================================================================
%%% Generated by generate_api.rb 2014-03-07 10:38:59 +0800
%%%===================================================================
-module(api_protocol).
-export([protocol_id/1, protocol_name/1]).

-define(NAME_MAPPED, [{town, 0},
                      {building, 1},
                      {user, 2},
                      {login_params, 3},
                      {public_info_params, 4}]).

-define(ID_MAPPED, [{0, town},
                    {1, building},
                    {2, user},
                    {3, login_params},
                    {4, public_info_params}]).

protocol_id(Name) -> 
    proplists:get_value(Name, ?NAME_MAPPED).

protocol_name(Id) -> 
    proplists:get_value(Id, ?ID_MAPPED).
