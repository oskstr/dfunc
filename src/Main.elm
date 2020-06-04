module Main exposing (main)

import Browser exposing (Document)
import Browser.Navigation as Nav
import CurrentMandates
import Html exposing (Html, a, div, footer, h1, h2, header, li, nav, text, ul)
import Html.Attributes exposing (class, classList, href, id)
import Html.Lazy exposing (lazy)
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, s, string)


type alias Model =
    { page : Page, key : Nav.Key }



-- TODO add more pages and routing through search queries and identifiers / kthIds


type Page
    = CurrentMandatesPage CurrentMandates.Model
      -- TODO add : | LookupPage Lookup.Model
    | NotFound


type Route
    = CurrentMandates



--| Lookup
--| PeopleLookup String
--| Role String


type Msg
    = ClickedLink Browser.UrlRequest
    | ChangedUrl Url
    | GotCurrentMandatesMsg CurrentMandates.Msg -- TODO check if applicable?


view : Model -> Document Msg
view model =
    let
        content =
            case model.page of
                CurrentMandatesPage currentMandates ->
                    CurrentMandates.view currentMandates
                        |> Html.map GotCurrentMandatesMsg

                NotFound ->
                    text "404, not found boi"
    in
    { title = "dfunc - Datasektionens funktionärer"
    , body =
        [ div [ id "methone-container-replace" ] []
        , div [ id "application", class "purple" ]
            [ lazy viewHeader model.page
            , content

            --, viewFooter
            ]
        ]
    }


viewHeader : Page -> Html Msg
viewHeader _ =
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


viewFooter : Html msg
viewFooter =
    footer [ id "footer", class "row" ]
        [ div [ id "footer-inner" ]
            [ div [ class "col-sm-6 text-center" ] [] ]
        , text "One is never alone with a rubber duck. -Douglas Adams"
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickedLink urlRequest ->
            case urlRequest of
                Browser.External href ->
                    ( model, Nav.load href )

                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

        ChangedUrl url ->
            updateUrl url model

        GotCurrentMandatesMsg currentMandatesMsg ->
            case model.page of
                CurrentMandatesPage currentMandates ->
                    toCurrentMandates model (CurrentMandates.update currentMandatesMsg currentMandates)

                _ ->
                    ( model, Cmd.none )


toCurrentMandates : Model -> ( CurrentMandates.Model, Cmd CurrentMandates.Msg ) -> ( Model, Cmd Msg )
toCurrentMandates model ( currentMandates, cmd ) =
    ( { model | page = CurrentMandatesPage currentMandates }
    , Cmd.map GotCurrentMandatesMsg cmd
    )


updateUrl : Url -> Model -> ( Model, Cmd Msg )
updateUrl url model =
    case Parser.parse parser url of
        Just CurrentMandates ->
            CurrentMandates.init ()
                |> toCurrentMandates model

        Nothing ->
            ( { model | page = NotFound }, Cmd.none )


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ Parser.map CurrentMandates Parser.top

        --, Parser.map Gallery (s "gallery")
        --, Parser.map SelectedPhoto (s "photos" </> string)
        ]


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    updateUrl url { page = NotFound, key = key }


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , onUrlRequest = ClickedLink
        , onUrlChange = ChangedUrl
        , subscriptions = \_ -> Sub.none
        , update = update
        , view = view
        }
