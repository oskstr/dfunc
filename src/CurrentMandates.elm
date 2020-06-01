module CurrentMandates exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes as Attr exposing (class, classList, id, name, src, title, type_)
import Html.Events exposing (on, onClick)
import Json.Decode as Decode exposing (Decoder, at, bool, int, list, string, succeed)
import Json.Decode.Pipeline exposing (optional, required)


type alias Model =
    { mandates : List Mandate }



-- TODO reduce fields?


type alias Mandate =
    { title : String
    , identifier : String
    , email : String
    , active : Bool
    , id : Int
    , start : String
    , end : String

    --- User
    , firstName : String
    , lastName : String
    , kthId : String
    , ugKthId : String

    -- Group
    , groupName : String
    , groupIdentifier : String
    }


type Msg
    = NothingYet


view : Model -> Html Msg
view model =
    Debug.todo "unimplemented"


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    Debug.todo "unimplemented"


initialModel : Model
initialModel =
    { mandates = [] }


init : () -> ( Model, Cmd Msg )
init _ =
    ( initialModel, Cmd.none )


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


type alias JsonModel =
    { mandates : List JsonMandate }


type alias JsonMandate =
    { title : String
    , identifier : String
    , email : String
    , active : Bool
    , id : Int
    , mandates : List Duration
    , group : Group
    }


type alias Duration =
    { start : String, end : String, user : User }


type alias User =
    { firstName : String, lastName : String, kthId : String, ugKthId : String }


type alias Group =
    { name : String, identifier : String }


jsonMandateDecoder : Decoder JsonMandate
jsonMandateDecoder =
    succeed JsonMandate
        |> required "title" string
        |> required "identifier" string
        |> required "email" string
        |> required "active" bool
        |> required "id" int
        |> required "Mandates" (list decodeStartEnd)
        |> required "Group" decodeGroup


decodeStartEnd =
    succeed Duration
        |> required "start" string
        |> required "end" string
        |> required "User" decodeUser


decodeUser =
    succeed User
        |> required "first_name" string
        |> required "last_name" string
        |> required "kthid" string
        |> required "ugkthid" string


decodeGroup =
    succeed Group
        |> required "name" string
        |> required "identifier" string


jsonModelDecoder : Decoder JsonModel
jsonModelDecoder =
    Decode.map (\mandates -> { mandates = mandates }) (list jsonMandateDecoder)



--modelFromJson : JsonModel -> Model
--modelFromJson jsonModel =
--    let
--        mandatesFromJson : JsonMandate -> List Mandate
--        mandatesFromJson =
--            \{ title, identifier, email, active, id, mandates, group } ->
--                List.map
--                    (\{ start, end, user } ->
--                        { title = title
--                        , identifier = identifier
--                        , email = email
--                        , active = active
--                        , id = id
--                        , start = start
--                        , end = end
--                        , firstName = user.firstName
--                        , lastName = user.lastName
--                        , kthId = user.kthId
--                        , ugKthId = user.ugKthId
--                        , groupName = group.name
--                        , groupIdentifier = group.identifier
--                        }
--                    )
--                    mandates
--    in
--    { mandates = List.concatMap mandatesFromJson jsonModel.mandates }
