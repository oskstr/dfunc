module CurrentMandatesTest exposing (..)

import CurrentMandates
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Json.Decode as Decode exposing (decodeString, decodeValue)
import Json.Encode as Encode
import Test exposing (..)


decoderTest : Test
decoderTest =
    test "decoder test" <|
        \_ ->
            testPayload
                |> decodeString CurrentMandates.jsonModelDecoder
                |> Expect.equal
                    (Ok
                        { mandates =
                            [ { title = "Kassör"
                              , identifier = "kassor"
                              , email = "kassor@d.kth.se"
                              , active = True
                              , id = 9
                              , mandates =
                                    [ { start = "nu"
                                      , end = "senare"
                                      , user =
                                            { firstName = "William"
                                            , lastName = "Nilsson"
                                            , kthId = "wil"
                                            , ugKthId = "wil"
                                            }
                                      }
                                    ]
                              , group =
                                    { name = "D-rektoratet"
                                    , identifier = "drek"
                                    }
                              }
                            ]
                        }
                    )


testPayload : String
testPayload =
    """
    [
    {
    "title": "Kassör",
    "description": "Ansvarar för sektionens ekonomi. Planerar budget, sköter löpande bokföring samt placerar sektionens tillgångar. Bistår med sektionens ekonomiska beslutsunderlag. Kassören ansvarar även för att det finns ett uppdaterat styrdokument för sektionens ekonomi. Leder sektionens bokföringspliktiga nämnder i bokföringsarbetet.",
    "identifier": "kassor",
    "email": "kassor@d.kth.se",
    "active": true,
    "id": 9,
    "Mandates": [
    {
    "start": "2020-01-01T00:00:00.000Z",
    "end": "2020-12-31T00:00:00.000Z",
    "User": {
    "first_name": "William",
    "last_name": "Nilsson",
    "email": null,
    "kthid": "wnil",
    "ugkthid": "u12lpln9"
    }
    },
    {
        "start": "2020-01-01T00:00:00.000Z",
        "end": "2020-12-31T00:00:00.000Z",
        "User": {
        "first_name": "William",
        "last_name": "Nilsson",
        "email": null,
        "kthid": "wnil",
        "ugkthid": "u12lpln9"
        }
        }
    ],
    "Group": {
    "name": "D-Rektoratet",
    "identifier": "drek"
    }
    },
    {
        "title": "Kassör",
        "description": "Ansvarar för sektionens ekonomi. Planerar budget, sköter löpande bokföring samt placerar sektionens tillgångar. Bistår med sektionens ekonomiska beslutsunderlag. Kassören ansvarar även för att det finns ett uppdaterat styrdokument för sektionens ekonomi. Leder sektionens bokföringspliktiga nämnder i bokföringsarbetet.",
        "identifier": "kassor",
        "email": "kassor@d.kth.se",
        "active": true,
        "id": 9,
        "Mandates": [
        {
        "start": "2020-01-01T00:00:00.000Z",
        "end": "2020-12-31T00:00:00.000Z",
        "User": {
        "first_name": "William",
        "last_name": "Nilsson",
        "email": null,
        "kthid": "wnil",
        "ugkthid": "u12lpln9"
        }
        }
        ],
        "Group": {
        "name": "D-Rektoratet",
        "identifier": "drek"
        }
        }
    ]
    """
