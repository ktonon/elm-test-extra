elm-test-extra
==============

[![elm-package](https://img.shields.io/badge/elm-2.0.1-blue.svg)](http://package.elm-lang.org/packages/ktonon/elm-test-extra/latest)
[![CircleCI](https://img.shields.io/circleci/project/github/ktonon/elm-test-extra.svg)](https://circleci.com/gh/ktonon/elm-test-extra)

Extra expectations, fuzzers, testers and describers.

`elm package install` [ktonon/elm-test-extra][]

## Example: Describing JSON Decoders

Write concise test for JSON decoders.

Use the high level `describeDecoder` to quickly write tests that exercise a `Json.Decode.Decoder`. For example,

```elm
describeDecoder "int"
  Json.Decode.int
  Debug.toString
  [ ( "", FailsToDecode )
  , ( "\"foo\"", FailsToDecode )
  , ( "1", DecodesTo 1 )
  , ( "1.5", FailsToDecode )
  , ( "\"this-will-fail\"", DecodesTo 5)
  ]
```

In this example, the last test will fail, giving helpful feedback:

```
↓ int
✗ this-will-fail DecodesTo 5

Expected input:
  "this-will-fail"
to decode successfully, but instead it failed with message:
  Problem with the given value:

"this-will-fail"

Expecting an INT
```

[ktonon/elm-test-extra]:http://package.elm-lang.org/packages/ktonon/elm-test-extra/latest
