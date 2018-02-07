module Data.User
    exposing
        ( User(..)
        , userDecoder
        , getLeagueId
        , getName
        , isAnonymous
        , isPlayer
        )

import Json.Decode as Decode exposing (Decoder)
import Data.Entity exposing (Entity, Id)
import Data.Player exposing (Player)


type alias UserMetadata a =
    { a | name : String }


type User
    = Anonymous
    | Player (Player (Entity (UserMetadata {})))
    | Admin (Player (Entity (UserMetadata {})))
    | ServerAdmin (Player (Entity (UserMetadata {})))


buildUser : Maybe String -> Maybe String -> String -> String -> String -> Player (Entity (UserMetadata {}))
buildUser id_ rev_ nick league_id name =
    { id_ = id_
    , rev_ = rev_
    , nick = nick
    , league_id = league_id
    , name = name
    }


metadataDecoder : Decoder (Player (Entity (UserMetadata {})))
metadataDecoder =
    Decode.map5 buildUser
        (Decode.maybe (Decode.field "_id" Decode.string))
        (Decode.maybe (Decode.field "_rev" Decode.string))
        (Decode.field "nick" Decode.string)
        (Decode.field "league_id" Decode.string)
        (Decode.field "name" Decode.string)


rolesDecoder : Decoder (List String)
rolesDecoder =
    Decode.field "roles" (Decode.list Decode.string)


userDecoder : Decoder User
userDecoder =
    rolesDecoder
        |> Decode.andThen
            (\roles ->
                let
                    roleExists role =
                        List.any ((==) role) roles

                    wrapMetadataWithRole role =
                        Decode.map role metadataDecoder
                in
                    if roleExists "_admin" then
                        wrapMetadataWithRole ServerAdmin
                    else if roleExists "admin" then
                        wrapMetadataWithRole Admin
                    else if roleExists "player" then
                        wrapMetadataWithRole Player
                    else
                        Decode.succeed Anonymous
            )


getLeagueId : User -> Maybe String
getLeagueId =
    getUser .league_id


getName : User -> Maybe String
getName =
    getUser .name


isAnonymous : User -> Bool
isAnonymous =
    (==) Anonymous


isPlayer : User -> Bool
isPlayer user =
    case user of
        Player _ ->
            True

        _ ->
            False


getUser : (Player (Entity (UserMetadata {})) -> a) -> User -> Maybe a
getUser getter user =
    case user of
        Anonymous ->
            Nothing

        Player u ->
            Just <| getter u

        Admin u ->
            Just <| getter u

        ServerAdmin u ->
            Just <| getter u
