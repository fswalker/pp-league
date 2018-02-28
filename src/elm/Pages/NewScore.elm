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
import Html.Events exposing (onInput, onClick)
import Date exposing (Date)
import Date.Extra exposing (toFormattedString, toUtcIsoString)
import Task
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
    , score1 : Int
    , score2 : Int
    , author : Maybe String
    , date : Maybe Date
    }


type FormPlayer
    = Player1
    | Player2


type Msg
    = UpdatePlayers (Maybe (List (Player (Entity {}))))
    | ChoosePlayer1 String
    | ChoosePlayer2 String
    | UpdateDate Date
    | UpdateScore1 Int
    | UpdateScore2 Int
    | AddNewScore Model


playerModel : User -> Model
playerModel user =
    let
        author =
            User.getName user
    in
        { emptyModel
            | leagueId = User.getLeagueId user
            , author = author
        }


emptyModel : Model
emptyModel =
    { leagueId = Nothing
    , leaguePlayers = Nothing
    , player1 = Nothing
    , player2 = Nothing
    , score1 = 0
    , score2 = 0
    , author = Nothing
    , date = Nothing
    }


init : Session -> ( Model, Cmd Msg )
init session =
    -- TODO allow admins choose league
    let
        getPlayersCmd =
            User.getLeagueId session.user
                |> Maybe.map Storage.getLeaguePlayers
                |> Maybe.withDefault Cmd.none

        getDateCmd =
            Task.perform UpdateDate Date.now
    in
        -- TODO set current session user as author
        playerModel session.user ! [ getPlayersCmd, getDateCmd ]


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

        ChoosePlayer1 pId ->
            let
                player =
                    model.leaguePlayers
                        |> Maybe.andThen (findPlayer (Just pId))
            in
                ( False, { model | player1 = player }, Cmd.none )

        ChoosePlayer2 pId ->
            let
                player =
                    model.leaguePlayers
                        |> Maybe.andThen (findPlayer (Just pId))
            in
                ( False, { model | player2 = player }, Cmd.none )

        UpdateScore1 score ->
            ( False, { model | score1 = score }, Cmd.none )

        UpdateScore2 score ->
            ( False, { model | score2 = score }, Cmd.none )

        UpdateDate date ->
            ( False, { model | date = Just date }, Cmd.none )

        AddNewScore _ ->
            let
                roundId =
                    Session.getRoundId session

                authorId =
                    User.getName session.user
            in
                case ( roundId, authorId ) of
                    ( Just rid, Just aid ) ->
                        getNewScore aid rid model
                            |> Storage.addNewScore
                            |> (,,) True model

                    ( _, _ ) ->
                        ( False, model, Cmd.none )


getNewScore :
    String
    -> String
    -> Model
    ->
        { authorId : String
        , player1 : String
        , player2 : String
        , score1 : Int
        , score2 : Int
        , date : String
        , league_id : String
        , round_id : String
        , id_ : String
        }
getNewScore authorId roundId model =
    let
        getPlayerId =
            (Maybe.map .id_) >> Maybe.andThen (\x -> x) >> Maybe.withDefault ""

        player1 =
            getPlayerId model.player1

        player2 =
            getPlayerId model.player2
    in
        { authorId = authorId
        , player1 = player1
        , player2 = player2
        , score1 = model.score1
        , score2 = model.score2
        , date = model.date |> Maybe.map toUtcIsoString |> Maybe.withDefault ""
        , league_id = model.leagueId |> Maybe.withDefault ""
        , round_id = roundId
        , id_ = createNewScoreId roundId player1 player2
        }


createNewScoreId : String -> String -> String -> String
createNewScoreId roundId player1Id player2Id =
    if player1Id <= player2Id then
        roundId ++ "_" ++ player1Id ++ "_" ++ player2Id
    else
        roundId ++ "_" ++ player2Id ++ "_" ++ player1Id


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
            [ h3 [ class "new-score-form-title is-size-3" ] [ text "Game Result" ]
            , div [ class "columns is-mobile" ]
                [ div [ class "column" ]
                    [ viewPlayerDropdown session.user model Player1 ChoosePlayer1 ]
                , div [ class "column" ]
                    [ viewPlayerDropdown session.user model Player2 ChoosePlayer2 ]
                ]
            , div [ class "columns is-mobile" ]
                [ div [ class "column" ]
                    [ viewScoreInput "Score 1" UpdateScore1 model.score1 ]
                , div [ class "column" ]
                    [ viewScoreInput "Score 2" UpdateScore2 model.score2 ]
                ]
            , div [ class "columns is-mobile" ]
                [ div [ class "column" ]
                    [ verticalFieldWrapper "Date" (text "") ]
                , div [ class "column" ]
                    [ displayDate model.date ]
                ]
            , div [ class "columns is-mobile" ]
                [ div [ class "column" ]
                    [ div [ class "level" ]
                        [ div [ class "level-left" ] []
                        , div [ class "level-right" ]
                            [ button
                                [ class "button level-item is-success"
                                , title "Add New Score button"
                                , disabled <| not <| isModelValid model
                                , onClick (AddNewScore model)
                                ]
                                [ text "Add" ]
                            ]
                        ]
                    ]
                ]
            ]
        ]


horizontalFieldWrapper : String -> Html msg -> Html msg
horizontalFieldWrapper =
    fieldWrapper True


verticalFieldWrapper : String -> Html msg -> Html msg
verticalFieldWrapper =
    fieldWrapper False


fieldWrapper : Bool -> String -> Html msg -> Html msg
fieldWrapper isHorizontal labelText control =
    div [ classList [ ( "field", True ), ( "is-horizontal", isHorizontal ) ] ]
        [ label [ class "label" ] [ text labelText ]
        , control
        ]


viewPlayerDropdown :
    User
    -> Model
    -> FormPlayer
    -> (String -> Msg)
    -> Html Msg
viewPlayerDropdown user model player msg =
    let
        ( labelText, thisPlayer, otherPlayer ) =
            if player == Player1 then
                ( "Player 1", model.player1, model.player2 )
            else
                ( "Player 2", model.player2, model.player1 )

        players =
            model.leaguePlayers

        isDisabled =
            player == Player1 && User.isPlayer user
    in
        p [ class "control is-expanded has-icons-left" ]
            [ span [ class "select is-fullwidth" ]
                [ select [ onInput msg, disabled isDisabled ]
                    (renderOptions thisPlayer otherPlayer players)
                ]
            , span [ class "icon is-small is-left" ]
                [ i [ class "fa fa-user" ] [] ]
            ]
            |> verticalFieldWrapper labelText


renderOptions :
    Maybe (Player (Entity {}))
    -> Maybe (Player (Entity {}))
    -> Maybe (List (Player (Entity {})))
    -> List (Html msg)
renderOptions thisPlayer otherPlayer players =
    option [ selected (thisPlayer == Nothing), value "" ] [ text "Choose player..." ]
        :: (players
                |> Maybe.withDefault []
                |> List.filter (\p -> p.id_ /= Nothing)
                |> List.filter (\p -> p.id_ /= (Maybe.andThen .id_ otherPlayer))
                |> List.sortBy .nick
                |> List.map (renderOption thisPlayer)
           )


renderOption : Maybe (Player (Entity {})) -> Player (Entity {}) -> Html msg
renderOption thisPlayer { id_, nick } =
    Maybe.map
        (\v ->
            option
                [ value v
                , selected (Just v == (Maybe.andThen .id_ thisPlayer))
                ]
                [ text nick ]
        )
        id_
        |> Maybe.withDefault (text "")


parseScore : String -> Int
parseScore =
    String.toInt >> (Result.withDefault 0)


viewScoreInput : String -> (Int -> Msg) -> Int -> Html Msg
viewScoreInput labelText updateAction score =
    div [ class "control is-expaned has-icons-left" ]
        [ input
            [ class "input"
            , type_ "number"
            , value <| toString score
            , Html.Attributes.min "0"
            , Html.Attributes.max "3"
            , onInput (parseScore >> updateAction)
            ]
            []
        , span [ class "icon is-small is-left" ]
            [ i [ class "fa fa-trophy" ] [] ]
        ]
        |> verticalFieldWrapper labelText


getFormattedDateString : String -> Maybe Date -> String
getFormattedDateString defaultStr date =
    date
        |> Maybe.map (toFormattedString "dd-MM-yyyy")
        |> Maybe.withDefault defaultStr


displayDate : Maybe Date -> Html msg
displayDate date =
    getFormattedDateString "Loading date..." date
        |> text
        |> List.singleton
        |> span [ class "is-size-6" ]


scoresAreValid : Model -> Bool
scoresAreValid model =
    (model.score1 >= 0 && model.score2 >= 0)
        && (model.score1 == 3 || model.score2 == 3)
        && (model.score1 /= model.score2)


playersAreValid : Model -> Bool
playersAreValid model =
    (model.player1 /= Nothing)
        && (model.player2 /= Nothing)
        && (model.player1 /= model.player2)


isModelValid : Model -> Bool
isModelValid model =
    (model.author /= Nothing)
        && (model.date /= Nothing)
        && (model.leagueId /= Nothing)
        && (scoresAreValid model)
        && (playersAreValid model)
