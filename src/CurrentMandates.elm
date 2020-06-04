port module CurrentMandates exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes as Attr exposing (class, classList, href, id, name, src, title, type_)
import Html.Events exposing (on, onClick)
import Http
import Json.Decode as Decode exposing (Decoder, at, bool, int, list, string, succeed)
import Json.Decode.Pipeline exposing (optional, required)


port setMethoneConfig : MethoneConfig -> Cmd msg


type alias Model =
    { status : Status
    , admin : Bool
    }


type Status
    = Loading
    | Loaded (List Role)
    | Errored String


type alias MethoneConfig =
    { login_text : String
    , login_href : String
    }



-- TODO reduce fields?
-- TODO toggle active
-- TODO add fuzzyfile


type alias Role =
    { title : String
    , identifier : String
    , email : String
    , active : Bool
    , id : Int
    , mandates : List Mandate
    , group : Group
    }


type alias Mandate =
    { start : String, end : String, user : User }


type alias User =
    { firstName : String, lastName : String, kthId : String, ugKthId : String }


type alias Group =
    { name : String, identifier : String }


type Msg
    = GotRoles (Result Http.Error (List Role))


view : Model -> Html Msg
view model =
    viewContent model


viewContent : Model -> Html Msg
viewContent model =
    div [ id "content" ]
        [ h1 [] [ text "Aktuella mandat" ]
        , div [ id "table-container" ]
            [ table [ class "table" ]
                [ thead []
                    [ tr []
                        [ th [] [ text "Roll" ]

                        --, th [] [ text "Grupp" ]
                        , th [] [ text "E-post" ]
                        , th [] [ text "Nuvarande innehavare" ]
                        ]
                    ]
                , case model.status of
                    Loading ->
                        -- TODO spinner while loading?
                        text ""

                    Loaded roles ->
                        viewMandates roles model.admin

                    Errored string ->
                        -- TODO error handling
                        text string
                ]
            ]
        ]


viewMandates : List Role -> Bool -> Html Msg
viewMandates roles admin =
    tbody [] <|
        List.concatMap
            (\role ->
                case role.active || admin of
                    True ->
                        case role.mandates of
                            [] ->
                                [ viewMandate role Nothing ]

                            _ ->
                                List.map (\{ user } -> viewMandate role (Just user)) role.mandates

                    False ->
                        []
            )
            roles


viewMandate : Role -> Maybe User -> Html Msg
viewMandate { title, identifier, email, group } user =
    tr []
        [ th []
            [ a [ href ("/role/" ++ identifier) ] [ text title ] ]

        --, th [] [ text group.name ]
        , th []
            [ a [ href ("mailto:" ++ email) ] [ text email ] ]
        , th [ class "user" ]
            [ case user of
                Just u ->
                    a [ href ("/user/" ++ u.kthId) ]
                        [ text (fullName u) ]

                Nothing ->
                    a [] [ text "Vakant" ]
            ]
        ]


fullName : User -> String
fullName { firstName, lastName } =
    firstName ++ " " ++ lastName


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotRoles (Ok roles) ->
            ( { model | status = Loaded roles }, Cmd.none )

        GotRoles (Err _) ->
            ( model, Cmd.none )


initialModel : Model
initialModel =
    { status = Loading, admin = True }


initialMethoneConfig : MethoneConfig
initialMethoneConfig =
    { login_text = "Logga in"
    , login_href = "/login" --TODO fix login
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( initialModel
    , Cmd.batch
        [ Http.get
            { url = "https://dfunkt.datasektionen.se/api/roles/all/current"
            , expect = Http.expectJson GotRoles rolesDecoder
            }
        , setMethoneConfig initialMethoneConfig -- TODO don't set here but maybe set on login
        ]
    )


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


roleDecoder : Decoder Role
roleDecoder =
    succeed Role
        |> required "title" string
        |> required "identifier" string
        |> required "email" string
        |> required "active" bool
        |> required "id" int
        |> required "Mandates" (list decodeMandate)
        |> required "Group" decodeGroup


decodeMandate =
    succeed Mandate
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


rolesDecoder : Decoder (List Role)
rolesDecoder =
    list roleDecoder
