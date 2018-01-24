module Data.Round exposing (Round, roundDecoder)

import Json.Decode as Decode exposing (Decoder)
import Data.Entity exposing (..)


type alias Round =
    Entity
        { name : String
        }


buildRound : Id -> Rev -> String -> Round
buildRound id rev name =
    { id_ = id
    , rev_ = rev
    , name = name
    }


roundDecoder : Decoder Round
roundDecoder =
    Decode.map3 buildRound
        (Decode.field "_id" (Decode.nullable Decode.string))
        (Decode.field "_rev" (Decode.nullable Decode.string))
        (Decode.field "name" Decode.string)
