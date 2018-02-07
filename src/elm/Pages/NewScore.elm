module Pages.NewScore
    exposing
        ( Msg(..)
        , Model
        , init
        , update
        , view
        )

import Html exposing (..)
import Data.Entity as Entity exposing (Entity)
import Data.Player as Player exposing (Player)
import Data.User as User exposing (User)
import Session as Session exposing (Session)
import Storage
import Views.Home.NewScore as NewScoreView


type alias Model =
    { leagueId : Maybe String
    , leaguePlayers : Maybe (List (Player (Entity {})))
    , player1 : Maybe (Player (Entity {}))
    , player2 : Maybe (Player (Entity {}))
    }


type Msg
    = UpdatePlayers (Maybe (List (Player (Entity {}))))
    | FormMsg NewScoreView.Msg


playerModel : User -> Model
playerModel user =
    { emptyModel | leagueId = User.getLeagueId user }


emptyModel : Model
emptyModel =
    { leagueId = Nothing
    , leaguePlayers = Nothing
    , player1 = Nothing
    , player2 = Nothing
    }


init : Session -> ( Model, Cmd msg )
init session =
    if User.isPlayer session.user then
        let
            getPlayersCmd =
                User.getLeagueId session.user
                    |> Maybe.map Storage.getLeaguePlayers
                    |> Maybe.withDefault Cmd.none
        in
            ( playerModel session.user, getPlayersCmd )
    else
        ( emptyModel, Cmd.none )


update : Session -> Msg -> Model -> ( Bool, Model, Cmd Msg )
update session msg model =
    case msg of
        UpdatePlayers players ->
            let
                newModel =
                    { model | leaguePlayers = players }
                        |> setPlayer1 session.user players
            in
                ( False, newModel, Cmd.none )

        FormMsg formMsg ->
            ( False, model, Cmd.none )


view : Session -> Model -> Html Msg
view session model =
    NewScoreView.view
        |> Html.map FormMsg


findPlayer : Maybe String -> List (Player (Entity {})) -> Maybe (Player (Entity {}))
findPlayer userName players =
    players
        |> List.filter (\p -> p.id_ == userName)
        |> List.head


setPlayer1 : User -> Maybe (List (Player (Entity {}))) -> Model -> Model
setPlayer1 user players model =
    if User.isPlayer user then
        { model | player1 = Maybe.andThen (findPlayer (User.getName user)) players }
    else
        model
