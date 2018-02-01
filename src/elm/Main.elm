port module Main exposing (..)

import Html exposing (..)
import Json.Decode as Decode
import Navigation exposing (Location)
import Route exposing (Route)
import Views.Page as Page
import Pages.Login as Login
import Pages.Home as Home
import Data.User exposing (User(..), userDecoder)
import Data.Session as Session exposing (Session)
import Data.Round exposing (Round, roundDecoder)
import Data.Player exposing (Player, playersListDecoder)
import Data.Score exposing (Score, scoresListDecoder)
import Data.League exposing (League, leagueDecoder)
import Storage


type Page
    = Blank
    | Login Login.Model
    | Home Home.Model



-- MODEL


type alias Model =
    { session : Session
    , page : Page
    , isLoading : Bool
    }


initialModel : Model
initialModel =
    { session = Session.init
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
    | SessionMsg Session.Msg
    | HomeMsg Home.Msg


setRoute : Maybe Route -> Model -> ( Model, Cmd Msg )
setRoute route model =
    let
        _ =
            Debug.log "setRoute" route
    in
        case route of
            Nothing ->
                -- TODO not found page here?
                { model
                    | page = Blank
                    , isLoading = False
                }
                    ! [ Cmd.none ]

            Just Route.Home ->
                let
                    ( homeModel, homeCmds ) =
                        Home.init model.session
                in
                    if isUserAuthenticated model.session.user then
                        { model
                            | page = Home homeModel
                            , isLoading = True
                        }
                            ! [ homeCmds |> Cmd.map HomeMsg ]
                    else
                        model ! [ Route.newUrl Route.Login ]

            Just Route.Login ->
                if model.session.user /= Anonymous then
                    ( model, Route.newUrl Route.Home )
                else
                    { model
                        | page = Login (Login.init)
                        , isLoading = False
                    }
                        ! [ Cmd.none ]

            Just Route.Logout ->
                { model
                    | page = Blank
                    , session =
                        { user = Anonymous
                        , league = Nothing
                        }
                    , isLoading = True
                }
                    ! [ Storage.logOut () ]


isUserAuthenticated : User -> Bool
isUserAuthenticated user =
    case user of
        Anonymous ->
            False

        _ ->
            True


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( SetRoute maybeRoute, _ ) ->
            setRoute maybeRoute model

        ( SessionMsg msg, _ ) ->
            let
                ( newSession, cmd ) =
                    Session.update msg model.session
            in
                { model
                    | isLoading = True
                    , session = newSession
                }
                    ! [ cmd ]

        ( LoginMsg loginMsg, Login loginModel ) ->
            let
                ( newModel, loginCmd ) =
                    Login.update loginMsg loginModel
            in
                { model | page = Login newModel }
                    ! [ Cmd.map LoginMsg loginCmd ]

        -- TODO handle model and create handler function for that case!
        ( HomeMsg homeMsg, Home homeModel ) ->
            let
                ( isLoading, newModel, newCmd ) =
                    Home.update model.session homeMsg homeModel
            in
                { model
                    | page = Home newModel
                    , isLoading = isLoading
                }
                    ! [ Cmd.map HomeMsg newCmd ]

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
view { session, page, isLoading } =
    viewPage session page isLoading


viewPage : Session -> Page -> Bool -> Html Msg
viewPage session page isLoading =
    let
        frame =
            Page.frame session isLoading
    in
        case page of
            Blank ->
                text ""
                    |> frame

            Login model ->
                Login.view model
                    |> Html.map LoginMsg
                    |> frame

            Home model ->
                Home.view session model
                    |> frame


subscriptions : Model -> Sub Msg
subscriptions =
    let
        decodeUser =
            Decode.decodeValue userDecoder
                >> (Result.withDefault Anonymous)

        decodeRound =
            Decode.decodeValue roundDecoder
                >> Result.toMaybe

        decodeLeague =
            Decode.decodeValue leagueDecoder
                >> Result.toMaybe

        decodePlayers =
            Decode.decodeValue playersListDecoder
                >> Result.toMaybe

        decodeScores =
            Decode.decodeValue scoresListDecoder
                >> Result.toMaybe
    in
        \_ ->
            Sub.batch
                [ Storage.updateSession (decodeUser >> Session.UpdateUser >> SessionMsg)
                , Storage.updateLeague (decodeLeague >> Session.UpdateLeague >> SessionMsg)
                , Storage.updateActiveRound (decodeRound >> Home.UpdateActiveRound >> HomeMsg)
                , Storage.updateLeaguePlayers (decodePlayers >> Home.UpdatePlayers >> HomeMsg)
                , Storage.updateScores (decodeScores >> Home.UpdateScores >> HomeMsg)
                ]


main : Program Never Model Msg
main =
    Navigation.program (Route.fromLocation >> SetRoute)
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
