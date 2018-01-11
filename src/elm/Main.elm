port module Main exposing (..)

import Html exposing (..)
import Json.Decode as Decode
import Views.Page as Page
import Views.Loader as Loader
import Pages.Login as Login
import Pages.Home as Home
import Data.User exposing (User(..), userDecoder)
import Storage


-- TODO refactor loadig - move to the model or use union type


type Page
    = Loading
    | Login Login.Model
    | Home



-- MODEL


type alias Model =
    { user : User
    , page : Page
    }


init : ( Model, Cmd Msg )
init =
    let
        model =
            { user = Anonymous
            , page = Loading
            }
    in
        ( model, Storage.getSession () )



-- UPDATE


type Msg
    = LoginMsg Login.Msg
    | LogoutMsg
    | SessionMsg User


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( SessionMsg user, _ ) ->
            -- TODO routing - go to login page
            -- TODO refactor to function
            let
                page =
                    if user == Anonymous then
                        Login Login.init
                    else
                        Home
            in
                { model
                    | page = page
                    , user = user
                }
                    ! [ Cmd.none ]

        ( LoginMsg loginMsg, Login loginModel ) ->
            let
                ( newModel, loginCmd ) =
                    Login.update loginMsg loginModel
            in
                { model | page = Login newModel }
                    ! [ Cmd.map LoginMsg loginCmd ]

        ( LogoutMsg, _ ) ->
            { model
                | page = Login Login.init
                , user = Anonymous
            }
                ! [ Storage.logOut () ]

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
    let
        frame =
            Page.frame user LogoutMsg
    in
        case page of
            Loading ->
                Loader.loader
                    |> frame

            Login loginModel ->
                Login.view loginModel
                    |> Html.map LoginMsg
                    |> frame

            Home ->
                Home.view
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
