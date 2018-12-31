module ExpectTests exposing (all)

import Expect
import Expect.Extra exposing (..)
import Test exposing (..)


all : Test
all =
    describe "Expect.Extra"
        [ describe "match (stringPattern pattern) actual"
            [ test "passes if actual equals pattern" <|
                \_ ->
                    Expect.equal
                        Expect.pass
                        (match (stringPattern "foo") "foo")
            , test "passes if actual begins with pattern" <|
                \_ ->
                    Expect.equal
                        Expect.pass
                        (match (stringPattern "foo") "foobar")
            , test "passes if actual ends with pattern" <|
                \_ ->
                    Expect.equal
                        Expect.pass
                        (match (stringPattern "bar") "foobar")
            , test "passes if actual contains pattern" <|
                \_ ->
                    Expect.equal
                        Expect.pass
                        (match (stringPattern "bar") "foobarcar")
            , test "fails if actual does not contain pattern" <|
                \_ ->
                    Expect.equal
                        (Expect.fail "\"bar\" to contain sub-string: foo")
                        (match (stringPattern "foo") "bar")
            , test "is case sensitive" <|
                \_ ->
                    Expect.equal
                        (Expect.fail "\"FOO\" to contain sub-string: foo")
                        (match (stringPattern "foo") "FOO")
            ]
        , describe "match (regexPattern pattern) actual"
            [ test "passes with full match" <|
                \_ ->
                    Expect.equal
                        Expect.pass
                        (match (regexPattern "^foo$") "foo")
            , test "fails with full match" <|
                \_ ->
                    Expect.equal
                        (Expect.fail "\"foo bar\" to match regex: ^foo$")
                        (match (regexPattern "^foo$") "foo bar")
            , test "fails with case-insensitive match" <|
                \_ ->
                    Expect.equal
                        (Expect.fail "\"FOO\" to match regex: foo")
                        (match (regexPattern "foo") "FOO")
            , test "passes with regular expression match" <|
                \_ ->
                    Expect.equal
                        Expect.pass
                        (match (regexPattern "foo\\s+bar") "foo    \t  bar")
            , test "fails if the pattern is not a regular expression" <|
                \_ ->
                    Expect.equal
                        (Expect.fail "Bad pattern given to Expect.Extra.match: [z")
                        (match (regexPattern "[z") "foo")
            ]
        , describe "member" <|
            [ test "value in list" <|
                \_ ->
                    Expect.equal
                        Expect.pass
                        (member Debug.toString 3 [ 1, 2, 3 ])
            , test "value not in list" <|
                \_ ->
                    Expect.equal
                        (Expect.fail "Expected:\n  [1, 2, 3]\nto contain:\n  4")
                        (member Debug.toString 4 [ 1, 2, 3 ])
            ]
        ]
