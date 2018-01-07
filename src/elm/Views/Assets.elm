module Views.Assets exposing (src, pp_menu)

import Html exposing (Attribute)
import Html.Attributes as Attr


type Image
    = Image String


src : Image -> Attribute msg
src (Image url) =
    Attr.src url


pp_menu : Image
pp_menu =
    Image "./static/img/pp_menu.png"
