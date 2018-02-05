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
import Html.Events exposing (..)
import Dict exposing (Dict, fromList)
import Data.Entity exposing (Entity, Id)
import Data.Round exposing (Round)
import Session as Session exposing (Session)
import Data.User as User exposing (User(..))
import Data.Player exposing (Player)
import Data.Score exposing (Score)
import Data.PlayerStats as Stats exposing (PlayerStats)
import Storage exposing (..)
import Views.LeagueTable as LeagueTable
import Views.Home.NewScore as NewScore


type Msg
    = UpdateActiveRound (Maybe Round)
    | UpdatePlayers (Maybe (List (Player (Entity {}))))
    | UpdateScores (Maybe (List (Score {})))
    | ShowNewScoreForm
    | ShowLeagueTable
    | NewScoreFormMsg NewScore.Msg


type alias HomeData =
    { activeRound : Maybe Round
    , leaguePlayersDict : Maybe (Dict String String)
    , scores : Maybe (List PlayerStats)
    }


type Model
    = Loading HomeData
    | ScoreTable HomeData
    | ScoreForm ( HomeData, NewScore.Model )


initialModel : Model
initialModel =
    Loading
        { activeRound = Nothing
        , leaguePlayersDict = Nothing
        , scores = Nothing
        }


view : Session -> Model -> Html Msg
view { user, league } model =
    case model of
        Loading _ ->
            text "Fetching data..."

        ScoreTable { activeRound, leaguePlayersDict, scores } ->
            case ( activeRound, leaguePlayersDict, scores ) of
                ( Just round, Just playersDict, Just stats ) ->
                    div [ class "home-page" ]
                        [ addNewScoreSection
                        , div [ class "columns" ]
                            [ div [ class "column has-text-centered" ]
                                [ LeagueTable.create (User.getName user) playersDict stats league round.name
                                ]
                            ]
                        ]

                _ ->
                    text "Could not load active round, players or scores data... TODO differentiate what is wrong"

        ScoreForm _ ->
            NewScore.view
                |> Html.map NewScoreFormMsg


update : Session -> Msg -> Model -> ( Bool, Model, Cmd Msg )
update ({ user, league } as session) msg model =
    case ( msg, model ) of
        ( UpdateActiveRound maybeRound, (Loading _) as m ) ->
            updateActiveRoundHandler user maybeRound m

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
                        ScoreTable newModelData
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
                        ScoreTable newModelData
                    else
                        Loading newModelData
            in
                ( not <| isDataLoadingDone newModel
                , newModel
                , Cmd.none
                )

        ( ShowNewScoreForm, ScoreTable data ) ->
            ( False
            , ScoreForm ( data, initNewScoreFormData session )
            , Cmd.none
            )

        ( ShowNewScoreForm, _ ) ->
            passUnchanged model

        ( NewScoreFormMsg nsMsg, (ScoreForm _) as sfModel ) ->
            -- TODO handle commands?
            ( False
            , handleNewScoreFormMsg nsMsg sfModel
            , Cmd.none
            )

        ( _, _ ) ->
            -- TODO create handler for each msg type - put case for model inside - the most safety
            -- TODO or remove it and just add logging to DB
            Debug.crash "Investigate if this should be handled!!"


handleNewScoreFormMsg : NewScore.Msg -> Model -> Model
handleNewScoreFormMsg msg model =
    case model of
        ScoreForm ( homeData, formData ) ->
            if msg == NewScore.Cancel then
                ScoreTable homeData
            else
                let
                    -- TODO Task ??
                    updatedNewScoreFormModel =
                        NewScore.update msg formData
                in
                    ScoreForm ( homeData, updatedNewScoreFormModel )

        _ ->
            model


updateActiveRoundHandler : User -> Maybe Round -> Model -> ( Bool, Model, Cmd Msg )
updateActiveRoundHandler user maybeRound model =
    case model of
        Loading m ->
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

        ScoreTable m ->
            passUnchanged model

        ScoreForm m ->
            passUnchanged model


initNewScoreFormData : Session -> NewScore.Model
initNewScoreFormData { user, league } =
    { player1 = User.getName user }


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

        ScoreForm _ ->
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


addNewScoreSection : Html Msg
addNewScoreSection =
    div [ class "level" ]
        [ div [ class "level-left" ] []
        , div [ class "level-right" ]
            [ div [ class "level-item" ]
                [ button
                    [ class "button is-rounded is-success"
                    , title "New Score button"
                    , onClick ShowNewScoreForm
                    ]
                    [ text "New Score" ]
                ]
            ]
        ]
