module Util exposing (..)

import Char
import Random.Pcg as Random exposing (Generator)


charGenerator : Generator Char
charGenerator =
    (Random.map Char.fromCode (Random.int 32 126))


lengthString : Generator Char -> Int -> Generator String
lengthString charGenerator stringLength =
    Random.list stringLength charGenerator
        |> Random.map String.fromList
