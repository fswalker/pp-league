module Data.User exposing (User, Role(..))


type Role
    = Anonymous
    | Player


type alias User =
    { role : Role }
