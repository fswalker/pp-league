port module Main exposing (..)

import Html exposing (..)
import Json.Decode as Decode
import Views.Page exposing (frame)
import Views.Loader as Loader
import Pages.Login as Login
import Data.User exposing (User(..), userDecoder)
import Storage


type Page
    = Loading
    | Login Login.Model



-- MODEL


type alias Model =
    { user : User
    , page : Page

    -- TODO page
    }


init : ( Model, Cmd Msg )
init =
    let
        model =
            { user = Anonymous

            -- , page = Login Login.init
            , page = Loading
            }
    in
        -- TODO command to fetch session info and based on that load login page or fetch user data
        ( model, Storage.getSession () )



-- UPDATE


type Msg
    = LoginMsg Login.Msg
    | SessionMsg User


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( SessionMsg user, Loading ) ->
            -- TODO routing - go to login page
            { model | page = Login Login.init }
                ! [ Cmd.none ]

        ( LoginMsg loginMsg, Login loginModel ) ->
            let
                ( newModel, loginCmd ) =
                    Login.update loginMsg loginModel
            in
                { model | page = Login newModel }
                    ! [ Cmd.map LoginMsg loginCmd ]

        ( s, m ) ->
            let
                _ =
                    Debug.log "msg" s

                _ =
                    Debug.log "model" m
            in
                model ! [ Cmd.none ]



-- VIEW


view : Model -> Html Msg
view { user, page } =
    viewPage user page


viewPage : User -> Page -> Html Msg
viewPage user page =
    -- TODO use session info to properly render all parts of the app
    case page of
        Loading ->
            Loader.loader
                |> frame

        Login loginModel ->
            Login.view loginModel
                |> Html.map LoginMsg
                |> frame


subscriptions : Model -> Sub Msg
subscriptions =
    let
        decodeUser =
            Decode.decodeValue userDecoder
                >> (Result.withDefault Anonymous)
    in
        \_ -> Storage.updateSession (decodeUser >> SessionMsg)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
