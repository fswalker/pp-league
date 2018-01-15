module Route
    exposing
        ( Route(..)
        , fromLocation
        , newUrl
        , href
        )

import Html exposing (Attribute)
import Html.Attributes as Attr
import Navigation exposing (Location)
import UrlParser as Url exposing (Parser, oneOf, map, top, s, parseHash)


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


routeToStr : Route -> String
routeToStr route =
    "#/"
        ++ case route of
            Home ->
                ""

            Login ->
                "login"

            Logout ->
                "logout"


fromLocation : Location -> Maybe Route
fromLocation location =
    if String.isEmpty location.hash then
        Just Home
    else
        parseHash route location


newUrl : Route -> Cmd msg
newUrl =
    routeToStr >> Navigation.newUrl


href : Route -> Attribute msg
href =
    Attr.href << routeToStr
