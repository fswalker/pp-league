module Views.Page exposing (frame)

import Char
import Html exposing (..)
import Html.Attributes exposing (..)
import Views.Assets as Assets exposing (src)
import Views.Loader as Loader
import Data.User as User exposing (User)
import Route


frame : User -> Bool -> Html msg -> Html msg
frame user isLoading content =
    section [ class "page-frame" ]
        [ div [ class "container" ]
            [ ppHeader user
            , navigation
            , div [ class "page-content" ]
                [ if isLoading then
                    Loader.loader
                  else
                    content
                ]
            , ppFooter
            ]
        ]


ppHeader : User -> Html msg
ppHeader user =
    header [ class "header" ]
        [ div [ class "container" ]
            [ div [ class "level" ]
                [ div [ class "level-left" ]
                    [ a [ Route.href Route.Home, title "Link - My League Page" ]
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
                , userGreeting user
                ]
            ]
        ]


userGreeting : User -> Html msg
userGreeting user =
    case user of
        User.Anonymous ->
            text ""

        User.Player { name } ->
            displayHelloMsg name

        User.Admin { name } ->
            displayHelloMsg name

        User.ServerAdmin { name } ->
            displayHelloMsg name


displayHelloMsg : String -> Html msg
displayHelloMsg uname =
    div [ class "level-right greeting" ]
        [ h3 [ class "subtitle" ]
            [ text "Hello, "
            , strong [] [ text uname ]
            , text "!"
            ]
        , a [ class "button is-rounded", Route.href Route.Logout ] [ text "Log Out" ]
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
                -- TODO proper nav with proper hrefs
                [ a [ class "navbar-item", href "#", title "Link - My League Page" ] [ text "My League" ]
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
