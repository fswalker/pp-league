module Views.Navigation exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)


view : Html msg
view =
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
