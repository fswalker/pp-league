module Data.Entity exposing (Entity, Id, Rev)


type alias Id =
    Maybe String


type alias Rev =
    Maybe String


type alias Entity a =
    { a
        | id_ : Id
        , rev_ : Rev
    }
