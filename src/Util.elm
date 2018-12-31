module Util exposing (charGenerator, lengthString)

import Char
import Random exposing (Generator)


charGenerator : Generator Char
charGenerator =
    Random.map Char.fromCode (Random.int 32 126)


lengthString : Generator Char -> Int -> Generator String
lengthString gen stringLength =
    Random.list stringLength gen
        |> Random.map String.fromList
