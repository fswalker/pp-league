port module Storage exposing (getSession, updateSession)

import Json.Decode exposing (Value)


port getSession : () -> Cmd msg


port updateSession : (Value -> msg) -> Sub msg
