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
import Data.Entity exposing (Entity)
import Data.Round exposing (Round)
import Data.User exposing (User(..))
import Data.Player exposing (Player)
import Storage exposing (..)


type Msg
    = UpdateActiveRound (Maybe Round)
    | UpdatePlayers (Maybe (List (Player (Entity {}))))


type alias Model =
    { activeRound : Maybe Round
    , leaguePlayersDict : Maybe (Dict String String)
    }


initialModel : Model
initialModel =
    { activeRound = Nothing
    , leaguePlayersDict = Nothing
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


update : Bool -> Msg -> Model -> ( Bool, Model, Cmd Msg )
update isLoading msg model =
    case msg of
        UpdateActiveRound maybeRound ->
            ( model.leaguePlayersDict == Nothing
            , { model
                | activeRound = maybeRound
              }
            , Cmd.none
            )

        UpdatePlayers maybePlayers ->
            ( model.activeRound == Nothing
            , { model
                | leaguePlayersDict = createPlayersDict maybePlayers
              }
            , Cmd.none
            )


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
