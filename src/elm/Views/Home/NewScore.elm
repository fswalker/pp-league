module Views.Home.NewScore exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)


view : Html msg
view =
    div [ class "new-score-form columns is-centered" ]
        [ div [ class "column is-half-desktop is-two-thirds-tablet has-text-centered is-size-5" ]
            [ h3 [ class "new-score-form-title is-size-3" ] [ text "Match Score" ]
            , div [ class "columns is-mobile" ]
                [ div [ class "column" ]
                    [ text "P1" ]
                , div [ class "column" ]
                    [ text "P2" ]
                ]
            , div [ class "columns is-mobile" ]
                [ div [ class "column" ]
                    [ text "S1" ]
                , div [ class "column" ]
                    [ text "S2" ]
                ]
            , div [ class "columns is-mobile" ]
                [ div [ class "column" ]
                    [ text "Date" ]
                , div [ class "column" ]
                    []
                ]
            , div [ class "columns is-mobile" ]
                [ div [ class "column" ]
                    [ div [ class "level" ]
                        [ div [ class "level-left" ]
                            [ button [ class "button level-item" ] [ text "Cancel" ]
                            , button [ class "button level-item" ] [ text "Add" ]
                            ]
                        ]
                    ]
                ]
            ]
        ]
