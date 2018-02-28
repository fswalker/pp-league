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
import Session as Session exposing (Session)
import Data.User as User exposing (User(..))
import Data.Player exposing (Player)
import Data.Score exposing (Score)
import Data.PlayerStats as Stats exposing (PlayerStats)
import Data.Request as Request
import Storage exposing (..)
import Views.LeagueTable as LeagueTable


type Msg
    = UpdatePlayers (Maybe (List (Player (Entity {}))))
    | UpdateScores (Maybe (List (Score {})))


type alias HomeData =
    { leaguePlayersDict : Maybe (Dict String String)
    , scores : Maybe (List PlayerStats)
    }


type Model
    = Loading HomeData
    | ScoreTable HomeData


initialModel : Model
initialModel =
    Loading
        { leaguePlayersDict = Nothing
        , scores = Nothing
        }


view : Session -> Model -> Html Msg
view { user, league, activeRound } model =
    case model of
        Loading _ ->
            text "Fetching data..."

        ScoreTable { leaguePlayersDict, scores } ->
            case ( Request.toMaybe activeRound, leaguePlayersDict, scores ) of
                ( Just (Just round), Just playersDict, Just stats ) ->
                    div [ class "home-page" ]
                        [ div [ class "columns" ]
                            [ div [ class "column has-text-centered" ]
                                [ LeagueTable.create
                                    (User.getName user)
                                    playersDict
                                    stats
                                    (Request.toMaybe league |> Maybe.withDefault Nothing)
                                    round
                                ]
                            ]
                        ]

                _ ->
                    text "Could not load active round, players or scores data... TODO differentiate what is wrong"


update : Session -> Msg -> Model -> ( Bool, Model, Cmd Msg )
update ({ user, league, activeRound } as session) msg model =
    case ( msg, model ) of
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
                    Loading newModelData

                maybeActiveRound =
                    activeRound
                        |> Request.toMaybe
                        |> Maybe.withDefault Nothing
            in
                ( not <| isDataLoadingDone newModel
                , Loading newModelData
                , tryCreatingGetScoresCommand user maybeActiveRound
                )

        ( UpdateScores maybeScores, Loading m ) ->
            let
                newModelData =
                    { m
                        | scores = tryCalculatingScoresTable m.leaguePlayersDict maybeScores
                    }

                newModel =
                    ScoreTable newModelData
            in
                ( not <| isDataLoadingDone newModel
                , newModel
                , Cmd.none
                )

        ( _, _ ) ->
            -- TODO create handler for each msg type - put case for model inside - the most safety
            -- TODO or remove it and just add logging to DB
            Debug.crash "Investigate if this should be handled!!"


passUnchanged : Model -> ( Bool, Model, Cmd Msg )
passUnchanged model =
    ( False, model, Cmd.none )



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

        ScoreTable _ ->
            True


init : Session -> ( Model, Cmd Msg )
init { user, league } =
    case User.getLeagueId user of
        Nothing ->
            initialModel ! []

        Just league_id ->
            initialModel
                ! [ Storage.getLeaguePlayers league_id
                  ]


createPlayersDict : Maybe (List (Player (Entity {}))) -> Maybe (Dict String String)
createPlayersDict =
    Maybe.map
        (List.filterMap (\p -> p |> .id_ |> (Maybe.map (\id_ -> ( id_, p.nick ))))
            >> Dict.fromList
        )
