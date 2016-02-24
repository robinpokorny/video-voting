module VideoVoting where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json
import Signal exposing (Signal, Address)
import String


-- MODEL

type alias Model =
  { videos : List Video
  , uid : ID
  , field : String }

type alias Video =
    { uri : String
    , votes : Int
    , id : ID
    }

type alias ID = Int


newVideo : String -> Int -> Video
newVideo uri id =
    { uri = uri
    , votes = 0
    , id = id
    }


emptyModel : Model
emptyModel =
    { videos = []
    , uid = 0
    , field = ""
    }

-- UPDATE

type Action
    = NoOp
    | Add
    | UpdateField String
    | Delete ID
    | VoteFor ID

update : Action -> Model -> Model
update action model =
  case action of
    NoOp -> model

    Add ->
      { model |
        uid = model.uid + 1,
        field = "",
        videos =
          if String.isEmpty model.field
            then model.videos
            else model.videos ++
              [newVideo ("https://www.youtube.com/watch?v=" ++ model.field) model.uid]
      }

    UpdateField str ->
      { model | field = str }

    Delete id ->
      { model | videos = List.filter (\v -> v.id /= id) model.videos }

    VoteFor id ->
      let voteUp video =
        if video.id == id then
          { video | votes = video.votes + 1 }
        else
          video
      in
        { model | videos = List.map voteUp model.videos }

-- VIEW

view : Address Action -> Model -> Html
view address model =
  div []
    [ videoEntry address model.field
    , videoList address model.videos
    ]

videoEntry : Address Action -> String -> Html
videoEntry address url =
  div [ class "form-inline" ]
    [ div [ class "form-group" ]
      [ label [ for "newVideo" ] [text "What do you want to watch?"]
      , text " "
      , (videoInput address url)
      ]
    , text " "
    , button
      [ class "btn btn-primary"
      , onClick address Add
      ]
      [ text "Add video" ]
    ]


videoInput : Address Action -> String -> Html
videoInput address url =
  input
    [ id "newVideo"
    , class "form-control"
    , placeholder "YouTube ID"
    , autofocus True
    , value url
    , name "newVideo"
    , on "input" targetValue (Signal.message address << UpdateField)
    , onEnter address Add
    ]
    []

onEnter : Address a -> a -> Attribute
onEnter address value =
    on "keydown"
      (Json.customDecoder keyCode is13)
      (\_ -> Signal.message address value)

is13 : Int -> Result String ()
is13 code =
  if code == 13 then Ok () else Err "not the right key code"

videoList : Address Action -> List Video -> Html
videoList address videos =
  let max = Maybe.withDefault 0 (List.maximum (List.map .votes videos))
  in
    div [ class "list-group" ]
      (List.map (videoDetail address max) videos)

videoDetail : Address Action -> Int -> Video -> Html
videoDetail address max video =
  button
    [ class (classForVideo max video.votes)
    , onClick address (VoteFor video.id)
    ]
    [ span
      [ class "badge" ]
      [ text (toString video.votes) ]
    , text video.uri
    , a
      [ class "delete"
      , onClick address (Delete video.id)
      , href "#"
      ]
      [ text "×" ]
    ]

classForVideo : Int -> Int -> String
classForVideo max votes =
  "list-group-item" ++
    if (votes > 0 && max == votes)
    then " active"
    else ""

main : Signal Html
main =
  Signal.map (view actions.address) model

model : Signal Model
model =
  Signal.foldp update emptyModel actions.signal

actions : Signal.Mailbox Action
actions =
  Signal.mailbox NoOp