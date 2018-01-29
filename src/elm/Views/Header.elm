module Views.Header exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Data.User as User exposing (User)
import Views.Assets as Assets exposing (src)
import Route


view : User -> Html msg
view user =
    header [ class "header" ]
        [ div [ class "container" ]
            [ div [ class "level" ]
                [ div [ class "level-left" ]
                    [ a [ Route.href Route.Home, title "Link - My League Page" ]
                        [ div [ class "level" ]
                            [ div [ class "level-left" ]
                                [ img
                                    [ class "level-item logo image is-128x128"
                                    , Assets.src Assets.pp_menu
                                    , alt "Logo image - racket and the ball"
                                    ]
                                    []
                                , h1 [ class "page-title level-item title is-size-2" ]
                                    [ text "Ping-pong League" ]
                                ]
                            ]
                        ]
                    ]
                , userGreeting user
                ]
            ]
        ]


userGreeting : User -> Html msg
userGreeting user =
    case user of
        User.Anonymous ->
            text ""

        User.Player { nick } ->
            displayHelloMsg nick

        User.Admin { nick } ->
            displayHelloMsg nick

        User.ServerAdmin { nick } ->
            displayHelloMsg nick


displayHelloMsg : String -> Html msg
displayHelloMsg uname =
    div [ class "level-right greeting" ]
        [ h3 [ class "subtitle" ]
            [ text "Hello, "
            , strong [] [ text uname ]
            ]
        , a [ class "button is-rounded", Route.href Route.Logout ] [ text "Log Out" ]
        ]
