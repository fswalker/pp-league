module Data.Player exposing (Player, playerDecoder)

import Json.Decode as Decode exposing (Decoder)
import Data.Entity exposing (..)


type alias Player a =
    { a
        | nick : String
        , league_id : String
    }


buildPlayerEntity : Maybe String -> Maybe String -> String -> String -> Player (Entity {})
buildPlayerEntity id_ rev_ nick league_id =
    { id_ = id_
    , rev_ = rev_
    , nick = nick
    , league_id = league_id
    }


playerDecoder : Decoder (Player (Entity {}))
playerDecoder =
    Decode.map4 buildPlayerEntity
        (Decode.field "_id" (Decode.nullable Decode.string))
        (Decode.field "_rev" (Decode.nullable Decode.string))
        (Decode.field "nick" Decode.string)
        (Decode.field "league_id" Decode.string)
