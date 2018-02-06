module Data.Request exposing (Request(..), toMaybe)


type Request a
    = NotStarted
    | Loading
    | Ready a


toMaybe : Request a -> Maybe a
toMaybe req =
    case req of
        NotStarted ->
            Nothing

        Loading ->
            Nothing

        Ready v ->
            Just v
