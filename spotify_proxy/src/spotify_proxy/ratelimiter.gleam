import gleam/dict
import gleam/erlang/process
import gleam/int
import gleam/otp/actor
import gleam/result
import logging

type State {
  State(
    ratelimits: dict.Dict(String, Ratelimit),
    max: Int,
    leak_every: Int,
    self_subject: process.Subject(Msg),
  )
}

type Ratelimit {
  Ratelimit(count: Int, max: Int, leak_every: Int)
}

pub type Msg {
  Take(process.Subject(Bool), String)
  Leak(String)
  Log
}

pub fn spawn_link(name: process.Name(Msg), max: Int, leak_every: Int) {
  let self_subject = process.named_subject(name)

  let init = fn(_sub) {
    let selector = process.new_selector() |> process.select(self_subject)
    let state = State(ratelimits: dict.new(), max:, leak_every:, self_subject:)
    actor.initialised(state)
    |> actor.selecting(selector)
    |> actor.returning(Nil)
  }

  let assert Ok(actor.Started(pid, _data)) =
    actor.new_with_initialiser(100, fn(sub) { Ok(init(sub)) })
    |> actor.on_message(handle_message)
    |> actor.start

  let _ = process.register(pid, name)
  process.send(self_subject, Log)

  pid
}

fn handle_message(state: State, msg: Msg) -> actor.Next(State, Msg) {
  let state = case msg {
    Log -> {
      logging.log(
        logging.Info,
        "Ratelimiter is currently tracking "
          <> int.to_string(dict.size(state.ratelimits))
          <> " ratelimits",
      )

      process.send_after(state.self_subject, 5 * 60 * 1000, Log)
      state
    }
    // SHOULD BE QUEUED AFTER EVERY TAKE! this will eventually equate to 0!
    Leak(key) -> {
      case dict.get(state.ratelimits, key) {
        Ok(ratelimit) -> {
          // remove the ratelimit altogether if it's empty for mem usage concerns
          // (does this even make a difference?)
          let ratelimits = case leak(ratelimit) {
            ratelimit if ratelimit.count == 0 -> {
              logging.log(
                logging.Debug,
                "ratelimit for " <> key <> " empty, removing...",
              )
              dict.delete(state.ratelimits, key)
            }
            ratelimit -> dict.insert(state.ratelimits, key, ratelimit)
          }

          State(..state, ratelimits:)
        }
        Error(Nil) -> {
          logging.log(
            logging.Debug,
            "Ratelimit not found to leak; it was already empty!",
          )
          state
        }
      }
    }
    Take(return, key) -> {
      let rl =
        state.ratelimits
        |> dict.get(key)
        |> result.unwrap(Ratelimit(
          count: 0,
          max: state.max,
          leak_every: state.leak_every,
        ))
        |> take

      let rl = case rl {
        Ok(rl) -> {
          // successfully taken
          process.send(return, True)
          rl
        }
        Error(rl) -> {
          // ratelimited
          process.send(return, False)
          rl
        }
      }

      let ratelimits = dict.insert(state.ratelimits, key, rl)
      process.send_after(state.self_subject, state.leak_every, Leak(key))
      State(..state, ratelimits:)
    }
  }

  actor.continue(state)
}

fn leak(ratelimit: Ratelimit) -> Ratelimit {
  logging.log(logging.Debug, "Leaking")
  let ratelimit = Ratelimit(..ratelimit, count: int.max(0, ratelimit.count - 1))
  logging.log(logging.Debug, "new count: " <> int.to_string(ratelimit.count))
  ratelimit
}

/// Ok(rl) if successfully taken, Error(rl) if ratelimited
fn take(ratelimit: Ratelimit) -> Result(Ratelimit, Ratelimit) {
  logging.log(logging.Debug, "Taking")
  case ratelimit.count {
    count if count == ratelimit.max -> {
      Error(ratelimit)
    }
    count -> {
      let ratelimit = Ratelimit(..ratelimit, count: count + 1)
      logging.log(
        logging.Debug,
        "new count: " <> int.to_string(ratelimit.count),
      )
      Ok(ratelimit)
    }
  }
}
