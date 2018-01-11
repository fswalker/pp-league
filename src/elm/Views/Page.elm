module Views.Page exposing (frame)

import Char
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Views.Assets as Assets exposing (src)
import Views.Loader as Loader
import Data.User as User exposing (User)


frame : User -> msg -> Html msg -> Html msg
frame user logoutMsg content =
    section [ class "page-frame" ]
        [ div [ class "container" ]
            [ ppHeader user logoutMsg
            , navigation
            , div [ class "page-content" ]
                [ content ]
            , ppFooter
            ]
        ]


ppHeader : User -> msg -> Html msg
ppHeader user logoutMsg =
    header [ class "header" ]
        [ div [ class "container" ]
            [ div [ class "level" ]
                [ div [ class "level-left" ]
                    [ a [ href "#", title "Link - Home Page" ]
                        [ div [ class "level" ]
                            [ div [ class "level-left" ]
                                [ img
                                    [ class "level-item logo image is-128x128"
                                    , Assets.src Assets.pp_menu
                                    , alt "Logo image - racket and the ball"
                                    ]
                                    []
                                , h1 [ class "page-title level-item title is-size-2" ]
                                    [ text "Ping-pong League" ]
                                ]
                            ]
                        ]
                    ]
                , userGreeting user logoutMsg
                ]
            ]
        ]


userGreeting : User -> msg -> Html msg
userGreeting user logoutMsg =
    case user of
        User.Anonymous ->
            text ""

        User.Player { name } ->
            displayHelloMsg name logoutMsg

        User.Admin { name } ->
            displayHelloMsg name logoutMsg

        User.ServerAdmin { name } ->
            displayHelloMsg name logoutMsg


displayHelloMsg : String -> msg -> Html msg
displayHelloMsg uname logoutMsg =
    div [ class "level-right greeting" ]
        [ h3 [ class "subtitle" ]
            [ text "Hello, "
            , strong [] [ text uname ]
            , text "!"
            ]
        , button [ class "button is-rounded", onClick logoutMsg ] [ text "Log Out" ]
        ]


navigation : Html msg
navigation =
    nav
        [ class "navbar is-transparent main"
        , attribute "role" "navigation"
        , attribute "aria-label" "main navigation"
        ]
        [ div [ class "navbar-brand" ]
            [ div [ class "button navbar-burger burger", attribute "data-target" "pp-navbar-menu" ]
                [ span [] []
                , span [] []
                , span [] []
                ]
            ]
        , div [ class "navbar-menu", id "pp-navbar-menu" ]
            [ div [ class "navbar-start is-size-5" ]
                [ a [ class "navbar-item", href "#", title "Link - Home Page" ] [ text "Home" ]
                ]
            ]
        ]


ppFooter : Html msg
ppFooter =
    let
        copyright =
            String.fromChar <| Char.fromCode 169
    in
        footer [ class "footer" ]
            [ div [ class "columns" ]
                [ p [ class "column" ]
                    [ strong [] [ text "Ping-pong League " ]
                    , text "web app. "
                    ]
                , p [ class "column has-text-centered" ]
                    [ text "The source code is licensed "
                    , span [] [ text "MIT. " ]
                    ]
                , p [ class "column has-text-right" ]
                    [ text (copyright ++ " Michał Grygierzec 2018.")
                    ]
                ]
            ]
