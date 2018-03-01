module Route
    exposing
        ( Route(..)
        , fromLocation
        , navigateTo
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
    | NewScore
    | Round


route : Parser (Route -> a) a
route =
    oneOf
        [ map Home top
        , map Login (s "login")
        , map Logout (s "logout")
        , map NewScore (s "newScore")
        , map Round (s "round")
        ]


toStr : Route -> String
toStr route =
    "#/"
        ++ case route of
            Home ->
                ""

            Login ->
                "login"

            Logout ->
                "logout"

            NewScore ->
                "newScore"

            Round ->
                "round"


fromLocation : Location -> Maybe Route
fromLocation location =
    if String.isEmpty location.hash then
        Just Home
    else
        parseHash route location


navigateTo : Route -> Cmd msg
navigateTo =
    toStr >> Navigation.newUrl


href : Route -> Attribute msg
href =
    Attr.href << toStr
