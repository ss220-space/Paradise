# TTS effects service

A small localhost HTTP service that applies TTS voice effects (radio, robot, megaphone and so on) with ffmpeg.
With `TTS_EFFECTS_URL` set, DreamDaemon sends effect requests to it through SShttp instead of running ffmpeg with `world.shelleo`, which forks the whole DreamDaemon process on the main thread.
With `TTS_EFFECTS_URL` unset, nothing changes: DreamDaemon runs ffmpeg through the shell as before.

## Requirements

- Python 3.8 or newer, standard library only.
- ffmpeg with the filters used in `code/game/sound/sound.dm` (`rubberband` is needed by `maskfilter`, `radio_maskfilter` and `old_vocoder`).
- The service must run on the same host as DreamDaemon, as a user that can read and write each server's `sound/tts_cache` (usually the user DreamDaemon runs as).

## Run

One service can serve every game server on the host. Give each DreamDaemon working directory a name:

```sh
python3 -I tools/tts_effects/tts_effects.py --root main=/srv/byond/main --root secondary=/srv/byond/secondary --port 5005
```

Options:

| Flag | Default | Meaning |
| --- | --- | --- |
| `--root` | required | `NAME=PATH`: a DreamDaemon working directory, served at `POST /NAME`. Repeat it for several servers. A bare `PATH` is served at `POST /`. Requests may only touch files under that root's `sound/tts_cache/`. |
| `--host` | `127.0.0.1` | Address to bind. Keep it on localhost: the service has no authentication. |
| `--port` | `5005` | Port to bind. |
| `--ffmpeg` | `ffmpeg` | ffmpeg executable. |
| `--timeout` | `15` | Seconds before an ffmpeg run is killed. Also how long a request waits for a free ffmpeg slot before it gets HTTP 503. |
| `--max-jobs` | CPUs in `--cpu-affinity`, else `2` | ffmpeg runs at once, across all roots. |
| `--cpu-affinity` | none | CPUs for the service and its ffmpeg runs, in taskset syntax (`0-3`, `1,4-7`). Linux only. Replaces `FFMPEG_CPUAFFINITY` for this path. |
| `--log-level` | `INFO` | Python logging level. |

Then set in each server's `config/config.txt` the URL ending in that server's root name:

```
TTS_EFFECTS_URL http://127.0.0.1:5005/main
```

`tts-effects.service` is an example systemd unit.

## Protocol

`POST /<root name>` with a JSON body of at most 4 KB. An unknown root name gets HTTP 404.

```json
{"effect": "radio", "input": "sound/tts_cache/Seed/abc.ogg", "output": "sound/tts_cache/Seed/abc_radio.ogg"}
```

Effects: `radio`, `robot`, `radio_robot`, `megaphone`, `megaphone_robot`, `maskfilter`, `radio_maskfilter`, `old_vocoder`.

The reply is `{"ok": true}` (HTTP 200) or `{"ok": false, "error": "<short>"}` (HTTP 4xx or 5xx).
On any failure, or with no reply within 20 seconds, DreamDaemon logs it (`log_debug`) and falls back to the shell ffmpeg call for that file.
A wrong root name in `TTS_EFFECTS_URL` therefore does not break voices, but every effect forks again: look for `TTS effects service` lines in the debug log after setting it up.

ffmpeg writes to a temporary file in the output's folder, which replaces the output only when ffmpeg succeeds, so a late reply never leaves a half-written file over the fallback's.

## Security

- No shell: ffmpeg runs through `subprocess.run` with an argument list.
- The effect is picked by name from a fixed table; the filter string never comes from the request.
- Paths must be relative. Each is joined with the root picked by the URL, resolved with `os.path.realpath` (symlinks included) and must stay inside `<root>/sound/tts_cache/`.
- The input must be an existing regular file; the output must end in `.ogg` and its directory must exist inside the cache.
- The request has 10 seconds to arrive whole; at most `--max-jobs` ffmpeg runs go at once.
- Logs hold the effect name, the resolved paths and the result, never the request body.

## Tests

```sh
python3 tools/tts_effects/test_tts_effects.py -v
```

The tests start the service on a free localhost port against a temporary root and a generated input file.
A script standing in for ffmpeg covers the timeout and failure paths. Effects whose filters the local ffmpeg lacks are skipped. A parity test checks that the filter chains match `sound.dm` byte for byte.
