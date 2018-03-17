module Pages.Round
    exposing
        ( Model
        , Msg(..)
        , init
        , view
        , update
        )

import Html exposing (..)
import Session as Session exposing (Session)
import Data.League exposing (League)
import Storage


type alias Model =
    { leagues : Maybe (List (League {})) }


type Msg
    = UpdateAllLeagues (Maybe (List (League {})))


initialModel : Model
initialModel =
    { leagues = Nothing }


init : Session -> ( Model, Cmd msg )
init session =
    ( initialModel, Storage.getAllLeagues () )


update : Session -> Msg -> Model -> ( Bool, Model, Cmd Msg )
update session msg model =
    case msg of
        UpdateAllLeagues mLeagues ->
            let
                newModel =
                    { model
                        | leagues = mLeagues
                    }
            in
                ( True, newModel, Cmd.none )


view : Session -> Model -> Html Msg
view session model =
    div [] []
