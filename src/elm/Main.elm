port module Main exposing (..)

import Html exposing (..)
import Json.Decode as Decode
import Navigation exposing (Location)
import Route exposing (Route)
import Storage
import Session as Session exposing (Session)
import Data.Entity as Entity exposing (Entity)
import Data.User as User exposing (User(..), userDecoder)
import Data.Round exposing (Round, roundDecoder)
import Data.Player exposing (Player, playersListDecoder)
import Data.Score exposing (Score, scoresListDecoder)
import Data.League exposing (League, leagueDecoder)
import Views.Page as Page
import Pages.Login as Login
import Pages.Home as Home
import Pages.NewScore as NewScore


type Page
    = Blank
    | Login Login.Model
    | Home Home.Model
    | NewScore NewScore.Model



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
    | UpdateLeaguePlayers (Maybe (List (Player (Entity {}))))
    | HomeMsg Home.Msg
    | NewScoreMsg NewScore.Msg


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

            Just Route.Login ->
                if isAuthenticated model.session.user then
                    ( model, Route.navigateTo Route.Home )
                else
                    { model
                        | page = Login (Login.init)
                        , isLoading = False
                    }
                        ! [ Cmd.none ]

            Just Route.Logout ->
                { model
                    | page = Blank
                    , session = Session.init
                    , isLoading = True
                }
                    ! [ Storage.logOut () ]

            Just Route.Home ->
                if isAuthenticated model.session.user then
                    let
                        ( homeModel, homeCmds ) =
                            Home.init model.session
                    in
                        { model
                            | page = Home homeModel
                            , isLoading = True
                        }
                            ! [ homeCmds |> Cmd.map HomeMsg ]
                else
                    model ! [ Route.navigateTo Route.Login ]

            Just Route.NewScore ->
                if isAuthenticated model.session.user then
                    let
                        ( scoreModel, scoreCmds ) =
                            NewScore.init model.session
                    in
                        { model
                            | page = NewScore scoreModel
                            , isLoading = True
                        }
                            ! [ scoreCmds |> Cmd.map NewScoreMsg ]
                else
                    model ! [ Route.navigateTo Route.Login ]


isAuthenticated : User -> Bool
isAuthenticated user =
    not <| User.isAnonymous user


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
            handleHomeMsg model homeMsg homeModel

        ( NewScoreMsg scoreMsg, NewScore scoreModel ) ->
            let
                ( isLoading, newModel, newCmd ) =
                    NewScore.update model.session scoreMsg scoreModel
            in
                { model
                    | page = NewScore newModel
                    , isLoading = isLoading
                }
                    ! [ Cmd.map NewScoreMsg newCmd ]

        ( UpdateLeaguePlayers players, Home homeModel ) ->
            handleHomeMsg model (Home.UpdatePlayers players) homeModel

        ( UpdateLeaguePlayers players, NewScore scoreModel ) ->
            handleNewScoreMsg model (NewScore.UpdatePlayers players) scoreModel

        ( s, m ) ->
            -- TODO create handler for each msg type - put case for model inside - the most safety
            Debug.crash <| "TODO Main" ++ toString s ++ " " ++ toString m



-- let
--     _ =
--         Debug.log "msg" s
--     _ =
--         Debug.log "model" m
-- in
--     model ! [ Cmd.none ]
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
                    |> Html.map HomeMsg
                    |> frame

            NewScore model ->
                NewScore.view session model
                    |> Html.map NewScoreMsg
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
                , Storage.updateActiveRound (decodeRound >> Session.UpdateRound >> SessionMsg)
                , Storage.updateLeaguePlayers (decodePlayers >> UpdateLeaguePlayers)
                , Storage.updateScores (decodeScores >> Home.UpdateScores >> HomeMsg)
                , Storage.newScoreAdded (\_ -> (NewScore.NewScoreAdded |> NewScoreMsg))
                ]


main : Program Never Model Msg
main =
    Navigation.program (Route.fromLocation >> SetRoute)
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


handleHomeMsg : Model -> Home.Msg -> Home.Model -> ( Model, Cmd Msg )
handleHomeMsg mainModel homeMessage homeModel =
    let
        ( isLoading, newHomeModel, newCmd ) =
            Home.update mainModel.session homeMessage homeModel
    in
        { mainModel
            | page = Home newHomeModel
            , isLoading = isLoading
        }
            ! [ Cmd.map HomeMsg newCmd ]


handleNewScoreMsg : Model -> NewScore.Msg -> NewScore.Model -> ( Model, Cmd Msg )
handleNewScoreMsg mainModel message scoreModel =
    let
        ( isLoading, newModel, newCmd ) =
            NewScore.update mainModel.session message scoreModel
    in
        { mainModel
            | page = NewScore newModel
            , isLoading = isLoading
        }
            ! [ Cmd.map NewScoreMsg newCmd ]
