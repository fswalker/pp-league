module Views.Page exposing (frame)

import Char
import Html exposing (..)
import Html.Attributes exposing (..)
import Views.Assets as Assets exposing (src)


frame : Html msg
frame =
    section [ class "page-frame" ]
        [ div [ class "container" ]
            [ ppHeader
            , navigation
            , div [ class "page-content" ]
                [ p [] [ text "TODO" ]
                ]
            , ppFooter
            ]
        ]


ppHeader : Html msg
ppHeader =
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
                , div [ class "level-right greeting" ]
                    [ h3 [ class "subtitle" ]
                        [ text "Hello, "
                        , strong [] [ text "Guest" ]
                        , text "!"
                        ]
                    ]
                ]
            ]
        ]


navigation : Html msg
navigation =
    nav
        [ class "navbar is-transparent main"
        , attribute "role" "navigation"
        , attribute "aria-label" "main navigation"
        ]
        [ div [ class "navbar-brand" ]
            [ -- [ a [ class "navbar-item", href "#" ]
              --     [ img [ Assets.src Assets.pp_menu ] []
              --     ]
              div [ class "button navbar-burger burger", attribute "data-target" "pp-navbar-menu" ]
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
    footer [ class "footer is-paddingless" ]
        [ div [ class "container" ]
            [ div [ class "content" ]
                [ p []
                    [ strong [] [ text "Ping-pong League " ]
                    , text "web app. "
                    , text "The source code is licensed "
                    , span [] [ text "MIT. " ]
                    , text ((String.fromChar <| Char.fromCode 169) ++ " Michał Grygierzec 2018.")
                    ]
                ]
            ]
        ]
