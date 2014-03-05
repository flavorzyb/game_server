%%%===================================================================
%%% Generated by generate_api.rb 2014-03-05 15:28:52 +0800
%%%===================================================================
-module(api_decoder).
-export([decode/1, decode_protocol/2]).
-include("include/protocol.hrl").

decode(<<ProtocolId:?SHORT, Data/binary>>) ->
    ProtocolName = api_protocol:protocol_name(ProtocolId),
    decode_protocol(ProtocolName, Data).

decode_protocol(town, Bin0) ->
    {Name, Bin1} = utils_protocol:decode_string(Bin0),
    {PositionX, Bin2} = utils_protocol:decode_integer(Bin1),
    {PositionY, Bin3} = utils_protocol:decode_integer(Bin2),
    {UserId, Bin4} = utils_protocol:decode_string(Bin3),
    {[{name, Name}, {position_x, PositionX}, {position_y, PositionY}, {user_id, UserId}], Bin4};
decode_protocol(building, Bin0) ->
    {Name, Bin1} = utils_protocol:decode_string(Bin0),
    {Position, Bin2} = utils_protocol:decode_integer(Bin1),
    {[{name, Name}, {position, Position}], Bin2};
decode_protocol(user, Bin0) ->
    {Uuid, Bin1} = utils_protocol:decode_string(Bin0),
    {Udid, Bin2} = utils_protocol:decode_string(Bin1),
    {Name, Bin3} = utils_protocol:decode_string(Bin2),
    {Gem, Bin4} = utils_protocol:decode_integer(Bin3),
    {Paid, Bin5} = utils_protocol:decode_float(Bin4),
    {Building, Bin6} = api_decoder:decode_protocol(building, Bin5),
    {Towns, Bin7} = utils_protocol:decode_array(Bin6, fun(Data) -> api_decoder:decode_protocol(town, Data) end),
    {Team, Bin8} = utils_protocol:decode_array(Bin7, fun(Data) -> utils_protocol:decode_integer(Data) end),
    {[{uuid, Uuid}, {udid, Udid}, {name, Name}, {gem, Gem}, {paid, Paid}, {building, Building}, {towns, Towns}, {team, Team}], Bin8};
decode_protocol(login_params, Bin0) ->
    {Udid, Bin1} = utils_protocol:decode_string(Bin0),
    {[{udid, Udid}], Bin1};
decode_protocol(public_info_params, Bin0) ->
    {UserId, Bin1} = utils_protocol:decode_string(Bin0),
    {[{user_id, UserId}], Bin1}.
