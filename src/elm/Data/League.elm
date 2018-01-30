module Data.League exposing (League)


type alias League a =
    { a
        | name : String
        , order : Int
    }
