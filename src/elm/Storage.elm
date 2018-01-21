port module Storage
    exposing
        ( logIn
        , logOut
        , getSession
        , updateSession
        , getActiveRound
        , updateActiveRound
        )

import Json.Decode exposing (Value)


port logIn : { login : String, password : String } -> Cmd msg


port logOut : () -> Cmd msg


port getSession : () -> Cmd msg


port updateSession : (Value -> msg) -> Sub msg


port getActiveRound : () -> Cmd msg


port updateActiveRound : (Value -> msg) -> Sub msg


port getLeaguePlayers : () -> Cmd msg


port updateLeaguePlayers : (Value -> msg) -> Sub msg
