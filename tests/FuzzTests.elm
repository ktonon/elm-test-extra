module FuzzTests exposing (all)

import Expect exposing (..)
import Expect.Extra exposing (..)
import Fuzz exposing (Fuzzer, constant)
import Fuzz.Extra
import Shrink exposing (Shrinker)
import Test exposing (..)


all : Test
all =
    describe "Fuzz.Extra"
        [ describe "stringMaxLength"
            [ fuzz (Fuzz.Extra.stringMaxLength 10) "fuzzes strings with appropriate length" <|
                \w ->
                    Expect.lessThan 11 (w |> String.length)
            ]
        ]
