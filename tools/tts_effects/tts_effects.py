#!/usr/bin/env python3
"""Local HTTP service that applies TTS voice effects with ffmpeg.

DreamDaemon calls it through SShttp (config TTS_EFFECTS_URL) instead of forking
itself with world.shelleo. Standard library only.

Request:  POST /<root name>, JSON {"effect": "<name>", "input": "<relative path>", "output": "<relative path>"}
Response: JSON {"ok": true} or {"ok": false, "error": "<short>"}

One service can serve several game servers: each --root NAME=PATH is one DreamDaemon working
directory, and each server's TTS_EFFECTS_URL ends in its root name.
"""

import argparse
import json
import logging
import os
import re
import stat
import subprocess
import sys
import tempfile
import threading
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

MAX_BODY_BYTES = 4096
READ_TIMEOUT_SECONDS = 10
DEFAULT_ROOT_NAME = "default"
CACHE_DIR = os.path.join("sound", "tts_cache")
FFMPEG_BASE_ARGS = ["-y", "-hide_banner", "-loglevel", "error"]

# Effect name -> (filter chain, extra output options).
# The chains are byte-for-byte those of apply_sound_effect() in code/game/sound/sound.dm.
EFFECTS = {
    "radio": (
        "highpass=f=1000, lowpass=f=3000, acrusher=1:1:50:0:log",
        [],
    ),
    "robot": (
        "afftfilt=real='hypot(re,im)*sin(0)':imag='hypot(re,im)*cos(0)':win_size=1024:overlap=0.5, deesser=i=0.4, volume=volume=1.5",
        [],
    ),
    "radio_robot": (
        "afftfilt=real='hypot(re,im)*sin(0)':imag='hypot(re,im)*cos(0)':win_size=1024:overlap=0.5, deesser=i=0.4, volume=volume=1.5, highpass=f=1000, lowpass=f=3000, acrusher=1:1:50:0:log",
        [],
    ),
    "megaphone": (
        "highpass=f=500, lowpass=f=4000, volume=volume=10, acrusher=1:1:45:0:log",
        [],
    ),
    "megaphone_robot": (
        "afftfilt=real='hypot(re,im)*sin(0)':imag='hypot(re,im)*cos(0)':win_size=1024:overlap=0.5, deesser=i=0.4, highpass=f=500, lowpass=f=4000, volume=volume=10, acrusher=1:1:45:0:log",
        [],
    ),
    "maskfilter": (
        "rubberband=pitch=0.8, highpass=f=450, lowpass=f=3600, equalizer=f=180:t=q:w=1.0:g=3, equalizer=f=1100:t=q:w=1.2:g=4, equalizer=f=2400:t=q:w=1.0:g=2, acompressor=threshold=-22dB:ratio=5:attack=3:release=90, alimiter=level_in=1.4, acrusher=bits=12:mix=0.3, volume=2.0",
        [],
    ),
    "radio_maskfilter": (
        "rubberband=pitch=0.8, highpass=f=1000, lowpass=f=3000, equalizer=f=180:t=q:w=1.0:g=3, equalizer=f=1100:t=q:w=1.2:g=4, acompressor=threshold=-22dB:ratio=5:attack=3:release=90, acrusher=1:1:50:0:log, volume=2.0",
        [],
    ),
    "old_vocoder": (
        "rubberband=pitch=0.8, highpass=f=1000, lowpass=f=3000, equalizer=f=1500:t=q:w=3:g=10, equalizer=f=2200:t=q:w=4:g=12, equalizer=f=2800:t=q:w=5:g=9, acompressor=threshold=-22dB:ratio=5:attack=3:release=90, acrusher=1:1:50:0:log, volume=2.2, aresample=8000, aresample=22050",
        ["-ar", "8000", "-ac", "1", "-c:a", "libmp3lame", "-b:a", "32k"],
    ),
}

log = logging.getLogger("tts_effects")


class RequestError(Exception):
    """A request the service refuses; the message is returned to the caller."""

    def __init__(self, message, status=400):
        super().__init__(message)
        self.status = status


def build_command(ffmpeg, effect, input_path, output_path):
    """Returns the ffmpeg argument list for an allowlisted effect name."""
    if effect not in EFFECTS:
        raise RequestError("unknown effect")
    filter_chain, output_options = EFFECTS[effect]
    return [ffmpeg, *FFMPEG_BASE_ARGS, "-i", input_path, "-filter:a", filter_chain, *output_options, output_path]


def _is_inside(path, directory):
    return os.path.commonpath([path, directory]) == directory and path != directory


def resolve_cache_path(cache_dir, root, relative_path):
    """Joins a relative request path with root and checks that it resolves inside the TTS cache."""
    if not isinstance(relative_path, str) or not relative_path:
        raise RequestError("bad path")
    if "\x00" in relative_path or "\\" in relative_path or os.path.isabs(relative_path):
        raise RequestError("bad path")
    if ".." in relative_path.split("/"):
        raise RequestError("bad path")
    resolved = os.path.realpath(os.path.join(root, relative_path))
    if not _is_inside(resolved, cache_dir):
        raise RequestError("path outside cache")
    return resolved


def validate_request(cache_dir, root, payload):
    """Returns (effect, input_path, output_path) as absolute resolved paths, or raises RequestError."""
    if not isinstance(payload, dict):
        raise RequestError("bad request")
    effect = payload.get("effect")
    if not isinstance(effect, str) or effect not in EFFECTS:
        raise RequestError("unknown effect")

    input_path = resolve_cache_path(cache_dir, root, payload.get("input"))
    try:
        input_stat = os.stat(input_path)
    except OSError:
        raise RequestError("input missing") from None
    if not stat.S_ISREG(input_stat.st_mode):
        raise RequestError("input not a file")

    output = payload.get("output")
    if not isinstance(output, str) or not output.endswith(".ogg"):
        raise RequestError("output must be .ogg")
    output_path = resolve_cache_path(cache_dir, root, output)
    if not output_path.endswith(".ogg"):
        raise RequestError("output must be .ogg")
    if os.path.isdir(output_path):
        raise RequestError("output is a directory")
    if not os.path.isdir(os.path.dirname(output_path)):
        raise RequestError("output directory missing")
    if output_path == input_path:
        raise RequestError("output equals input")
    return effect, input_path, output_path


def run_effect(config, effect, input_path, output_path, jobs=None):
    """Runs ffmpeg for one effect. `jobs` caps how many ffmpeg runs go at once.

    ffmpeg writes a temporary file next to the output, which replaces the output only on success:
    a reply that comes after DreamDaemon gave up and ran its own fallback never leaves a half-written file.
    """
    if jobs is not None and not jobs.acquire(timeout=config.timeout):
        raise RequestError("busy", status=503)
    try:
        _run_ffmpeg(config, effect, input_path, output_path)
    finally:
        if jobs is not None:
            jobs.release()


def _run_ffmpeg(config, effect, input_path, output_path):
    output_dir = os.path.dirname(output_path)
    try:
        handle, temp_path = tempfile.mkstemp(prefix=".tts_effects_", suffix=".ogg", dir=output_dir)
    except OSError as error:
        raise RequestError(f"temp file not created: {error.strerror}", status=500) from None
    os.close(handle)
    command = build_command(config.ffmpeg, effect, input_path, temp_path)
    try:
        result = subprocess.run(
            command,
            cwd=output_dir,
            stdin=subprocess.DEVNULL,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            timeout=config.timeout,
            check=False,
        )
    except subprocess.TimeoutExpired:
        _remove_partial(temp_path)
        raise RequestError("ffmpeg timeout", status=500) from None
    except OSError as error:
        _remove_partial(temp_path)
        raise RequestError(f"ffmpeg not started: {error.strerror}", status=500) from None
    if result.returncode != 0:
        _remove_partial(temp_path)
        stderr = result.stderr.decode("utf-8", "replace").strip().splitlines()
        log.warning("ffmpeg failed for %s (%s): %s", effect, output_path, stderr[-1] if stderr else result.returncode)
        raise RequestError(f"ffmpeg exit {result.returncode}", status=500)
    try:
        os.chmod(temp_path, 0o644)
        os.replace(temp_path, output_path)
    except OSError as error:
        _remove_partial(temp_path)
        raise RequestError(f"output not written: {error.strerror}", status=500) from None


def _remove_partial(path):
    try:
        os.unlink(path)
    except FileNotFoundError:
        pass
    except OSError as error:
        log.warning("could not remove %s: %s", path, error.strerror)


class EffectsHandler(BaseHTTPRequestHandler):
    server_version = "tts_effects"
    sys_version = ""
    # Socket timeout for reading the request; a client that stalls mid-body is dropped.
    timeout = READ_TIMEOUT_SECONDS

    def do_POST(self):
        effect = input_path = output_path = None
        try:
            root, cache_dir = self._root()
            payload = self._read_json()
            effect, input_path, output_path = validate_request(cache_dir, root, payload)
            run_effect(self.server.config, effect, input_path, output_path, self.server.jobs)
        except RequestError as error:
            log.info("rejected effect=%s input=%s output=%s: %s", effect, input_path, output_path, error)
            self._reply(error.status, {"ok": False, "error": str(error)})
            return
        log.info("applied effect=%s input=%s output=%s", effect, input_path, output_path)
        self._reply(200, {"ok": True})

    def do_GET(self):
        self._reply(405, {"ok": False, "error": "method not allowed"})

    def _root(self):
        name = self.path.split("?", 1)[0].strip("/") or DEFAULT_ROOT_NAME
        if name not in self.server.roots:
            raise RequestError("unknown root", status=404)
        return self.server.roots[name]

    def _read_json(self):
        if self.headers.get("Transfer-Encoding"):
            raise RequestError("chunked body not supported", status=411)
        length_header = self.headers.get("Content-Length")
        if length_header is None:
            raise RequestError("length required", status=411)
        try:
            length = int(length_header)
        except ValueError:
            raise RequestError("bad length") from None
        if length < 0:
            raise RequestError("bad length")
        if length > MAX_BODY_BYTES:
            raise RequestError("body too large", status=413)
        body = self.rfile.read(length)
        try:
            return json.loads(body)
        except (UnicodeDecodeError, ValueError):
            raise RequestError("bad json") from None

    def _reply(self, status, payload):
        data = json.dumps(payload).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(data)))
        if status != 200:
            # The body may not have been read; do not reuse the connection.
            self.send_header("Connection", "close")
            self.close_connection = True
        self.end_headers()
        self.wfile.write(data)

    def log_message(self, format, *args):
        # Request lines only (method, path, status); bodies are never logged.
        log.debug("%s - %s", self.address_string(), format % args)


def parse_cpu_list(value):
    """Parses a taskset-style CPU list such as "0-3" or "1,4-7"."""
    cpus = set()
    for part in value.split(","):
        part = part.strip()
        if not part:
            raise argparse.ArgumentTypeError(f"bad CPU list: {value!r}")
        try:
            if "-" in part:
                first, last = (int(bound) for bound in part.split("-", 1))
                if first > last:
                    raise ValueError
                cpus.update(range(first, last + 1))
            else:
                cpus.add(int(part))
        except ValueError:
            raise argparse.ArgumentTypeError(f"bad CPU list: {value!r}") from None
    if not cpus or min(cpus) < 0:
        raise argparse.ArgumentTypeError(f"bad CPU list: {value!r}")
    return cpus


def parse_root(value):
    """Parses NAME=PATH, or a bare PATH for the default root."""
    name, sep, path = value.partition("=")
    if not sep:
        name, path = DEFAULT_ROOT_NAME, value
    if not path or not re.fullmatch(r"[A-Za-z0-9_-]+", name):
        raise argparse.ArgumentTypeError(f"bad root: {value!r} (expected NAME=PATH, NAME of letters, digits, - and _)")
    return name, os.path.realpath(path)


def parse_args(argv=None):
    parser = argparse.ArgumentParser(description="Applies TTS voice effects for DreamDaemon.")
    parser.add_argument("--root", required=True, action="append", type=parse_root,
                        help="NAME=PATH: a DreamDaemon working directory (holds sound/tts_cache), served at POST /NAME; "
                             "repeat for several servers. A bare PATH is served at POST /")
    parser.add_argument("--host", default="127.0.0.1", help="address to bind (default: 127.0.0.1)")
    parser.add_argument("--port", type=int, default=5005, help="port to bind (default: 5005)")
    parser.add_argument("--ffmpeg", default="ffmpeg", help="ffmpeg executable (default: ffmpeg from PATH)")
    parser.add_argument("--timeout", type=float, default=15.0, help="seconds before ffmpeg is killed (default: 15)")
    parser.add_argument("--cpu-affinity", type=parse_cpu_list, help='CPUs for the service and ffmpeg, taskset style: "0-3" or "1,4-7"')
    parser.add_argument("--max-jobs", type=int, help="ffmpeg runs at once (default: CPUs in --cpu-affinity, else 2)")
    parser.add_argument("--log-level", default="INFO", choices=["DEBUG", "INFO", "WARNING", "ERROR"])
    args = parser.parse_args(argv)
    if args.timeout <= 0:
        parser.error("--timeout must be positive")
    roots = dict(args.root)
    if len(roots) != len(args.root):
        parser.error("--root names must be unique")
    args.root = roots
    if args.max_jobs is None:
        args.max_jobs = len(args.cpu_affinity) if args.cpu_affinity else 2
    if args.max_jobs < 1:
        parser.error("--max-jobs must be at least 1")
    return args


def make_server(config):
    roots = {}
    for name, root in config.root.items():
        cache_dir = os.path.realpath(os.path.join(root, CACHE_DIR))
        if not os.path.isdir(cache_dir):
            raise SystemExit(f"cache directory not found: {cache_dir}")
        roots[name] = (root, cache_dir)
    server = ThreadingHTTPServer((config.host, config.port), EffectsHandler)
    server.daemon_threads = True
    server.config = config
    server.roots = roots
    server.jobs = threading.BoundedSemaphore(config.max_jobs)
    return server


def main(argv=None):
    config = parse_args(argv)
    logging.basicConfig(level=config.log_level, format="%(asctime)s %(levelname)s %(message)s")
    if config.cpu_affinity is not None:
        if not hasattr(os, "sched_setaffinity"):
            raise SystemExit("--cpu-affinity is not supported on this platform")
        # ffmpeg children inherit the affinity, replacing the taskset prefix of the shell path.
        os.sched_setaffinity(0, config.cpu_affinity)
    server = make_server(config)
    host, port = server.server_address[:2]
    for name, (_root, cache_dir) in sorted(server.roots.items()):
        log.info("root %s: cache %s", name, cache_dir)
    log.info("listening on %s:%s, %d ffmpeg run(s) at once", host, port, config.max_jobs)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()
    return 0


if __name__ == "__main__":
    sys.exit(main())
