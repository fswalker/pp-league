module Views.Page exposing (frame)

import Html exposing (..)
import Html.Attributes exposing (..)
import Views.Loader as Loader
import Views.Header as Header
import Views.Navigation as Navigation
import Views.Footer as Footer
import Data.User as User exposing (User)


frame : User -> Bool -> Html msg -> Html msg
frame user isLoading content =
    section [ class "hero is-fullheight" ]
        [ div [ class "hero-head" ]
            [ Header.view user
            , Navigation.view
            ]
        , div [ class "hero-body page-frame" ]
            [ div [ class "container" ]
                [ if isLoading then
                    Loader.loader
                  else
                    content
                ]
            ]
        , div [ class "hero-foot" ]
            [ Footer.view ]
        ]
