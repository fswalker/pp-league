module Pages.Home
    exposing
        ( Model
        , Msg(..)
        , init
        , view
        , update
        )

import Html exposing (..)
import Html.Attributes exposing (..)
import Dict exposing (Dict, fromList)
import Data.Entity exposing (Entity, Id)
import Data.Round exposing (Round)
import Data.User as User exposing (User(..))
import Data.Player exposing (Player)
import Data.Score exposing (Score)
import Data.PlayerStats as Stats exposing (PlayerStats)
import Storage exposing (..)
import Views.League as League


type Msg
    = UpdateActiveRound (Maybe Round)
    | UpdatePlayers (Maybe (List (Player (Entity {}))))
    | UpdateScores (Maybe (List (Score {})))


type alias Model =
    { activeRound : Maybe Round
    , leaguePlayersDict : Maybe (Dict String String)
    , scores : Maybe (List PlayerStats)
    }


initialModel : Model
initialModel =
    { activeRound = Nothing
    , leaguePlayersDict = Nothing
    , scores = Nothing
    }


view : User -> Model -> Html msg
view user { activeRound, leaguePlayersDict, scores } =
    case ( activeRound, leaguePlayersDict, scores ) of
        ( Just round, Just playersDict, Just stats ) ->
            div [ class "columns" ]
                [ div [ class "column has-text-centered" ]
                    [ h3 [ class "is-size-3" ] [ text round.name ]
                    , h4 [ class "league-name is-size-4 has-text-left has-text-weight-bold" ] [ text "TODO League name" ]
                    , League.createLeagueTable (User.getName user) playersDict stats
                    ]
                ]

        _ ->
            text "Fetching data..."


update : User -> Msg -> Model -> ( Bool, Model, Cmd Msg )
update user msg model =
    case msg of
        UpdateActiveRound maybeRound ->
            let
                newModel =
                    { model
                        | activeRound = maybeRound
                    }
            in
                ( not <| isDataLoadingDone newModel
                , newModel
                , tryCreatingGetScoresCommand user maybeRound
                )

        UpdatePlayers maybePlayers ->
            let
                playersDict =
                    createPlayersDict maybePlayers

                usersIds =
                    getUsersIds playersDict

                stats =
                    Maybe.withDefault [] model.scores

                newModel =
                    { model
                        | leaguePlayersDict = playersDict
                        , scores = Just <| Stats.recalculateScoresTableForUsers usersIds stats
                    }
            in
                ( not <| isDataLoadingDone newModel
                , newModel
                , Cmd.none
                )

        UpdateScores maybeScores ->
            let
                newModel =
                    { model
                        | scores = tryCalculatingScoresTable model.leaguePlayersDict maybeScores
                    }
            in
                ( not <| isDataLoadingDone newModel
                , newModel
                , Cmd.none
                )


getUsersIds : Maybe (Dict String String) -> List String
getUsersIds =
    Maybe.withDefault Dict.empty
        >> Dict.keys


tryCalculatingScoresTable : Maybe (Dict String String) -> Maybe (List (Score {})) -> Maybe (List PlayerStats)
tryCalculatingScoresTable mUsers mScores =
    let
        users =
            getUsersIds mUsers

        scores =
            Maybe.withDefault [] mScores
    in
        Stats.calculateScoresTable users scores
            |> Just


tryCreatingGetScoresCommand : User -> (Maybe { a | id_ : Id } -> Cmd Msg)
tryCreatingGetScoresCommand user activeRound =
    case ( User.getLeagueId user, activeRound ) of
        ( Just lid, Just ar ) ->
            ar
                |> .id_
                |> (Maybe.map (((,) lid) >> Storage.getScores))
                |> Maybe.withDefault Cmd.none

        _ ->
            Cmd.none


isDataLoadingDone : Model -> Bool
isDataLoadingDone model =
    model.leaguePlayersDict
        /= Nothing
        && model.activeRound
        /= Nothing
        && model.scores
        /= Nothing


init : User -> ( Model, Cmd Msg )
init user =
    case User.getLeagueId user of
        Nothing ->
            initialModel ! []

        Just league_id ->
            initialModel
                ! [ Storage.getActiveRound ()
                  , Storage.getLeaguePlayers league_id
                  ]


createPlayersDict : Maybe (List (Player (Entity {}))) -> Maybe (Dict String String)
createPlayersDict =
    Maybe.map
        (List.filterMap (\p -> p |> .id_ |> (Maybe.map (\id_ -> ( id_, p.nick ))))
            >> Dict.fromList
        )
