module Pages.NewScore
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
import Session as Session exposing (Session)
import Storage


type alias Model =
    {}


type alias Msg =
    ()


init : ( Model, Cmd msg )
init =
    ( {}, Cmd.none )


update : Session -> Msg -> Model -> ( Model, Cmd Msg )
update session msg model =
    case msg of
        () ->
            ( model, Cmd.none )


view : Session -> Model -> Html Msg
view session model =
    div [] []
