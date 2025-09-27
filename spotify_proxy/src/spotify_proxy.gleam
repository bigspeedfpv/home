import envoy
import gleam/erlang/process
import gleam/otp/actor
import gleam/otp/static_supervisor as sup
import gleam/otp/supervision
import gleam/result
import logging
import spotify_proxy/api
import spotify_proxy/ratelimiter
import spotify_proxy/spotify
import spotify_proxy/status
import spotify_proxy/util
import wisp

pub fn start(_app, _type) -> Result(process.Pid, actor.StartError) {
  logging.configure()
  logging.set_level(logging.Debug)

  let spotify_id = get_env("SPOTIFY_ID")
  let spotify_secret = get_env("SPOTIFY_SECRET")
  let spotify_refresh = get_env("SPOTIFY_REFRESH")

  // There are three actors here - one to query the Spotify API, one to hold the current status,
  // and one just to handle API requests.
  // I'm not entirely sure this is the best way to break these out, but the Spotify actor is *very*
  // fallible and I didn't really want to lose statuses if for whatever reason someone's request
  // errors or whatever
  // Flow is Spotify actor requests status -> Saves to status actor
  // Web actor requests status -> Status actor sends to web actor -> Web actor serializes and replies
  //
  // gg?

  let ratelimit_name = process.new_name("ratelimiter")
  let ratelimit_subject = process.named_subject(ratelimit_name)

  let status_name = process.new_name("spotify_status")
  let status_subject = process.named_subject(status_name)

  let ratelimit_child =
    supervision.worker(fn() {
      Ok(actor.Started(ratelimiter.spawn_link(ratelimit_name, 2, 10_000), Nil))
    })

  let spotify_child =
    supervision.worker(fn() {
      spotify.spawn_link(
        spotify_id,
        spotify_secret,
        spotify_refresh,
        status_subject,
      )
    })

  let status_child =
    supervision.worker(fn() {
      status.spawn_link(status_name) |> result.map(actor.Started(_, Nil))
    })

  let api_child = api.supervised(status_subject, ratelimit_subject)

  let res =
    sup.new(sup.OneForOne)
    |> sup.add(ratelimit_child)
    |> sup.add(spotify_child)
    |> sup.add(status_child)
    |> sup.add(api_child)
    |> sup.start

  case res {
    Ok(actor.Started(pid, _data)) -> {
      let sup_name = process.new_name("main_supervisor")
      let _ = process.register(pid, sup_name)
      Ok(pid)
    }
    Error(why) -> Error(why)
  }
}

fn get_env(key: String) -> String {
  case envoy.get(key) {
    Ok(v) -> v
    Error(Nil) -> {
      wisp.log_critical("Missing env var " <> key <> ". Bye :(")
      util.stop()
    }
  }
}

pub fn main() {
  process.sleep_forever()
}
