module FuzzTests exposing (all)

import ElmTestBDDStyle exposing (..)
import Expect exposing (..)
import Expect.Extra exposing (..)
import Fuzz exposing (Fuzzer, constant)
import Fuzz.Extra
import Lazy.List exposing ((:::), empty)
import Shrink exposing (Shrinker)
import Test exposing (..)


all : Test
all =
    describe "Fuzz.Extra"
        [ describe "stringMaxLength"
            [ fuzz (Fuzz.Extra.stringMaxLength 10) "fuzzes strings with appropriate length" <|
                \w ->
                    expect (w |> String.length) toBe lessThan 11
            ]
        , describe "union"
            [ fuzz fuzzAge "fuzzes a union type" <|
                \age ->
                    expect [ Baby, Teen, Adult ] to contain age
            ]
        ]


type Age
    = Baby
    | Teen
    | Adult
    | WillLeaveThisOut


shrinkAge : Shrinker Age
shrinkAge a =
    case a of
        WillLeaveThisOut ->
            Baby ::: Teen ::: Adult ::: empty

        Baby ->
            Teen ::: Adult ::: empty

        Teen ->
            Adult ::: empty

        Adult ->
            empty


fuzzAge : Fuzzer Age
fuzzAge =
    Fuzz.Extra.union [ Baby, Teen, Adult ] WillLeaveThisOut shrinkAge
