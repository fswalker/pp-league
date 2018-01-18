module Pages.Home
    exposing
        ( Model
        , Msg(..)
        , initialModel
        , view
        , update
        )

import Html exposing (..)
import Data.Round exposing (Round)


type Msg
    = UpdateActiveRound (Maybe Round)


type alias Model =
    { activeRound : Maybe Round
    }


initialModel =
    { activeRound = Nothing }


view : Model -> Html msg
view { activeRound } =
    case activeRound of
        Nothing ->
            text "Fetching active round or no round is active!"

        Just round ->
            text round.name


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateActiveRound maybeRound ->
            { model | activeRound = maybeRound } ! [ Cmd.none ]
