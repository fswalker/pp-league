port module Main exposing (..)

import Html exposing (Html, div, h1, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Views.Page exposing (frame)


type User
    = Anonymous



-- MODEL


type alias Model =
    { user : User
    }


model : Model
model =
    { user = Anonymous
    }


init : ( Model, Cmd Msg )
init =
    ( model, Cmd.none )



-- PORTS
-- UPDATE


type Msg
    = String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    frame


subscriptions : Model -> Sub Msg
subscriptions =
    \_ -> Sub.none


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
