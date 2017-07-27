module TestTests exposing (..)

import Json.Decode
import Test exposing (..)
import Test.Extra exposing (..)


all : Test
all =
    describe "Test.Extra"
        [ describe "testDecoder"
            [ testDecoder Json.Decode.int
                ( "\"foo\""
                , FailsToDecodeWith "Expecting an Int but instead got: \"foo\""
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
                , ( "1.5", FailsToDecodeWith "Expecting an Int but instead got: 1.5" )
                ]
            ]
        ]
