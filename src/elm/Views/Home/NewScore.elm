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
                    [ viewPlayerDropdown "Player 1" ]
                , div [ class "column" ]
                    [ viewPlayerDropdown "Player 2" ]
                ]
            , div [ class "columns is-mobile" ]
                [ div [ class "column" ]
                    [ viewScoreInput "Score 1" ]
                , div [ class "column" ]
                    [ viewScoreInput "Score 2" ]
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


fieldWrapper : String -> Html msg -> Html msg
fieldWrapper labelText control =
    div [ class "field" ]
        [ label [ class "label" ] [ text labelText ]
        , control
        ]


viewPlayerDropdown : String -> Html msg
viewPlayerDropdown labelText =
    p [ class "control is-expanded has-icons-left" ]
        [ span [ class "select is-fullwidth" ]
            [ select []
                [ option [ selected True ] [ text "Choose player..." ]
                , option [] [ text "Player 1" ]
                , option [] [ text "Player 2" ]
                , option [] [ text "Player 3" ]
                ]
            ]
        , span [ class "icon is-small is-left" ]
            [ i [ class "fa fa-user" ] [] ]
        ]
        |> fieldWrapper labelText


viewScoreInput : String -> Html msg
viewScoreInput labelText =
    div [ class "control is-expaned has-icons-left" ]
        [ input
            [ class "input"
            , type_ "number"
            , value "0"
            , Html.Attributes.min "0"
            , Html.Attributes.max "3"
            ]
            []
        , span [ class "icon is-small is-left" ]
            [ i [ class "fa fa-trophy" ] [] ]
        ]
        |> fieldWrapper labelText
