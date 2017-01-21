module Expect.Extra exposing (contain, member)

{-| Extends `Expect` with more `Expectation`s.

@docs contain, member
-}

import Expect exposing (..)


{-| Passes if value is a member of list.

    member 1 [0, 1, 2]

    -- Passes because 1 is a member of [0, 1, 2]
-}
member : a -> List a -> Expectation
member value list =
    if List.member value list then
        pass
    else
        fail
            ("Expected:\n  "
                ++ (toString list)
                ++ "\nto contain:\n  "
                ++ (toString value)
            )


{-| Alias of `member`.

Reads better with bdd style tests.

    expect [0, 1, 2] to contain 1

    -- Passes because [0, 1, 2] contains 1
-}
contain : a -> List a -> Expectation
contain =
    member
