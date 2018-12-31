module TestTests exposing (all)

import Json.Decode
import Test exposing (..)
import Test.Extra exposing (..)


all : Test
all =
    describe "Test.Extra"
        [ describe "testDecoder"
            [ testDecoder Json.Decode.int
                ( "\"foo\""
                , FailsToDecodeWith "Problem with the given value:\n\n\"foo\"\n\nExpecting an INT"
                )
            , testDecoder
                Json.Decode.string
                ( "\"foo\"", DecodesTo "foo" )
            ]
        , describe "describeDecoder"
            [ describeDecoder "int"
                Json.Decode.int
                [ ( "", FailsToDecode )
                , ( "\"foo\"", FailsToDecode )
                , ( "1", DecodesTo 1 )
                , ( "1.5", FailsToDecode )
                , ( "1.5", FailsToDecodeWith "Problem with the given value:\n\n1.5\n\nExpecting an INT" )
                ]
            ]
        ]
