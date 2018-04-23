%%%-------------------------------------------------------------------
%%% @author tkarkocha
%%% @copyright (C) 2018, <COMPANY>
%%% @doc Module to monitor the pollution of air. Struct to store date is:
%%% #{ {StationName, {Xcord, Ycord}} => #{ {Date, Type} => Value } }
%%% Date = {Y, M, D, H}
%%%
%%% @end
%%% Created : 22. kwi 2018 23:13
%%%-------------------------------------------------------------------
-module(pollution).
-author("tkarkocha").

%% API
-export([createMonitor/0, addStation/3, addValue/5, removeValue/4, getOneValue/4]).
-export([getStationMean/3, getDailyMean/3]).


-define(DATE, {{Year, Month, Day}, {Hour, _, _}}).

%% @doc Function to create a monitor which will
%% monitor the pollution stations
createMonitor() ->
  #{}.

%% @doc Function to add new station.
%% @param
addStation(StationName, {X, Y}, M) ->
  case checkKey(maps:keys(M), StationName, {X, Y}) of
    true -> io:format("This station already exists!~n"), M;
    false -> M#{{StationName, {X,Y}} => #{}}
  end.

%% @doc Function to add new reading to monitor
addValue(Id, ?DATE, Type, Value, M) ->
  FullId = retFullId(Id, M),
  Date = {Year, Month, Day, Hour},
  case checkKey(maps:keys(M), Id) and                         %if exits this station
       ( not checkKey(maps:keys(maps:get(FullId, M)), {Date, Type}) ) of
    false -> io:format("This record cant be added"), M;
    true  -> M#{ FullId => maps:put({Date, Type}, Value, maps:get(FullId, M)) }
  end.

%% @doc Function to remove an existing reading from monitor.
removeValue(Id, ?DATE, Type, M) ->
  Date = {Year, Month, Day, Hour},
  FullId = retFullId(Id, M),
  M#{ FullId => maps:remove({Date, Type}, maps:get(FullId, M)) }.

%% @doc Function to get value of certain reading
getOneValue(Id, ?DATE, Type, M) ->
  Date = {Year, Month, Day, Hour},
  FullId = retFullId(Id, M),
  maps:get({Date, Type}, maps:get(FullId, M)).

%% @doc Function to return the average value
getStationMean(Id, Type, M) ->
  FullId = retFullId(Id, M),
  {Sum, I, _} = maps:fold(fun valuesFun/3, {0, 0, Type}, maps:get(FullId, M)),
  Sum / I.

valuesFun({_, Type}, V, {Acc, I, PrimType}) when Type == PrimType ->
  {Acc + V, I + 1, PrimType};

valuesFun(_, _, {Acc, I, PrimType}) -> {Acc, I, PrimType}.

%% @doc Function which returns the average
getDailyMean(Type, Day, M) ->
  {Sum, I, _} = maps:fold(fun dailyMean/3, {0, 0, {Day, Type}}, M),
  Sum / I.

dailyMean({{_,_,D,_}, Type}, V, {Acc, I, {Day, Type_}})
  when (D == Day) and (Type == Type_) ->
  {Acc + V, I + 1, {Day, Type_}};

dailyMean(_, V, {Acc, I, W}) when is_map(V) ->
  maps:fold(fun dailyMean/3, {Acc, I, W}, V);

dailyMean(_, _, {Acc, I, W}) -> {Acc, I, W}.


%% =================================================== %%
retFullId(Name, M) when is_map(M) -> retFullId(Name, maps:keys(M));

retFullId(Name, [{N, C} | T]) when Name == N -> {N, C};

retFullId(Coord, [{N, C} | T]) when Coord == C -> {N, C};

retFullId(Name, [H | T]) -> retFullId(Name, T);

retFullId(_, []) -> error("Not like this").


%% @doc Helper function to find out if the Name and coords
%% are already in our Monitor.
%% Returns: true if is, false if isn't
checkKey([], _, _) ->
  false;

%% @todo change the names of params
checkKey([{N, Coords} | T], SN, C) when (N == SN) or (Coords == C) ->
  true;

checkKey([H | T], SN, C) ->
  false orelse checkKey(T, SN, C).

% Function checkKey for two args
checkKey([], _) ->
  false;

checkKey([{N, _} | T], SN) when SN == N ->
  true;

checkKey([{_, Cord} | T], {X, Y}) when Cord == {X, Y} ->
  true;

checkKey([H | T], Check) ->
  false orelse checkKey(T, Check).
