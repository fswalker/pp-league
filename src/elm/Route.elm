module Route exposing (Route(..), fromLocation)

import Navigation exposing (Location)
import UrlParser as Url exposing (Parser, oneOf, map, top, s, parsePath)


type Route
    = Home
    | Login
    | Logout


route : Parser (Route -> a) a
route =
    oneOf
        [ map Home top
        , map Login (s "login")
        , map Logout (s "logout")
        ]


fromLocation : Location -> Maybe Route
fromLocation location =
    if String.isEmpty location.pathname then
        Just Home
    else
        parsePath route location
