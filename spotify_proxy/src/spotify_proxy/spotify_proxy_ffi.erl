-module(spotify_proxy_ffi).
-export([now/0]).

now() ->
    {MegaSecs, Secs, _} = os:timestamp(),
    1000000 * MegaSecs + Secs.
