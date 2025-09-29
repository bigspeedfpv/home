import gleam/erlang/process
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/otp/actor
import gleam/result
import gleam/string
import mist
import spotify_proxy/ratelimiter
import spotify_proxy/status
import wisp
import wisp/wisp_mist

type Context {
  Context(
    status_subject: process.Subject(status.Msg),
    ratelimit_subject: process.Subject(ratelimiter.Msg),
  )
}

pub fn supervised(
  status_subject: process.Subject(status.Msg),
  ratelimit_subject: process.Subject(ratelimiter.Msg),
) {
  let secret_key_base = wisp.random_string(64)

  let ctx = Context(status_subject:, ratelimit_subject:)

  wisp_mist.handler(fn(req) { router(req, ctx) }, secret_key_base)
  |> mist.new
  |> mist.port(8000)
  |> mist.bind("0.0.0.0")
  |> mist.supervised
}

fn middleware(
  req: wisp.Request,
  ctx: Context,
  handle_request: fn(wisp.Request) -> wisp.Response,
) -> wisp.Response {
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)
  use req <- wisp.csrf_known_header_protection(req)
  use <- default_cors()
  use <- ratelimit(req, ctx)
  handle_request(req)
}

fn router(req: wisp.Request, ctx: Context) -> wisp.Response {
  use req <- middleware(req, ctx)
  case wisp.path_segments(req) {
    [] -> now_playing(req, ctx)
    _ -> wisp.not_found()
  }
}

fn now_playing(_req: wisp.Request, ctx: Context) -> wisp.Response {
  let now_playing = actor.call(ctx.status_subject, 250, status.Get)
  let resp = status_to_json(now_playing)

  json.to_string(resp)
  |> wisp.json_response(200)
  |> wisp.set_header("Cache-Control", "public, max-age=15")
}

fn status_to_json(
  currently_playing: Option(status.CurrentlyPlaying),
) -> json.Json {
  case currently_playing {
    None -> {
      json.object([#("playing", json.bool(False))])
    }
    Some(currently_playing) -> {
      let status.CurrentlyPlaying(song:, set_at:) = currently_playing
      let status.Song(
        artists:,
        duration_ms:,
        progress_ms:,
        url:,
        name:,
        images:,
      ) = song

      json.object([
        #("playing", json.bool(True)),
        #("artists", json.array(artists, artist_to_json)),
        #("duration_ms", json.int(duration_ms)),
        #("progress_ms", json.int(progress_ms)),
        #("since", json.int(set_at)),
        #("url", json.string(url)),
        #("name", json.string(name)),
        #("images", json.array(images, image_to_json)),
      ])
    }
  }
}

fn artist_to_json(artist: status.Artist) -> json.Json {
  let status.Artist(url:, name:) = artist
  json.object([
    #("url", json.string(url)),
    #("name", json.string(name)),
  ])
}

fn image_to_json(image: status.Image) -> json.Json {
  json.object([
    #("url", json.string(image.url)),
    #("width", json.int(image.width)),
    #("height", json.int(image.height)),
  ])
}

fn ratelimit(
  req: wisp.Request,
  ctx: Context,
  next: fn() -> wisp.Response,
) -> wisp.Response {
  let ip =
    req.headers
    |> list.find_map(fn(header) {
      case string.lowercase(header.0) {
        h if h == "x-forwarded-for" -> Ok(header.1)
        _ -> Error(Nil)
      }
    })
    |> result.unwrap(req.host)
  case actor.call(ctx.ratelimit_subject, 200, ratelimiter.Take(_, ip)) {
    True -> next()
    False -> wisp.response(429)
  }
}

fn default_cors(next: fn() -> wisp.Response) -> wisp.Response {
  next() |> wisp.set_header("Access-Control-Allow-Origin", "*")
}
