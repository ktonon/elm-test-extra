module Fuzz.Extra exposing (eitherOr, uniformOrCrash, stringMaxLength, union, sequence)

{-| Extends `Fuzz` with more `Fuzzer`s.

@docs eitherOr, uniformOrCrash, stringMaxLength, sequence

## Deprecated

Do not use this. It will be deprecated in version 2.

@docs union
-}

import Array
import Fuzz exposing (Fuzzer, andThen, map)
import Random.Pcg as Random exposing (Generator)
import Shrink exposing (Shrinker)
import Util exposing (..)


{-| Combine two fuzzers.

    fuzzMaybeInt : Fuzzer (Maybe Int)
    fuzzMaybeInt =
        Fuzz.Extra.eitherOr
            (Fuzz.constant Nothing)
            (Fuzz.int |> Fuzz.map Just)
-}
eitherOr : Fuzzer a -> Fuzzer a -> Fuzzer a
eitherOr a b =
    Fuzz.bool
        |> andThen
            (\x ->
                if x then
                    a
                else
                    b
            )


{-| Generates among the provided values with uniform distribution

Like `Fuzz.frequencyOrCrash` but with uniform distribution.

    httpMethod : Fuzzer Method
    httpMethod =
        [ GET, POST, PUT, DELETE, OPTIONS ]
            |> List.map Fuzz.constant
            |> uniformOrCrash

Same as for `frequencyOrCrash`: "This is useful in tests, where a crash will
simply cause the test run to fail. There is no danger to a production system
there."
-}
uniformOrCrash : List (Fuzzer a) -> Fuzzer a
uniformOrCrash list =
    list
        |> List.map (\x -> ( 1.0, x ))
        |> Fuzz.frequencyOrCrash


{-| Generates random printable ASCII with a maximum length.
-}
stringMaxLength : Int -> Fuzzer String
stringMaxLength high =
    Fuzz.custom
        (Random.int 0 high
            |> Random.andThen (lengthString charGenerator)
        )
        Shrink.string


{-| Sequence a list of fuzzers into a fuzzer of a list.
-}
sequence : List (Fuzzer a) -> Fuzzer (List a)
sequence fuzzers =
    List.foldl
        (\fuzzer listFuzzer ->
            Fuzz.constant (::)
                |> Fuzz.andMap fuzzer
                |> Fuzz.andMap listFuzzer
        )
        (Fuzz.constant [])
        fuzzers


{-| Create a fuzzer for a union type.

__Deprecated__: use `uniformOrCrash`
-}
union : List a -> a -> Shrinker a -> Fuzzer a
union list default shrinker =
    Fuzz.custom
        (let
            array =
                Array.fromList list

            index =
                (Array.length array) - 1
         in
            index
                |> Random.int 0
                |> Random.map
                    (\index ->
                        Array.get index array
                            |> Maybe.withDefault default
                    )
        )
        shrinker
