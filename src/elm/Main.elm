port module Main exposing (..)

import Html exposing (..)
import Json.Decode as Decode
import Navigation exposing (Location)
import UrlParser as Url
import Route exposing (Route)
import Views.Page as Page
import Views.Loader as Loader
import Pages.Login as Login
import Pages.Home as Home
import Data.User exposing (User(..), userDecoder)
import Storage


-- TODO refactor loadig - move to the model or use union type


type
    Page
    -- Rename Loading to Blank
    = Blank
    | Login Login.Model
    | Home



-- MODEL


type alias Model =
    { user : User
    , page : Page
    , isLoading : Bool
    }


initialModel : Model
initialModel =
    { user = Anonymous
    , page = Blank
    , isLoading = True
    }


init : Location -> ( Model, Cmd Msg )
init location =
    -- TODO handle different initial locations based on session data, model, and url location
    ( initialModel, Storage.getSession () )



-- UPDATE


type Msg
    = SetRoute (Maybe Route)
    | LoginMsg Login.Msg
    | LogoutMsg
    | SessionMsg User


setRoute : Maybe Route -> Model -> ( Model, Cmd Msg )
setRoute route model =
    let
        _ =
            Debug.log "setRoute" route
    in
        case route of
            Nothing ->
                -- TODO not found page here?
                { model | page = Blank, isLoading = True } ! [ Cmd.none ]

            Just Route.Home ->
                -- TODO
                { model | page = Home } ! [ Cmd.none ]

            Just Route.Login ->
                { model
                    | page = Login (Login.init)
                    , isLoading = False
                }
                    ! [ Cmd.none ]

            Just Route.Logout ->
                -- TODO
                { model | page = Login (Login.init) } ! [ Cmd.none ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( SetRoute maybeRoute, _ ) ->
            setRoute maybeRoute model

        ( SessionMsg user, _ ) ->
            -- TODO routing - go to login page
            handleSessionChange user model

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


handleSessionChange : User -> Model -> ( Model, Cmd Msg )
handleSessionChange user ({ page, isLoading } as model) =
    let
        command =
            if user == Anonymous then
                -- Login Login.init
                Route.newUrl Route.Login
            else
                -- TODO change url to home
                Route.newUrl Route.Home
    in
        { model
            | user = user
            , isLoading = True
        }
            ! [ command ]



-- VIEW


view : Model -> Html Msg
view { user, page, isLoading } =
    viewPage user page isLoading


viewPage : User -> Page -> Bool -> Html Msg
viewPage user page isLoading =
    -- TODO use session info to properly render all parts of the app
    let
        frame =
            Page.frame user isLoading
    in
        case page of
            Blank ->
                text ""
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
    Navigation.program (Route.fromLocation >> SetRoute)
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
