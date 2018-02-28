module Session
    exposing
        ( Session
        , Msg(..)
        , init
        , update
        , getRoundId
        )

import Route exposing (Route)
import Data.User as User exposing (User(..))
import Data.League exposing (League)
import Data.Round exposing (Round)
import Data.Request exposing (Request(..))
import Storage


type Msg
    = UpdateUser User
    | UpdateLeague (Maybe (League {}))
    | UpdateRound (Maybe Round)


type alias Session =
    { user : User
    , league : Request (Maybe (League {}))
    , activeRound : Request (Maybe Round)
    }


init : Session
init =
    { user = User.Anonymous
    , league = NotStarted
    , activeRound = NotStarted
    }


fetchDataForUser : Session -> ( Session, Cmd msg )
fetchDataForUser session =
    if session.user == Anonymous then
        ( session, Route.navigateTo Route.Login )
    else
        { session
            | league = Loading
            , activeRound = Loading
        }
            ! [ getLeagueCmd session
              , getRoundCmd session
              ]


getLeagueCmd : Session -> Cmd msg
getLeagueCmd session =
    if session.league == NotStarted then
        User.getLeagueId session.user
            |> Maybe.map Storage.getLeague
            |> Maybe.withDefault Cmd.none
    else
        Cmd.none


getRoundCmd : Session -> Cmd msg
getRoundCmd session =
    if session.activeRound == NotStarted then
        Storage.getActiveRound ()
    else
        Cmd.none


getRouteHomeCmd : Session -> Session -> Cmd msg
getRouteHomeCmd oldSession { league, activeRound } =
    case ( oldSession.league, league, oldSession.activeRound, activeRound ) of
        ( Loading, Ready _, Ready _, Ready _ ) ->
            Route.navigateTo Route.Home

        ( Ready _, Ready _, Loading, Ready _ ) ->
            Route.navigateTo Route.Home

        _ ->
            Cmd.none


update : Msg -> Session -> ( Session, Cmd msg )
update msg session =
    case msg of
        UpdateUser u ->
            let
                newModel =
                    { session | user = u }
            in
                fetchDataForUser newModel

        UpdateLeague ml ->
            let
                newSession =
                    { session | league = Ready ml }
            in
                ( newSession, getRouteHomeCmd session newSession )

        UpdateRound mr ->
            let
                newSession =
                    { session | activeRound = Ready mr }
            in
                ( newSession, getRouteHomeCmd session newSession )


getRoundId : Session -> Maybe String
getRoundId { activeRound } =
    case activeRound of
        NotStarted ->
            Nothing

        Loading ->
            Nothing

        Ready v ->
            Maybe.andThen .id_ v
