port module Storage
    exposing
        ( getSession
        , updateSession
        , logIn
        , logOut
        )

import Json.Decode exposing (Value)


port getSession : () -> Cmd msg


port updateSession : (Value -> msg) -> Sub msg


port logIn : { login : String, password : String } -> Cmd msg


port logOut : () -> Cmd msg
