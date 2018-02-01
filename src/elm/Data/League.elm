module Data.League exposing (League, leagueDecoder)

import Json.Decode as Decode exposing (Decoder)


type alias League a =
    { a
        | name : String
        , order : Int
    }


buildLeague : String -> Int -> League {}
buildLeague name order =
    { name = name
    , order = order
    }


leagueDecoder : Decoder (League {})
leagueDecoder =
    Decode.map2 buildLeague
        (Decode.field "name" Decode.string)
        (Decode.field "order" Decode.int)
