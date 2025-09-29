import gleam/erlang/process
import gleam/option.{type Option, None}
import gleam/otp/actor
import gleam/result
import gleam/string
import logging
import spotify_proxy/util

type State =
  Option(CurrentlyPlaying)

pub type Msg {
  Set(Option(Song))
  Get(reply_to: process.Subject(Option(CurrentlyPlaying)))
}

pub fn spawn_link(name: process.Name(Msg)) {
  let subject = process.named_subject(name)

  let init = fn() {
    let selector = process.new_selector() |> process.select(subject)
    let state = None
    actor.initialised(state)
    |> actor.selecting(selector)
    |> actor.returning(subject)
  }

  use actor.Started(pid, _data) <- result.try(
    actor.new_with_initialiser(1000, fn(_) { Ok(init()) })
    |> actor.on_message(handle_message)
    |> actor.start(),
  )

  let _ = process.register(pid, name)
  Ok(pid)
}

fn handle_message(state: State, msg: Msg) -> actor.Next(State, Msg) {
  case msg {
    Set(currently_playing) -> {
      logging.log(
        logging.Debug,
        "setting new status: " <> string.inspect(currently_playing),
      )

      currently_playing
      |> option.map(CurrentlyPlaying(song: _, set_at: util.now()))
      |> actor.continue()
    }
    Get(reply_subject) -> {
      process.send(reply_subject, state)
      actor.continue(state)
    }
  }
}

pub type CurrentlyPlaying {
  CurrentlyPlaying(song: Song, set_at: Int)
}

pub type Song {
  Song(
    artists: List(Artist),
    duration_ms: Int,
    progress_ms: Int,
    url: String,
    name: String,
    images: List(Image),
  )
}

pub type Artist {
  Artist(url: String, name: String)
}

pub type Image {
  Image(url: String, height: Int, width: Int)
}
