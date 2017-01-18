module Test.Extra exposing (DecoderExpectation(..), describeDecoder, testDecoder)

{-| Write concise test for JSON decoders

@docs DecoderExpectation, describeDecoder, testDecoder
-}

import Expect
import Json.Decode exposing (decodeString)
import Test exposing (..)


{-| Expectation for a decoder result.

* `FailsToDecode` - expect the decoder to fail, the failure message can be anything
* `FailsToDecodeWith String` - expect the decoder to fail with a specific message
* `DecodesTo a` - expect the decoder to succeed, decoding to the provided value
-}
type DecoderExpectation a
    = FailsToDecode
    | FailsToDecodeWith String
    | DecodesTo a


{-| Exercise a decoder over a list of input/expectation pairs.

For example

```elm
describeDecoder "int"
  Json.Decode.int
  [ ( "", FailsToDecode )
  , ( "foo", FailsToDecode )
  , ( "1", DecodesTo 1 )
  , ( "1.5", FailsToDecode )
  ]
```
-}
describeDecoder : String -> Json.Decode.Decoder a -> List ( String, DecoderExpectation a ) -> Test
describeDecoder label decoder cases =
    cases
        |> List.map (testDecoder decoder)
        |> describe label


{-| Exercise a decoder with a JSON encoded string.

For example

```elm
testDecoder Json.Decode.string
  "\"foo\""
  (DecodesTo "foo")
```
-}
testDecoder : Json.Decode.Decoder a -> ( String, DecoderExpectation a ) -> Test
testDecoder decoder ( input, expectation ) =
    test (testDecoderLabel input expectation) <|
        \() ->
            input
                |> decodeString decoder
                |> decoderExpectation input expectation


testDecoderLabel : String -> DecoderExpectation a -> String
testDecoderLabel input de =
    input ++ " " ++ (de |> toString)


decoderExpectation : String -> DecoderExpectation a -> Result String a -> Expect.Expectation
decoderExpectation input de result =
    case de of
        FailsToDecode ->
            case result of
                Ok actual ->
                    expectedFail input actual

                Err _ ->
                    Expect.pass

        FailsToDecodeWith exp ->
            case result of
                Ok actual ->
                    expectedFail input actual

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
                        expectedValue input exp actual

                Err err ->
                    expectedDecode input err


expectedFail : String -> a -> Expect.Expectation
expectedFail input actual =
    Expect.fail
        ("Expected input:\n  "
            ++ input
            ++ "\nto fail to decoded, but it decoded to:\n  "
            ++ (toString actual)
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


expectedValue : String -> a -> a -> Expect.Expectation
expectedValue input expected actual =
    Expect.fail
        ("Expected input:\n  "
            ++ input
            ++ "\nto decode to:\n  "
            ++ (toString expected)
            ++ "\nbut instead got decoded value:\n  "
            ++ (toString actual)
        )
