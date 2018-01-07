module Pages.Login exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)


view : Html msg
view =
    div [ class "hero" ]
        [ div [ class "hero-body" ]
            [ div [ class "columns" ]
                [ div [ class "column is-one-third is-offset-one-third" ]
                    [ div [ class "field" ]
                        [ p [ class "control has-icons-left" ]
                            [ input [ class "input", type_ "email", placeholder "Email" ] []
                            , span [ class "icon is-small is-left" ]
                                [ i [ class "fa fa-envelope" ] [] ]
                            ]
                        ]
                    , div [ class "field" ]
                        [ p [ class "control has-icons-left" ]
                            [ input [ class "input", type_ "password", placeholder "Password" ] []
                            , span [ class "icon is-small is-left" ]
                                [ i [ class "fa fa-lock" ] [] ]
                            ]
                        ]
                    , div [ class "field is-grouped is-grouped-right" ]
                        [ p [ class "control" ]
                            [ button [ class "button is-success" ]
                                [ text "Login"
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]
