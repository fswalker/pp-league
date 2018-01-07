module Views.Loader exposing (loader)

import Html exposing (..)
import Html.Attributes exposing (..)


loader : Html msg
loader =
    div [ class "hero is-medium" ]
        [ div [ class "hero-body" ]
            [ div [ class "level" ]
                [ div [ class "level-item" ]
                    [ div [ class "loader is-size-1" ] []
                    ]
                ]
            ]
        ]
