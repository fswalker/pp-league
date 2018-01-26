module Data.PlayerStats
    exposing
        ( PlayerStats
        , calculateScoresTable
        , mergePlayerStats
        , comparePlayerStats
        )

import Dict as Dict exposing (Dict)
import Data.Score exposing (Score)


type alias PlayerStats =
    { id : String
    , games : Int
    , points : Int
    , wonGames : Int
    , lostGames : Int
    , wonSets : Int
    , lostSets : Int
    }


initPlayerStats : ( String, String ) -> PlayerStats
initPlayerStats ( user_id, _ ) =
    PlayerStats user_id 0 0 0 0 0 0


getPlayersStats : Score {} -> List PlayerStats
getPlayersStats score =
    if score.score1 < score.score2 then
        [ PlayerStats score.player1 1 1 0 1 score.score1 score.score2
        , PlayerStats score.player2 1 2 1 0 score.score2 score.score1
        ]
    else
        [ PlayerStats score.player1 1 2 1 0 score.score1 score.score2
        , PlayerStats score.player2 1 1 0 1 score.score2 score.score1
        ]


calculateScoresTable : List ( String, String ) -> List (Score {}) -> List PlayerStats
calculateScoresTable users scores =
    [ List.map initPlayerStats users
    , List.concatMap getPlayersStats scores
    ]
        |> List.concat
        |> List.foldl aggregateScoreWithStats Dict.empty
        |> Dict.values
        |> List.sortWith comparePlayerStats
        |> List.reverse



-- 3. foldl scores to dictionary of users and their stats
-- 4. dict 2 list
-- 5. custom sort


aggregateScoreWithStats : PlayerStats -> Dict String PlayerStats -> Dict String PlayerStats
aggregateScoreWithStats singleStat =
    let
        updateDict mv =
            case mv of
                Nothing ->
                    Just singleStat

                Just v ->
                    mergePlayerStats singleStat v
    in
        Dict.update singleStat.id updateDict


mergePlayerStats : PlayerStats -> PlayerStats -> Maybe PlayerStats
mergePlayerStats ps1 ps2 =
    if ps1.id == ps2.id then
        { id = ps1.id
        , games = ps1.games + ps2.games
        , points = ps1.points + ps2.points
        , wonGames = ps1.wonGames + ps2.wonGames
        , lostGames = ps1.lostGames + ps2.lostGames
        , wonSets = ps1.wonSets + ps2.wonSets
        , lostSets = ps1.lostSets + ps2.lostSets
        }
            |> Just
    else
        Nothing


comparePlayerStats : PlayerStats -> PlayerStats -> Order
comparePlayerStats ps1 ps2 =
    if ps1.points > ps2.points then
        GT
    else if ps1.points < ps2.points then
        LT
    else if ps1.wonGames > ps2.wonGames then
        GT
    else if ps1.wonGames < ps2.wonGames then
        LT
    else if ps1.lostGames < ps2.lostGames then
        GT
    else if ps1.lostGames > ps2.lostGames then
        LT
    else if ps1.wonSets > ps2.wonSets then
        GT
    else if ps1.wonSets < ps2.wonSets then
        LT
    else if ps1.lostSets < ps2.lostSets then
        GT
    else if ps1.lostSets > ps2.lostSets then
        LT
    else
        compare ps2.id ps1.id
