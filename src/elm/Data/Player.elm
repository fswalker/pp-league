module Data.Player exposing (Player, playerDecoder)

import Json.Decode as Decode exposing (Decoder)


type alias Player a =
    { a
        | nick : String
        , league_id : String
    }


buildPlayer : String -> String -> Player {}
buildPlayer nick league_id =
    { nick = nick
    , league_id = league_id
    }


playerDecoder : Decoder (Player {})
playerDecoder =
    Decode.map2 buildPlayer
        (Decode.field "nick" Decode.string)
        (Decode.field "league_id" Decode.string)
