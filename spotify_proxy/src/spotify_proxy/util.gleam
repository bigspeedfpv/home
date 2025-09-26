import gleam/erlang/process

@external(erlang, "init", "stop")
fn init_stop() -> a

pub fn stop() -> a {
  let v = init_stop()
  process.sleep_forever()
  v
}

@external(erlang, "spotify_proxy_ffi", "now")
pub fn now() -> Int
