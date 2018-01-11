module Data.User exposing (User(..), userDecoder)

import Json.Decode as Decode exposing (Decoder)


type alias UserMetadata =
    { name : String
    }


type User
    = Anonymous
    | Player UserMetadata
    | Admin UserMetadata
    | ServerAdmin UserMetadata


metadataDecoder : Decoder UserMetadata
metadataDecoder =
    Decode.field "name" (Decode.nullable Decode.string)
        |> Decode.map ((Maybe.withDefault "") >> UserMetadata)


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
