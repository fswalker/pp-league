module Views.Page exposing (frame)

import Html exposing (..)
import Html.Attributes exposing (..)
import Views.Loader as Loader
import Views.Header as Header
import Views.Navigation as Navigation
import Views.Footer as Footer
import Data.Session as Session exposing (Session)


frame : Session -> Bool -> Html msg -> Html msg
frame session isLoading content =
    section [ class "hero is-fullheight" ]
        [ div [ class "hero-head" ]
            [ Header.view session.user
            , Navigation.view
            ]
        , div [ classList [ ( "hero-body", True ), ( "page-frame", True ), ( "centered", isLoading ) ] ]
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
