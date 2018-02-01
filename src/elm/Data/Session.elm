module Data.Session
    exposing
        ( Session
        , Msg(..)
        , init
        , update
        )

import Route exposing (Route)
import Data.Entity exposing (Entity)
import Data.User as User exposing (User(..))
import Data.League exposing (League)
import Storage


type Msg
    = UpdateUser User
    | UpdateLeague (Maybe (League {}))


type alias Session =
    { user : User
    , league : Maybe (League {})
    }


getCmd : Session -> Cmd msg
getCmd session =
    if session.user == Anonymous then
        Route.newUrl Route.Login
    else if session.league == Nothing then
        User.getLeagueId session.user
            |> Maybe.map Storage.getLeague
            |> Maybe.withDefault Cmd.none
    else
        Route.newUrl Route.Home


init : Session
init =
    { user = User.Anonymous
    , league = Nothing
    }


update : Msg -> Session -> ( Session, Cmd msg )
update msg session =
    case msg of
        UpdateUser u ->
            let
                newModel =
                    { session | user = u }
            in
                ( newModel, getCmd newModel )

        UpdateLeague ml ->
            let
                newModel =
                    { session | league = ml }
            in
                ( newModel, getCmd newModel )
