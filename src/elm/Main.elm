port module Main exposing (..)

import Html exposing (..)
import Views.Page exposing (frame)
import Pages.Login as Login
import Data.User exposing (User, Role(..))
import Data.Session exposing (Session)


type Page
    = Loading
    | Login Login.Model



-- MODEL


type alias Model =
    { session : Session
    , page : Page

    -- TODO page
    }


init : ( Model, Cmd Msg )
init =
    let
        model =
            { session = { user = { role = Anonymous } }
            , page = Login Login.init
            }
    in
        -- TODO command to fetch session info and based on that load login page or fetch user data
        ( model, Cmd.none )



-- UPDATE


type Msg
    = LoginMsg Login.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( LoginMsg loginMsg, Login loginModel ) ->
            let
                ( newModel, loginCmd ) =
                    Login.update loginMsg loginModel
            in
                { model | page = Login newModel }
                    ! [ Cmd.map LoginMsg loginCmd ]

        ( _, _ ) ->
            model ! [ Cmd.none ]



-- VIEW


view : Model -> Html Msg
view { session, page } =
    viewPage session page


viewPage : Session -> Page -> Html Msg
viewPage session page =
    -- TODO use session info to properly render all parts of the app
    case page of
        Loading ->
            text ""
                |> frame

        Login loginModel ->
            Login.view loginModel
                |> Html.map LoginMsg
                |> frame


subscriptions : Model -> Sub Msg
subscriptions =
    \_ -> Sub.none


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
