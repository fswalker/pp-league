module Views.Navigation exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Data.User as User exposing (User(..))
import Route as Route exposing (Route(..))


view : User -> Html msg
view user =
    nav
        [ class "navbar is-transparent main"
        , attribute "role" "navigation"
        , attribute "aria-label" "main navigation"
        ]
        [ div [ class "navbar-brand" ]
            [ div [ class "button navbar-burger burger", attribute "data-target" "pp-navbar-menu" ]
                [ span [] []
                , span [] []
                , span [] []
                ]
            ]
        , div [ class "navbar-menu", id "pp-navbar-menu" ]
            [ user
                |> User.isAnonymous
                |> not
                |> renderNavItems
            ]
        ]


renderNavItems : Bool -> Html msg
renderNavItems shouldRender =
    div [ class "navbar-start is-size-5" ]
        (if shouldRender then
            [ navItem Route.Home "My League" "Link to My League Page"
            , navItem Route.NewScore "New Score" "Link to New Score Page"
            ]
         else
            []
        )


navItem : Route -> String -> String -> Html msg
navItem route name description =
    a
        [ class "navbar-item"
        , Route.href route
        , title description
        ]
        [ text name ]
