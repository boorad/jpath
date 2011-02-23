-module(jpath).

%% api
-export([get/2, set/3, multi_set/3, cleanup/1]).

%% types
-type(json_string() :: atom | binary()).
-type(json_number() :: integer() | float()).
-type(json_array() :: [json_term()]).
-type(json_object() :: {struct, [{json_string(), json_term()}]}).
-type(json_iolist() :: {json, iolist()}).
-type(json_term() :: json_string() | json_number() | json_array() |
      json_object() | json_iolist()).

-type(path() :: [binary()]).
-type(doc() :: json_object() | undefined).
-type(value() :: json_term() | undefined).
-type(new_values() :: [{json_string(), json_term()}]).

%% ===========================================================================
%%  api
%% ===========================================================================

%% @doc
%% given a path and a json document (mochijson2), query for the underlying
%% json value. Path looks like [<<"level1">>,<<"level2">>,<<"level3">>]
%% @end
-spec get(path(), doc()) -> value().
get([], Json) -> Json;
get(_, undefined) -> undefined;
get([Level|Rest], {struct, PropList}) ->
  get(Rest, get_value(Level, PropList)).

%% @doc
%% given a path, a json document (mochijson2), and a new value,
%% insert the value into the document at that path.  If the path does not
%% exist, create it.  Returns the new doc
%% @end
-spec set(path(), doc(), value()) -> doc().
set([], _Json, NewValue) -> NewValue;
set([Level|Rest], undefined, NewValue) ->
  % handle case where path doesn't exist... create it :)
  {struct, [{Level, set(Rest, undefined, NewValue)}] };
set([Level|Rest], {struct, PropList}, NewValue) ->
  NewJson = set(Rest, get_value(Level, PropList), NewValue),
  NewPropList = case lists:keysearch(Level, 1, PropList) of
    false ->
      lists:flatten(lists:append([PropList, [{Level, NewJson}]]));
    _ ->
      lists:keyreplace(Level, 1, PropList, {Level, NewJson})
  end,
  {struct, NewPropList}.

%% @doc
%% multi_set allows the caller to set multiple key/value pairs in one call.
%% Root is a list of levels passed to the set function above for all values.
%% Root can be the empty list, [].
%% NewValues is a list of tuples in the following format:
%% {RemainingPath, NewValue}.
%% RemainingPath is a list describing the rest of the path to the value being
%% set.  This will be appended to Root to set NewValue.  Returns the new doc.
%%
%% Example:
%% If you want to set "createTime" to CreateTime and "serviceGroup" to
%% ServiceGroup and both of those values exist in the "sessionManagerRequestData"
%% top-level element of your Json document, you'd call this function as follows:
%% jpath:multi_set(
%%   [<<"sessionManagerRequestData">>],
%%   [{[<<"createTime">>], CreateTime},
%%    {[<<"serviceGroup">>], ServiceGroup}],
%%   Json)
-spec multi_set(path(), new_values(), doc()) -> doc().
multi_set(Root, NewValues, Json) ->
  lists:foldl(fun({Path, NewVal}, JsonSoFar) ->
    set(lists:append(Root, Path), JsonSoFar, NewVal)
  end, Json, NewValues).

% This function removes all key/value pairs in the input Json document where the
% value is undefined.
-spec cleanup(json_term()) -> json_term().
cleanup({Name, Val}) ->
  {Name, cleanup(Val)};
cleanup([]) ->
  [];
cleanup([{_, undefined} | Rest]) ->
  cleanup(Rest);
cleanup([undefined | Rest]) ->
  cleanup(Rest);
cleanup([{Name, Val} | Rest]) ->
  [{Name, cleanup(Val)} | cleanup(Rest)];
cleanup(Val) ->
  Val.

%% ===========================================================================
%%  internal
%% ===========================================================================

%% @doc
%% get_value/2 and /3 replaces proplist:get_value/2 and /3
%% because this bif list function is a bit more efficient
%% @end
get_value(Key, List) ->
  get_value(Key, List, undefined).

get_value(Key, List, Default) ->
  case lists:keysearch(Key, 1, List) of
    {value, {Key,Value}} ->
      Value;
    false ->
      Default
  end.
