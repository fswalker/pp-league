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
import Data.Session as Session exposing (Session)
import Data.User as User exposing (User(..))
import Data.League exposing (League)
import Data.Player exposing (Player)
import Data.Score exposing (Score)
import Data.PlayerStats as Stats exposing (PlayerStats)
import Storage exposing (..)
import Views.League as League


type Msg
    = UpdateActiveRound (Maybe Round)
    | UpdatePlayers (Maybe (List (Player (Entity {}))))
    | UpdateScores (Maybe (List (Score {})))


type alias HomeData =
    { activeRound : Maybe Round
    , leaguePlayersDict : Maybe (Dict String String)
    , scores : Maybe (List PlayerStats)
    , league : Maybe (League (Entity {}))
    }


type Model
    = Loading HomeData
    | Display HomeData


initialModel : Model
initialModel =
    Loading
        { activeRound = Nothing
        , leaguePlayersDict = Nothing
        , scores = Nothing
        , league = Nothing
        }


view : Session -> Model -> Html msg
view { user, league } model =
    case model of
        Loading _ ->
            text "Fetching data..."

        Display { activeRound, leaguePlayersDict, scores } ->
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
                    text "Could not load active round, players or scores data... TODO differentiate what is wrong"


update : Session -> Msg -> Model -> ( Bool, Model, Cmd Msg )
update { user, league } msg model =
    case ( msg, model ) of
        ( UpdateActiveRound maybeRound, Loading m ) ->
            let
                newModel =
                    Loading
                        { m
                            | activeRound = maybeRound
                        }
            in
                ( not <| isDataLoadingDone newModel
                , newModel
                , tryCreatingGetScoresCommand user maybeRound
                )

        ( UpdatePlayers maybePlayers, Loading m ) ->
            let
                playersDict =
                    createPlayersDict maybePlayers

                usersIds =
                    getUsersIds playersDict

                stats =
                    Maybe.withDefault [] m.scores

                newModelData =
                    { m
                        | leaguePlayersDict = playersDict
                        , scores = Just <| Stats.recalculateScoresTableForUsers usersIds stats
                    }

                newModel =
                    if m.scores /= Nothing then
                        Display newModelData
                    else
                        Loading newModelData
            in
                ( not <| isDataLoadingDone newModel
                , newModel
                , Cmd.none
                )

        ( UpdateScores maybeScores, Loading m ) ->
            let
                newModelData =
                    { m
                        | scores = tryCalculatingScoresTable m.leaguePlayersDict maybeScores
                    }

                newModel =
                    if m.leaguePlayersDict /= Nothing then
                        Display newModelData
                    else
                        Loading newModelData
            in
                ( not <| isDataLoadingDone newModel
                , newModel
                , Cmd.none
                )

        ( _, _ ) ->
            Debug.crash "Investigate if this should be handled!!"



-- TODO log error!!
-- (False, model, Cmd.none)


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
    case model of
        Loading _ ->
            False

        Display _ ->
            True


init : Session -> ( Model, Cmd Msg )
init { user, league } =
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
