module Data.User exposing (User(..), userDecoder)

import Data.Player exposing (..)
import Json.Decode as Decode exposing (Decoder)


type alias UserMetadata =
    Player { name : String }


type User
    = Anonymous
    | Player UserMetadata
    | Admin UserMetadata
    | ServerAdmin UserMetadata


buildUserMetadata : String -> String -> String -> UserMetadata
buildUserMetadata name nick league_id =
    { name = name
    , nick = nick
    , league_id = league_id
    }


metadataDecoder : Decoder UserMetadata
metadataDecoder =
    Decode.map3 buildUserMetadata
        (Decode.field "name" Decode.string)
        (Decode.field "nick" Decode.string)
        (Decode.field "league_id" Decode.string)


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
