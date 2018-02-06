port module Storage
    exposing
        ( logIn
        , logOut
        , getSession
        , updateSession
        , getActiveRound
        , updateActiveRound
        , getLeaguePlayers
        , updateLeaguePlayers
        , getScores
        , updateScores
        , getLeague
        , updateLeague
        )

import Json.Decode exposing (Value)


port logIn : { login : String, password : String } -> Cmd msg


port logOut : () -> Cmd msg


port getSession : () -> Cmd msg


port updateSession : (Value -> msg) -> Sub msg


port getActiveRound : () -> Cmd msg


port updateActiveRound : (Value -> msg) -> Sub msg


port getLeaguePlayers : String -> Cmd msg


port updateLeaguePlayers : (Value -> msg) -> Sub msg



-- TODO change to record!
-- league_id, round_id


port getScores : ( String, String ) -> Cmd msg


port updateScores : (Value -> msg) -> Sub msg


port getLeague : String -> Cmd msg


port updateLeague : (Value -> msg) -> Sub msg
