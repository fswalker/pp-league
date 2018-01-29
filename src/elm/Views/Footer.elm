module Views.Footer exposing (view)

import Html exposing (Html, footer, div, p, span, strong, text)
import Html.Attributes exposing (class)
import Char


view : Html msg
view =
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
