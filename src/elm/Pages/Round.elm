module Pages.Round
    exposing
        ( Model
        , Msg
        , init
        , view
        )

import Html exposing (..)
import Session as Session exposing (Session)


type alias Model =
    ()


type alias Msg =
    ()


init : Session -> ( Model, Cmd msg )
init session =
    ( (), Cmd.none )


view : Session -> Model -> Html Msg
view session model =
    div [] []
