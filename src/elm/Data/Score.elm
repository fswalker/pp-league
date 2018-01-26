module Data.Score exposing (Score, scoreDecoder, scoresListDecoder)

import Date as Date exposing (Date)
import Json.Decode as Decode exposing (Decoder)


type alias Score a =
    { a
        | player1 : String
        , player2 : String
        , score1 : Int
        , score2 : Int
        , date : Maybe Date
        , league_id : String
        , round_id : String
    }


buildScoreEntity : String -> String -> Int -> Int -> String -> String -> String -> Score {}
buildScoreEntity p1 p2 s1 s2 dateStr league_id round_id =
    { player1 = p1
    , player2 = p2
    , score1 = s1
    , score2 = s2
    , date = parseDate dateStr
    , league_id = league_id
    , round_id = round_id
    }


scoreDecoder : Decoder (Score {})
scoreDecoder =
    Decode.map7 buildScoreEntity
        (Decode.field "player1" Decode.string)
        (Decode.field "player2" Decode.string)
        (Decode.field "score1" Decode.int)
        (Decode.field "score2" Decode.int)
        (Decode.field "date" Decode.string)
        (Decode.field "league_id" Decode.string)
        (Decode.field "round_id" Decode.string)


scoresListDecoder : Decoder (List (Score {}))
scoresListDecoder =
    Decode.list scoreDecoder


parseDate : String -> Maybe Date
parseDate =
    Date.fromString >> Result.toMaybe
