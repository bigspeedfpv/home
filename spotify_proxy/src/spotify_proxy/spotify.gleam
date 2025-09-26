import gleam/bit_array
import gleam/dynamic/decode
import gleam/erlang/process
import gleam/http
import gleam/http/request
import gleam/http/response
import gleam/httpc
import gleam/int
import gleam/json
import gleam/option.{type Option, None, Some}
import gleam/otp/actor
import gleam/result
import gleam/string
import gleam/uri
import logging
import spotify_proxy/status
import spotify_proxy/util

type State {
  State(
    self_subject: process.Subject(Nil),
    status_subject: process.Subject(status.Msg),
    id: String,
    secret: String,
    refresh: String,
    access: Option(Token),
  )
}

type Token {
  Token(key: String, expires: Int)
}

pub fn spawn_link(
  id: String,
  secret: String,
  refresh: String,
  status_subject: process.Subject(status.Msg),
) {
  let init = fn(subject: process.Subject(Nil)) {
    let selector = process.new_selector() |> process.select(subject)
    let state =
      State(
        self_subject: subject,
        status_subject:,
        id:,
        secret:,
        refresh:,
        access: None,
      )
    process.send(subject, Nil)
    actor.initialised(state)
    |> actor.selecting(selector)
    |> actor.returning(subject)
  }

  actor.new_with_initialiser(1000, fn(sub) { Ok(init(sub)) })
  |> actor.on_message(handle_message)
  |> actor.start()
}

// only supports one message - refresh
fn handle_message(state: State, _msg) -> actor.Next(State, Nil) {
  let assert Ok(req) =
    request.to("https://api.spotify.com/v1/me/player/currently-playing")
  use #(state, resp) <- try_or_abnormal(make_request(state, req, 0))
  case resp {
    None -> {
      logging.log(logging.Info, "No status, not playing")
      actor.send(state.status_subject, status.Set(None))
      queue_next(state)
    }
    Some(resp) -> {
      use song <- try_or_abnormal(json.parse(
        resp.body,
        currently_playing_resp_decoder(),
      ))
      actor.send(state.status_subject, status.Set(song))
      queue_next(state)
    }
  }
}

fn queue_next(state: State) -> actor.Next(State, Nil) {
  logging.log(
    logging.Debug,
    "successfully refreshed status, queueing refresh for 10 secs from now...",
  )
  process.send_after(state.self_subject, 10_000, Nil)
  actor.continue(state)
}

fn try_or_abnormal(
  res: Result(value, error),
  cb: fn(value) -> actor.Next(State, Nil),
) -> actor.Next(State, Nil) {
  case res {
    Ok(v) -> cb(v)
    Error(why) -> {
      logging.log(
        logging.Error,
        "Error, shutting down: " <> string.inspect(why),
      )
      actor.stop_abnormal(string.inspect(why))
    }
  }
}

fn make_request(
  state: State,
  req: request.Request(String),
  try: Int,
) -> Result(#(State, Option(response.Response(String))), FetchError) {
  case try {
    2 -> {
      logging.log(logging.Error, "hit 2 tries for making request, bai...")
      Error(RepeatedFailure)
    }
    try -> {
      logging.log(logging.Debug, "try #" <> int.to_string(try))
      use token <- result.try(access_token(state))
      let state = State(..state, access: Some(token))
      let req = request.set_header(req, "Authorization", "Bearer " <> token.key)
      use resp <- result.try(httpc.send(req) |> result.map_error(Http))
      case resp.status {
        200 -> Ok(#(state, Some(resp)))
        204 -> Ok(#(state, None))
        401 -> {
          logging.log(
            logging.Warning,
            "Got 401 fetching status, force refreshing token",
          )
          use token <- result.try(refresh_token(state))
          make_request(State(..state, access: Some(token)), req, try + 1)
        }
        c -> {
          logging.log(
            logging.Error,
            "Got unhandled status code " <> int.to_string(c),
          )
          Error(BadStatus(c))
        }
      }
    }
  }
}

fn access_token(state: State) -> Result(Token, FetchError) {
  let now = util.now()
  case state.access {
    Some(access) if now < access.expires -> Ok(access)
    _ -> {
      logging.log(logging.Debug, "Token not loaded or expired, refreshing")
      let token = refresh_token(state)
      logging.log(logging.Debug, "Done!")
      token
    }
  }
}

fn refresh_token(state: State) -> Result(Token, FetchError) {
  let assert Ok(req) = request.to("https://accounts.spotify.com/api/token")
  let req =
    req
    |> request.set_header("Content-Type", "application/x-www-form-urlencoded")
    |> request.set_header("Authorization", basic_auth(state.id, state.secret))
    |> request.set_method(http.Post)
    |> request.set_body(
      uri.query_to_string([
        #("grant_type", "refresh_token"),
        #("refresh_token", state.refresh),
      ]),
    )
  use resp <- result.try(httpc.send(req) |> result.map_error(Http))
  case resp.status {
    200 -> {
      resp.body
      |> json.parse(refresh_token_resp_decoder())
      |> result.map_error(Json)
    }
    c -> {
      logging.log(
        logging.Error,
        "Got bad response code " <> int.to_string(c) <> " when refreshing token",
      )
      Error(BadStatus(c))
    }
  }
}

fn basic_auth(user: String, pass: String) -> String {
  "Basic "
  <> {
    { user <> ":" <> pass }
    |> bit_array.from_string
    |> bit_array.base64_encode(True)
  }
}

fn refresh_token_resp_decoder() -> decode.Decoder(Token) {
  use access_token <- decode.field("access_token", decode.string)
  use expires_in <- decode.field("expires_in", decode.int)
  decode.success(Token(key: access_token, expires: util.now() + expires_in))
}

type FetchError {
  Http(httpc.HttpError)
  Json(json.DecodeError)
  BadStatus(Int)
  RepeatedFailure
}

fn currently_playing_resp_decoder() -> decode.Decoder(Option(status.Song)) {
  use currently_playing <- decode.field("is_playing", decode.bool)
  case currently_playing {
    False -> decode.success(None)
    True -> {
      use currently_playing_type <- decode.field(
        "currently_playing_type",
        decode.string,
      )
      case currently_playing_type {
        "track" -> {
          use progress_ms <- decode.field("progress_ms", decode.int)
          use song <- decode.field("item", song_decoder(progress_ms))
          decode.success(Some(song))
        }
        _ -> decode.success(None)
      }
    }
  }
}

fn song_decoder(progress_ms: Int) -> decode.Decoder(status.Song) {
  use artists <- decode.field("artists", decode.list(artist_decoder()))
  use duration_ms <- decode.field("duration_ms", decode.int)
  use url <- decode.subfield(["external_urls", "spotify"], decode.string)
  use name <- decode.field("name", decode.string)
  decode.success(status.Song(artists:, duration_ms:, progress_ms:, url:, name:))
}

fn artist_decoder() -> decode.Decoder(status.Artist) {
  use url <- decode.subfield(["external_urls", "spotify"], decode.string)
  use name <- decode.field("name", decode.string)
  decode.success(status.Artist(url:, name:))
}
