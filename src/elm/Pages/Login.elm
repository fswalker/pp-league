module Pages.Login
    exposing
        ( Msg
        , Model
        , init
        , update
        , view
        )

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick)
import Storage


type alias Model =
    { login : String
    , password : String
    }


type Msg
    = InputLogin String
    | InputPassword String
    | Login Model


init : Model
init =
    { login = ""
    , password = ""
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InputLogin login ->
            ( { model | login = login }, Cmd.none )

        InputPassword pwd ->
            ( { model | password = pwd }, Cmd.none )

        Login _ ->
            ( init, Storage.logIn model )


view : Model -> Html Msg
view model =
    div [ class "columns" ]
        [ div [ class "column is-one-third is-offset-one-third" ]
            [ h2 [ class "is-size-3 has-text-centered" ] [ text "Login" ]
            , div [ class "field" ]
                [ p [ class "control has-icons-left" ]
                    [ input
                        [ class "input is-rounded"
                        , type_ "email"
                        , placeholder "Email"
                        , value model.login
                        , onInput InputLogin
                        ]
                        []
                    , span [ class "icon is-small is-left" ]
                        [ i [ class "fa fa-envelope" ] [] ]
                    ]
                ]
            , div [ class "field" ]
                [ p [ class "control has-icons-left" ]
                    [ input
                        [ class "input is-rounded"
                        , type_ "password"
                        , placeholder "Password"
                        , value model.password
                        , onInput InputPassword
                        ]
                        []
                    , span [ class "icon is-small is-left" ]
                        [ i [ class "fa fa-lock" ] [] ]
                    ]
                ]
            , div [ class "field is-grouped is-grouped-right" ]
                [ p [ class "control" ]
                    [ button
                        [ class "button is-rounded is-success"
                        , onClick (Login model)
                        ]
                        [ text "Login"
                        ]
                    ]
                ]
            ]
        ]
