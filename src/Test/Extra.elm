module Test.Extra exposing (DecoderExpectation(..), describeDecoder, testDecoder)

{-| Extends `Test` with specialized test and describe function.


## Describing JSON Decoders

Write concise test for JSON decoders

@docs DecoderExpectation, describeDecoder, testDecoder

-}

import Expect
import Json.Decode exposing (decodeString)
import Test exposing (..)


{-| Expectation for a decoder result.

  - `FailsToDecode` - expect the decoder to fail, the failure message can be anything
  - `FailsToDecodeWith String` - expect the decoder to fail with a specific message
  - `DecodesTo a` - expect the decoder to succeed, decoding to the provided value

-}
type DecoderExpectation a
    = FailsToDecode
    | FailsToDecodeWith String
    | DecodesTo a


{-| Exercise a decoder over a list of input/expectation pairs.

For example

    describeDecoder "int"
        Json.Decode.int
        Debug.toString
        [ ( "", FailsToDecode )
        , ( "foo", FailsToDecode )
        , ( "1", DecodesTo 1 )
        , ( "1.5", FailsToDecode )
        ]

-}
describeDecoder :
    String
    -> Json.Decode.Decoder a
    -> (a -> String)
    -> List ( String, DecoderExpectation a )
    -> Test
describeDecoder label decoder toString cases =
    cases
        |> List.map (testDecoder decoder toString)
        |> describe label


{-| Exercise a decoder with a JSON encoded string.

For example

    testDecoder Json.Decode.string
        Debug.toString
        ( "\"foo\"", DecodesTo "foo" )

-}
testDecoder : Json.Decode.Decoder a -> (a -> String) -> ( String, DecoderExpectation a ) -> Test
testDecoder decoder toString ( input, expectation ) =
    test (testDecoderLabel toString input expectation) <|
        \() ->
            input
                |> decodeString decoder
                |> Result.mapError Json.Decode.errorToString
                |> decoderExpectation toString input expectation


testDecoderLabel : (a -> String) -> String -> DecoderExpectation a -> String
testDecoderLabel toString input de =
    input
        ++ " "
        ++ (case de of
                FailsToDecode ->
                    "FailsToDecode"

                FailsToDecodeWith val ->
                    "FailsToDecodeWith " ++ val

                DecodesTo val ->
                    "DecodesTo " ++ toString val
           )


decoderExpectation : (a -> String) -> String -> DecoderExpectation a -> Result String a -> Expect.Expectation
decoderExpectation toString input de result =
    case de of
        FailsToDecode ->
            case result of
                Ok actual ->
                    expectedFail toString input actual

                Err _ ->
                    Expect.pass

        FailsToDecodeWith exp ->
            case result of
                Ok actual ->
                    expectedFail toString input actual

                Err actualError ->
                    if actualError /= exp then
                        expectedMsg input exp actualError

                    else
                        Expect.pass

        DecodesTo exp ->
            case result of
                Ok actual ->
                    if actual == exp then
                        Expect.pass

                    else
                        expectedValue toString input exp actual

                Err err ->
                    expectedDecode input err


expectedFail : (a -> String) -> String -> a -> Expect.Expectation
expectedFail toString input actual =
    Expect.fail
        ("Expected input:\n  "
            ++ input
            ++ "\nto fail to decoded, but it decoded to:\n  "
            ++ toString actual
        )


expectedMsg : String -> String -> String -> Expect.Expectation
expectedMsg input expected actual =
    Expect.fail
        ("Expected input:\n  "
            ++ input
            ++ "\nto fail to decode with message:\n  "
            ++ expected
            ++ "\nbut instead got message:\n  "
            ++ actual
        )


expectedDecode : String -> String -> Expect.Expectation
expectedDecode input errorMessage =
    Expect.fail
        ("Expected input:\n  "
            ++ input
            ++ "\nto decode successfully, but instead it failed with message:\n  "
            ++ errorMessage
        )


expectedValue : (a -> String) -> String -> a -> a -> Expect.Expectation
expectedValue toString input expected actual =
    Expect.fail
        ("Expected input:\n  "
            ++ input
            ++ "\nto decode to:\n  "
            ++ toString expected
            ++ "\nbut instead got decoded value:\n  "
            ++ toString actual
        )
