module Main exposing (..)

import Benchmark exposing (..)
import Benchmark.Runner exposing (BenchmarkProgram, program)
import Char
import Dict
import Dict.Avl as Avl
import Time exposing (Time)


forValues : String -> Int -> (Int -> comparable) -> (Int -> b) -> Benchmark
forValues name size keyer valuer =
    let
        source =
            List.map
                (\n -> ( keyer n, valuer n ))
                (List.range 1 size)

        key =
            keyer size

        value =
            valuer size
    in
        describe (name ++ " (" ++ toString size ++ " items)")
            [ Benchmark.compare "insert"
                (Benchmark.benchmark3 "Dict.Avl" Avl.insert key value (Avl.fromList source))
                (Benchmark.benchmark3 "Dict" Dict.insert key value (Dict.fromList source))
            , Benchmark.compare "get"
                (Benchmark.benchmark2 "Dict.Avl" Avl.get key (Avl.fromList source))
                (Benchmark.benchmark2 "Dict" Dict.get key (Dict.fromList source))
            , Benchmark.compare "remove"
                (Benchmark.benchmark2 "Dict.Avl" Avl.remove key (Avl.fromList source))
                (Benchmark.benchmark2 "Dict" Dict.remove key (Dict.fromList source))
            , Benchmark.compare "toList"
                (Benchmark.benchmark1 "Dict.Avl" Avl.toList (Avl.fromList source))
                (Benchmark.benchmark1 "Dict" Dict.toList (Dict.fromList source))
            ]


suiteOfSize : Int -> Benchmark
suiteOfSize size =
    describe ("dicts of size " ++ toString size)
        [ forValues "int" size identity (always ())
        , forValues "float" size toFloat (always ())
        , forValues "time" size (toFloat >> (*) Time.millisecond) (always ())
        , forValues "char" size Char.fromCode (always ())
        , forValues "string" size toString (always ())
        , forValues "tuple of int" size (\i -> ( i, i )) (always ())
        ]


main : BenchmarkProgram
main =
    program <| describe "dicts" <| List.map suiteOfSize [ 0, 1, 10, 100, 1000, 10000 ]
