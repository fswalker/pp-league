module Pages.NewScore
    exposing
        ( Msg(..)
        , Model
        , init
        , update
        , view
        )

import Html exposing (..)
import Html.Attributes exposing (..)
import Data.Entity as Entity exposing (Entity)
import Data.Player as Player exposing (Player)
import Data.User as User exposing (User)
import Session as Session exposing (Session)
import Storage


type alias Model =
    { leagueId : Maybe String
    , leaguePlayers : Maybe (List (Player (Entity {})))
    , player1 : Maybe (Player (Entity {}))
    , player2 : Maybe (Player (Entity {}))
    }


type Msg
    = UpdatePlayers (Maybe (List (Player (Entity {}))))


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
                        |> trySetPlayer1 session.user players
            in
                ( False, newModel, Cmd.none )


findPlayer : Maybe String -> List (Player (Entity {})) -> Maybe (Player (Entity {}))
findPlayer userName players =
    players
        |> List.filter (\p -> p.id_ == userName)
        |> List.head


trySetPlayer1 : User -> Maybe (List (Player (Entity {}))) -> Model -> Model
trySetPlayer1 user players model =
    if User.isPlayer user && model.player1 == Nothing then
        { model | player1 = Maybe.andThen (findPlayer (User.getName user)) players }
    else
        model


view : Session -> Model -> Html Msg
view session model =
    div [ class "new-score-form columns is-centered" ]
        [ div [ class "column is-half-desktop is-two-thirds-tablet has-text-centered is-size-5" ]
            [ h3 [ class "new-score-form-title is-size-3" ] [ text "Match Result" ]
            , div [ class "columns is-mobile" ]
                [ div [ class "column" ]
                    [ viewPlayerDropdown "Player 1" model.player1 model.player2 model.leaguePlayers ]
                , div [ class "column" ]
                    [ viewPlayerDropdown "Player 2" model.player2 model.player1 model.leaguePlayers ]
                ]
            , div [ class "columns is-mobile" ]
                [ div [ class "column" ]
                    [ viewScoreInput "Score 1" ]
                , div [ class "column" ]
                    [ viewScoreInput "Score 2" ]
                ]
            , div [ class "columns is-mobile" ]
                [ div [ class "column" ]
                    [ text "Date" ]
                , div [ class "column" ]
                    []
                ]
            , div [ class "columns is-mobile" ]
                [ div [ class "column" ]
                    [ div [ class "level" ]
                        [ div [ class "level-left" ] []
                        , div [ class "level-right" ]
                            [ button [ class "button level-item is-success" ] [ text "Add" ]
                            ]
                        ]
                    ]
                ]
            ]
        ]


fieldWrapper : String -> Html msg -> Html msg
fieldWrapper labelText control =
    div [ class "field" ]
        [ label [ class "label" ] [ text labelText ]
        , control
        ]


viewPlayerDropdown :
    String
    -> Maybe (Player (Entity {}))
    -> Maybe (Player (Entity {}))
    -> Maybe (List (Player (Entity {})))
    -> Html msg
viewPlayerDropdown labelText thisPlayer otherPlayer players =
    p [ class "control is-expanded has-icons-left" ]
        [ span [ class "select is-fullwidth" ]
            [ select []
                (renderOptions players)
            ]
        , span [ class "icon is-small is-left" ]
            [ i [ class "fa fa-user" ] [] ]
        ]
        |> fieldWrapper labelText


renderOptions : Maybe (List (Player (Entity {}))) -> List (Html msg)
renderOptions players =
    option [ selected True ] [ text "Choose player..." ]
        :: (players
                |> Maybe.withDefault []
                |> List.filter (\p -> p.id_ /= Nothing)
                |> List.sortBy .nick
                |> List.map renderOption
           )


renderOption : Player (Entity {}) -> Html msg
renderOption { id_, nick } =
    Maybe.map
        (\v -> option [ value v ] [ text nick ])
        id_
        |> Maybe.withDefault (text "")


viewScoreInput : String -> Html msg
viewScoreInput labelText =
    div [ class "control is-expaned has-icons-left" ]
        [ input
            [ class "input"
            , type_ "number"
            , value "0"
            , Html.Attributes.min "0"
            , Html.Attributes.max "3"
            ]
            []
        , span [ class "icon is-small is-left" ]
            [ i [ class "fa fa-trophy" ] [] ]
        ]
        |> fieldWrapper labelText
