# jpath - an xpath-like libary for Erlang

Brad Anderson - brad@sankatygroup.com

## Overview

jpath works on decoded json (mochijson2) documents as Erlang terms.  You can get and set values based on a path you provide.

## Usage

Simple `get` example:

    Path = [<<"simple_level">>]
    Doc = {struct,
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
                  [{<<"level_4">>, <<"level_4_value">>}]}}]}}]}}]}

    <<"bin_value">> = jpath:get(Path, Doc)

Simple `set` example:

    NewDoc = jpath:set(Path, Doc, "string_value")
    "string_value" = jpath:get(Path, NewDoc)