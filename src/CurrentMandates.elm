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
    { status : Status }


type Status
    = Loading
    | Loaded (List Role)
    | Errored String


type alias MethoneConfig =
    { system_name : String
    , color_scheme : String
    , login_text : String
    , login_href : String
    , links : List Link
    }


type alias Link =
    { str : String
    , href : String
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
    div [ id "application", class "purple" ]
        [ viewHeader
        , viewContent model
        ]


viewHeader : Html Msg
viewHeader =
    header []
        [ div [ class "header-inner" ]
            [ div [ class "row" ]
                [ div [ class "header-left col-md-2" ]
                    [ a [ href "/" ] [ text "« Tillbaka" ] ]
                , div [ class "col-md-8" ] [ h2 [] [ text "dfunc" ] ]
                , div [ class "header-right col-md-2" ]
                    [ a [ href "https://github.com/oskstr/dfunc", class "primary-action" ]
                        [ text "Github" ]
                    ]
                ]
            ]
        ]


viewContent : Model -> Html Msg
viewContent model =
    div [ id "content" ]
        [ h1 [] [ text "Aktuella mandat" ]
        , table [ class "table" ]
            [ thead []
                [ tr []
                    [ th [] [ text "Namn" ]
                    , th [] [ text "Grupp" ]
                    , th [] [ text "E-post" ]
                    , th [] [ text "Nuvarande innehavare" ]
                    ]
                ]
            , case model.status of
                Loading ->
                    -- TODO spinner while loading
                    text ""

                Loaded roles ->
                    viewMandates roles

                Errored string ->
                    -- TODO error handling
                    text string
            ]
        ]


viewMandates : List Role -> Html Msg
viewMandates roles =
    let
        viewMandate : Role -> Maybe User -> Html Msg
        viewMandate { title, identifier, email, group } user =
            tr []
                [ th []
                    [ a [ href ("/position/" ++ identifier) ] [ text title ] ]
                , th [] [ text group.name ]
                , th []
                    [ a [ href ("mailto:" ++ email) ] [ text email ] ]
                , th []
                    [ case user of
                        Just u ->
                            a [ href ("/user/" ++ u.kthId) ]
                                [ text (fullName u) ]

                        Nothing ->
                            a [] [ text "Vakant" ]
                    ]
                ]
    in
    tbody [] <|
        List.concatMap
            (\role ->
                case role.mandates of
                    [] ->
                        [ viewMandate role Nothing ]

                    _ ->
                        List.map (\{ user } -> viewMandate role (Just user)) role.mandates
            )
            roles


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
    { status = Loading }


initialMethoneConfig =
    { system_name = "dfunc"
    , color_scheme = "purple"
    , login_text = "Logga in"
    , login_href = "/login" -- TODO
    , links = [ { str = "Användarlookup", href = "/lookup" } ]
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( initialModel
    , Cmd.batch
        [ Http.get
            { url = "https://dfunkt.datasektionen.se/api/roles/all/current"
            , expect = Http.expectJson GotRoles rolesDecoder
            }
        , setMethoneConfig initialMethoneConfig
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
