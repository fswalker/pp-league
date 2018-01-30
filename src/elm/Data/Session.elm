module Data.Session exposing (Session)

import Data.Entity exposing (Entity)
import Data.User exposing (User)
import Data.League exposing (League)


type alias Session =
    { user : User
    , league : Maybe (League (Entity {}))
    }
