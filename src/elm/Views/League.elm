module Views.League exposing (createLeagueTable)

import Html exposing (Html, table, thead, tbody, tr, th, td, text, abbr)
import Html.Attributes exposing (class, title)
import Dict exposing (Dict)
import Data.PlayerStats exposing (PlayerStats)


createLeagueTable : Maybe String -> Dict String String -> List PlayerStats -> Html msg
createLeagueTable loggedInUser playersDict stats =
    table [ class "table is-striped league-table is-size-5" ]
        [ thead []
            [ th [] [ abbr [ title "Position" ] [ text "Pos" ] ]
            , th [] [ text "Player" ]
            , th [] [ abbr [ title "Games" ] [ text "G" ] ]
            , th [ class "emed" ] [ abbr [ title "Points" ] [ text "Pts" ] ]
            , th [] [ abbr [ title "Won Games" ] [ text "WG" ] ]
            , th [] [ abbr [ title "Lost Games" ] [ text "LG" ] ]
            , th [] [ abbr [ title "Won Sets" ] [ text "WS" ] ]
            , th [] [ abbr [ title "Lost Sets" ] [ text "LS" ] ]
            ]
        , tbody [] <|
            List.indexedMap (createRow loggedInUser playersDict) stats
        ]


createRow : Maybe String -> Dict String String -> Int -> PlayerStats -> Html msg
createRow loggedInUser playersDict i stats =
    tr
        [ class <| getSelectedRowClass <| isCurrentUser loggedInUser stats.id
        ]
        [ th [] [ text <| toString (i + 1) ++ "." ]
        , td [] [ text <| Maybe.withDefault "Unknown" <| Dict.get stats.id playersDict ]
        , td [] [ getText stats.games ]
        , td [ class "emed" ] [ getText stats.points ]
        , td [] [ getText stats.wonGames ]
        , td [] [ getText stats.lostGames ]
        , td [] [ getText stats.wonSets ]
        , td [] [ getText stats.lostSets ]
        ]


getText : Int -> Html msg
getText =
    toString >> text


isCurrentUser : Maybe String -> String -> Bool
isCurrentUser loggedInUser currentRowPlayer =
    loggedInUser == Just currentRowPlayer


getSelectedRowClass : Bool -> String
getSelectedRowClass isSelected =
    if isSelected then
        "has-text-weight-bold"
    else
        ""
