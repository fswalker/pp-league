module Views.Page exposing (frame)

import Char
import Html exposing (..)
import Html.Attributes exposing (..)


frame : Html msg
frame =
    section [ class "page-frame" ]
        [ div [ class "container" ]
            [ header [ class "header" ]
                [ div [ class "container" ]
                    [ div [ class "level" ]
                        [ div [ class "level-left" ]
                            [ h1 [ class "title" ]
                                [ text "Ping-pong League" ]
                            ]
                        , div [ class "level-right" ]
                            [ h3 [ class "subtitle" ]
                                [ text "Hello, "
                                , strong [] [ text "Guest" ]
                                , text "!"
                                ]
                            ]
                        ]
                    ]
                ]
            , nav
                [ class "navbar"
                , attribute "role" "navigation"
                , attribute "aria-label" "main navigation"
                ]
                [ div [ class "navbar-brand" ]
                    [ button [ class "button navbar-burger" ]
                        [ span [] []
                        , span [] []
                        , span [] []
                        ]
                    ]
                , div [ class "navbar-menu" ]
                    [ div [ class "navbar-start" ]
                        [ a [ class "navbar-item", href "#" ] [ text "Home" ]
                        ]
                    ]
                ]
            , div [ class "page-content" ] []
            , footer [ class "footer" ]
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
            ]
        ]
