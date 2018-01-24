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
import Data.Round exposing (Round)
import Data.User exposing (User(..))
import Data.Player exposing (Player)
import Storage exposing (..)


type Msg
    = UpdateActiveRound (Maybe Round)


type alias Model =
    { activeRound : Maybe Round
    , leaguePlayers : Maybe (List (Player {}))
    }


initialModel : Model
initialModel =
    { activeRound = Nothing
    , leaguePlayers = Nothing
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
            ( model.leaguePlayers == Nothing
            , { model
                | activeRound = maybeRound
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
