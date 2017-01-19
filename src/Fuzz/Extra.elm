module Fuzz.Extra exposing (union)

{-| Extends [Fuzz](http://package.elm-lang.org/packages/elm-community/elm-test/latest/Fuzz) with more `Fuzzer`s

@docs union
-}

import Array
import Fuzz exposing (Fuzzer, map)
import Random.Pcg as Random
import Shrink exposing (Shrinker)


{-| Create a fuzzer for a union type.

    type Age
        = Baby
        | Teen
        | Adult


    shrinkAge : Shrinker Age
    shrinkAge a =
        case a of
            Baby ->
                Teen ::: Adult ::: empty

            Teen ->
                Adult ::: empty

            Adult ->
                empty


    fuzzAge : Fuzzer Age
    fuzzAge =
        Fuzz.Extra.union [ Baby, Teen, Adult ] Baby shrinkAge
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
