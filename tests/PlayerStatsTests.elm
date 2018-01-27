module PlayerStatsTests exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import Date exposing (Date)
import Data.Score exposing (Score)
import Data.PlayerStats exposing (..)


buildScore : String -> String -> Int -> Int -> Score {}
buildScore p1 p2 s1 s2 =
    { player1 = p1
    , player2 = p2
    , score1 = s1
    , score2 = s2
    , date = Nothing
    , league_id = ""
    , round_id = ""
    }


unitTests : Test
unitTests =
    describe "PlayerStats module"
        [ describe "calculateScoresTable"
            [ test "Given empty input When run Then produce empty output" <|
                \_ ->
                    calculateScoresTable [] []
                        |> Expect.equal []
            , test "Given empty users and one score, When run, Then produce two valid stats" <|
                \_ ->
                    calculateScoresTable [] [ buildScore "p1" "p2" 3 1 ]
                        |> Expect.equal
                            [ PlayerStats "p1" 1 2 1 0 3 1
                            , PlayerStats "p2" 1 1 0 1 1 3
                            ]
            , test "Given empty users and two scores with three different users, When run, Then produce three valid stats" <|
                \_ ->
                    calculateScoresTable []
                        [ buildScore "p1" "p2" 3 1
                        , buildScore "p1" "p3" 3 2
                        ]
                        |> Expect.equal
                            [ PlayerStats "p1" 2 4 2 0 6 3
                            , PlayerStats "p3" 1 1 0 1 2 3
                            , PlayerStats "p2" 1 1 0 1 1 3
                            ]
            ]
        ]
