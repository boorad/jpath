-module(jpath_test).

-include_lib("eunit/include/eunit.hrl").


-define(DOC1,
        {struct,
         [{<<"simple_level">>, <<"bin_value">>},
          {<<"different_types">>,
           {struct,
            [{<<"bin_key">>, <<"bin_value">>},
             {<<"epoch">>, 1274813855407},
             {<<"null">>, null}] }},
          {<<"level_1">>,
           {struct,
            [{<<"level_2">>,
              {struct,
               [{<<"level_3">>,
                 {struct,
                  [{<<"level_4">>, <<"level_4_value">>}]}}]}}]}}]}).


%% jpath_get tests
get_simple_level_test() ->
    Json = jpath:get([<<"simple_level">>], ?DOC1),
    ?assertEqual(<<"bin_value">>, Json),
    ok.

get_multi_level_test() ->
    Json = jpath:get(
        [<<"level_1">>,<<"level_2">>,<<"level_3">>,<<"level_4">>], ?DOC1),
    ?assertEqual(<<"level_4_value">>, Json),
    ok.

%% jpath_set tests
set_simple_level_replace_test() ->
    Path = [<<"simple_level">>],
    % do jpath_set of new value
    NewDoc = jpath:set(Path, ?DOC1, "string_value"),
    % get and test new value
    Json2 = jpath:get(Path, NewDoc),
    ?assertEqual("string_value", Json2),
    ok.

set_new_key_append_test() ->
    Path = [<<"new_key">>],
    % do jpath_set of new value
    NewDoc = jpath:set(Path, ?DOC1, "string_value"),
    % get and test new value
    Json2 = jpath:get(Path, NewDoc),
    ?assertEqual("string_value", Json2),
    ok.

set_multi_level_test() ->
    Path = [<<"level_1">>,<<"level_2">>,<<"level_3">>,<<"level_4">>],
    % do jpath_set of new value
    NewDoc = jpath:set(Path, ?DOC1, "string_value"),
    % get and test new value
    Json2 = jpath:get(Path, NewDoc),
    ?assertEqual("string_value", Json2),
    ok.

set_one_not_present_test() ->
    Path = [<<"componentData">>,<<"TEARDOWN">>],
    Doc = {struct,[{<<"requestData">>,
               {struct,[{<<"sessionId">>,<<"000010628c2b09e5bd5e">>}]}}]},
    Json = {struct,[{<<"teardown">>, <<"SUCCESS">>}]},
    _NewDoc = jpath:set(Path, Doc, Json),
    ok.

set_two_not_present_test() ->
    Path = [<<"level_1">>,<<"level_2">>,<<"level_3">>],
    Doc = {struct,[{<<"requestData">>,
               {struct,[{<<"sessionId">>,<<"000010628c2b09e5bd5e">>}]}}]},
    Json = {struct,[{<<"teardown">>, <<"SUCCESS">>}]},
    NewDoc = jpath:set(Path, Doc, Json),
    Json2 = jpath:get(Path, NewDoc),
    ?assertEqual(Json, Json2).
