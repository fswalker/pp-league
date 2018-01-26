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
import Data.User exposing (User(..))
import Data.Player exposing (Player)
import Data.Score exposing (Score)
import Storage exposing (..)


type Msg
    = UpdateActiveRound (Maybe Round)
    | UpdatePlayers (Maybe (List (Player (Entity {}))))
    | UpdateScores (Maybe (List (Score {})))


type alias Model =
    { activeRound : Maybe Round
    , leaguePlayersDict : Maybe (Dict String String)
    , scores : Maybe (List (Score {}))
    }


initialModel : Model
initialModel =
    { activeRound = Nothing
    , leaguePlayersDict = Nothing
    , scores = Nothing
    }


view : Model -> Html msg
view { activeRound } =
    case activeRound of
        Nothing ->
            text "Fetching active round or no round is active!"

        Just round ->
            div []
                [ div [ class "level" ]
                    [ h3 [ class "level-item is-size-3" ] [ text round.name ]
                    ]
                , div [ class "level" ]
                    [ text "" ]
                ]


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
                newModel =
                    { model
                        | leaguePlayersDict = createPlayersDict maybePlayers
                    }
            in
                ( not <| isDataLoadingDone newModel
                , newModel
                , Cmd.none
                )

        UpdateScores maybeScores ->
            let
                -- TODO map scores list to properly aggregated and sorted list
                newModel =
                    { model
                        | scores = maybeScores
                    }
            in
                ( not <| isDataLoadingDone newModel
                , newModel
                , Cmd.none
                )


tryCreatingGetScoresCommand : User -> (Maybe { a | id_ : Id } -> Cmd Msg)
tryCreatingGetScoresCommand user activeRound =
    case ( getLeagueId user, activeRound ) of
        ( Just lid, Just ar ) ->
            ar
                |> .id_
                |> (Maybe.map (((,) lid) >> Storage.getScores))
                |> Maybe.withDefault Cmd.none

        _ ->
            Cmd.none



-- (\ar ->
--     Storage.getScores ( league_id, ar.id_ ) |> Maybe.Just
-- >> (Maybe.withDefault Cmd.none)
-- canScoresBeLoaded : Model -> Bool
-- canScoresBeLoaded model =
--     model.leaguePlayersDict
--         /= Nothing
--         && model.activeRound
--         /= Nothing
--         && model.scores
--         == Nothing


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
    case getLeagueId user of
        Nothing ->
            initialModel ! []

        Just league_id ->
            initialModel
                ! [ Storage.getActiveRound ()
                  , Storage.getLeaguePlayers league_id
                  ]


getLeagueId : User -> Maybe String
getLeagueId user =
    case user of
        Anonymous ->
            Nothing

        Player { league_id } ->
            Just league_id

        Admin { league_id } ->
            Just league_id

        ServerAdmin { league_id } ->
            Just league_id


createPlayersDict : Maybe (List (Player (Entity {}))) -> Maybe (Dict String String)
createPlayersDict =
    Maybe.map
        (List.filterMap (\p -> p |> .id_ |> (Maybe.map (\id_ -> ( id_, p.nick ))))
            >> Dict.fromList
        )
