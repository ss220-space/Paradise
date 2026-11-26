#!/usr/bin/env python3
"""Tests for tts_effects.py: starts the service on a free localhost port against a temporary root.

Run: python3 tools/tts_effects/test_tts_effects.py -v
Needs ffmpeg on PATH (or FFMPEG=/path/to/ffmpeg). Effects whose filters this ffmpeg lacks are skipped.
"""

import http.client
import importlib.util
import json
import os
import re
import shutil
import socket
import subprocess
import sys
import tempfile
import threading
import time
import unittest
from contextlib import redirect_stderr
from types import SimpleNamespace

HERE = os.path.dirname(os.path.abspath(__file__))
SERVICE = os.path.join(HERE, "tts_effects.py")
SOUND_DM = os.path.join(HERE, "..", "..", "code", "game", "sound", "sound.dm")
FFMPEG = os.environ.get("FFMPEG") or shutil.which("ffmpeg")

DM_EFFECT_NAMES = {
    "SOUND_EFFECT_RADIO": "radio",
    "SOUND_EFFECT_ROBOT": "robot",
    "SOUND_EFFECT_RADIO_ROBOT": "radio_robot",
    "SOUND_EFFECT_MEGAPHONE": "megaphone",
    "SOUND_EFFECT_MEGAPHONE_ROBOT": "megaphone_robot",
    "SOUND_EFFECT_MASKFILTER": "maskfilter",
    "SOUND_EFFECT_RADIO_MASKFILTER": "radio_maskfilter",
    "SOUND_EFFECT_OLD_VOCODER": "old_vocoder",
}


def load_service_module():
    sys.dont_write_bytecode = True
    spec = importlib.util.spec_from_file_location("tts_effects", SERVICE)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


tts_effects = load_service_module()


def free_port():
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
        sock.bind(("127.0.0.1", 0))
        return sock.getsockname()[1]


def start_service(*args):
    """Starts the service on a free port; returns (process, port)."""
    port = free_port()
    process = subprocess.Popen(
        [sys.executable, "-I", SERVICE, "--port", str(port), "--log-level", "WARNING", *args],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    deadline = time.monotonic() + 10
    while True:
        try:
            socket.create_connection(("127.0.0.1", port), timeout=0.2).close()
            return process, port
        except OSError:
            if process.poll() is not None or time.monotonic() > deadline:
                stop_service(process)
                raise RuntimeError("service did not start")
            time.sleep(0.05)


def stop_service(process):
    if process.poll() is None:
        process.terminate()
        try:
            process.wait(timeout=5)
        except subprocess.TimeoutExpired:
            process.kill()
            process.wait()


def post(port, payload=None, raw=None, path="/"):
    body = raw if raw is not None else json.dumps(payload).encode("utf-8")
    connection = http.client.HTTPConnection("127.0.0.1", port, timeout=60)
    try:
        connection.request("POST", path, body=body, headers={"Content-Type": "application/json"})
        response = connection.getresponse()
        return response.status, json.loads(response.read())
    finally:
        connection.close()


def make_root(base, name):
    root = os.path.join(base, name)
    os.makedirs(os.path.join(root, "sound", "tts_cache", "Seed"))
    return root


def available_filters():
    if not FFMPEG:
        return set()
    output = subprocess.run([FFMPEG, "-hide_banner", "-filters"], capture_output=True, text=True, check=False).stdout
    return {line.split()[1] for line in output.splitlines() if len(line.split()) > 2 and "->" in line.split()[2]}


def chain_filters(chain):
    return {part.strip().split("=", 1)[0] for part in chain.split(", ")}


@unittest.skipUnless(FFMPEG, "ffmpeg not found")
class ServiceTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.tmp = tempfile.mkdtemp(prefix="tts_effects_test_")
        cls.root = make_root(cls.tmp, "root")
        cls.root2 = make_root(cls.tmp, "root2")
        cls.cache = os.path.join(cls.root, "sound", "tts_cache")
        cls.seed_dir = os.path.join(cls.cache, "Seed")
        cls.outside = os.path.join(cls.tmp, "outside")
        os.makedirs(cls.outside)
        os.makedirs(os.path.join(cls.root, "config"))
        cls.input_rel = "sound/tts_cache/Seed/voice.ogg"
        subprocess.run(
            [FFMPEG, "-y", "-hide_banner", "-loglevel", "error", "-f", "lavfi", "-i", "sine=frequency=440:duration=1",
             os.path.join(cls.root, cls.input_rel)],
            check=True,
        )
        shutil.copy(os.path.join(cls.root, cls.input_rel), os.path.join(cls.outside, "secret.ogg"))
        shutil.copy(os.path.join(cls.root, cls.input_rel), os.path.join(cls.root, "config", "notcache.ogg"))
        os.symlink(os.path.join(cls.outside, "secret.ogg"), os.path.join(cls.seed_dir, "link_out.ogg"))
        os.symlink(cls.outside, os.path.join(cls.cache, "dir_out"))
        os.symlink(os.path.join(cls.seed_dir, "target.sh"), os.path.join(cls.seed_dir, "alias.ogg"))
        os.makedirs(os.path.join(cls.seed_dir, "folder.ogg"))
        with open(os.path.join(cls.seed_dir, "corrupt.ogg"), "wb") as corrupt:
            corrupt.write(b"not an ogg file" * 64)
        shutil.copy(os.path.join(cls.root, cls.input_rel), os.path.join(cls.root2, cls.input_rel))

        cls.filters = available_filters()
        try:
            cls.process, cls.port = start_service(
                "--root", cls.root, "--root", f"second={cls.root2}", "--ffmpeg", FFMPEG, "--timeout", "30")
        except Exception:
            shutil.rmtree(cls.tmp, ignore_errors=True)
            raise

    @classmethod
    def tearDownClass(cls):
        stop_service(cls.process)
        shutil.rmtree(cls.tmp, ignore_errors=True)

    def post(self, payload=None, raw=None, path="/"):
        return post(self.port, payload, raw, path)

    def assert_rejected(self, payload, error, status=400, path="/"):
        result_status, result = self.post(payload, path=path)
        self.assertEqual(result_status, status, result)
        self.assertEqual(result, {"ok": False, "error": error})
        self.assertEqual(os.listdir(self.outside), ["secret.ogg"])

    def request(self, effect="radio", input_rel=None, output_rel="sound/tts_cache/Seed/voice_out.ogg"):
        return {"effect": effect, "input": input_rel or self.input_rel, "output": output_rel}

    # Each effect produces its file.

    def check_effect(self, effect):
        missing = chain_filters(tts_effects.EFFECTS[effect][0]) - self.filters
        if missing:
            self.skipTest(f"ffmpeg lacks filter(s): {', '.join(sorted(missing))}")
        output_rel = f"sound/tts_cache/Seed/voice_{effect}.ogg"
        status, result = self.post(self.request(effect, output_rel=output_rel))
        self.assertEqual((status, result), (200, {"ok": True}))
        output = os.path.join(self.root, output_rel)
        self.assertTrue(os.path.isfile(output))
        self.assertGreater(os.path.getsize(output), 0)

    # Rejections.

    def test_unknown_effect(self):
        self.assert_rejected(self.request("echo"), "unknown effect")

    def test_filter_string_as_effect(self):
        self.assert_rejected(self.request("highpass=f=1000"), "unknown effect")

    def test_traversal_input(self):
        self.assert_rejected(self.request(input_rel="sound/tts_cache/../../../outside/secret.ogg"), "bad path")

    def test_traversal_output(self):
        self.assert_rejected(self.request(output_rel="sound/tts_cache/Seed/../../../../outside/x.ogg"), "bad path")

    def test_absolute_input(self):
        self.assert_rejected(self.request(input_rel=os.path.join(self.outside, "secret.ogg")), "bad path")

    def test_absolute_output(self):
        self.assert_rejected(self.request(output_rel=os.path.join(self.outside, "x.ogg")), "bad path")

    def test_input_outside_cache(self):
        self.assert_rejected(self.request(input_rel="config/notcache.ogg"), "path outside cache")

    def test_symlink_input_escapes_cache(self):
        self.assert_rejected(self.request(input_rel="sound/tts_cache/Seed/link_out.ogg"), "path outside cache")

    def test_symlink_output_dir_escapes_cache(self):
        self.assert_rejected(self.request(output_rel="sound/tts_cache/dir_out/x.ogg"), "path outside cache")

    def test_output_not_ogg(self):
        self.assert_rejected(self.request(output_rel="sound/tts_cache/Seed/voice_out.sh"), "output must be .ogg")

    def test_output_dir_missing(self):
        self.assert_rejected(self.request(output_rel="sound/tts_cache/Nope/voice_out.ogg"), "output directory missing")

    def test_missing_input(self):
        self.assert_rejected(self.request(input_rel="sound/tts_cache/Seed/missing.ogg"), "input missing")

    def test_input_is_directory(self):
        self.assert_rejected(self.request(input_rel="sound/tts_cache/Seed"), "input not a file")

    def test_output_equals_input(self):
        self.assert_rejected(self.request(output_rel=self.input_rel), "output equals input")

    def test_oversized_body(self):
        payload = self.request()
        payload["padding"] = "x" * (tts_effects.MAX_BODY_BYTES + 1)
        self.assert_rejected(payload, "body too large", status=413)

    def test_bad_json(self):
        status, result = self.post(raw=b"{not json")
        self.assertEqual((status, result), (400, {"ok": False, "error": "bad json"}))

    def test_output_is_directory(self):
        self.assert_rejected(self.request(output_rel="sound/tts_cache/Seed/folder.ogg"), "output is a directory")

    def test_output_symlink_to_non_ogg(self):
        self.assert_rejected(self.request(output_rel="sound/tts_cache/Seed/alias.ogg"), "output must be .ogg")
        self.assertFalse(os.path.lexists(os.path.join(self.seed_dir, "target.sh")))

    def test_corrupt_input_fails_without_output(self):
        output_rel = "sound/tts_cache/Seed/corrupt_radio.ogg"
        status, result = self.post(self.request(input_rel="sound/tts_cache/Seed/corrupt.ogg", output_rel=output_rel))
        self.assertEqual(status, 500, result)
        self.assertFalse(result["ok"])
        self.assertTrue(result["error"].startswith("ffmpeg exit "), result)
        self.assertFalse(os.path.exists(os.path.join(self.root, output_rel)))

    # Several roots.

    def test_named_root_writes_into_its_own_cache(self):
        output_rel = "sound/tts_cache/Seed/second_radio.ogg"
        for path in ("/second", "/second/"):
            status, result = self.post(self.request(output_rel=output_rel), path=path)
            self.assertEqual((status, result), (200, {"ok": True}))
        self.assertTrue(os.path.isfile(os.path.join(self.root2, output_rel)))
        self.assertFalse(os.path.exists(os.path.join(self.root, output_rel)))

    def test_named_root_cannot_read_other_root(self):
        self.assert_rejected(self.request(input_rel="sound/tts_cache/../../../root/sound/tts_cache/Seed/voice.ogg"),
                             "bad path", path="/second")
        os.remove(os.path.join(self.root2, "sound", "tts_cache", "Seed", "voice.ogg"))
        try:
            self.assert_rejected(self.request(), "input missing", path="/second")
        finally:
            shutil.copy(os.path.join(self.root, self.input_rel), os.path.join(self.root2, self.input_rel))

    def test_query_string_ignored(self):
        output_rel = "sound/tts_cache/Seed/query_radio.ogg"
        status, result = self.post(self.request(output_rel=output_rel), path="/second?x=1")
        self.assertEqual((status, result), (200, {"ok": True}))
        self.assertTrue(os.path.isfile(os.path.join(self.root2, output_rel)))

    def test_unknown_root(self):
        self.assert_rejected(self.request(), "unknown root", status=404, path="/nope")
        self.assert_rejected(self.request(), "unknown root", status=404, path="/second/x")

    def test_missing_content_length(self):
        with socket.create_connection(("127.0.0.1", self.port), timeout=10) as sock:
            sock.sendall(b"POST / HTTP/1.1\r\nHost: 127.0.0.1\r\nTransfer-Encoding: chunked\r\n\r\n0\r\n\r\n")
            reply = sock.recv(4096).decode("utf-8", "replace")
        self.assertTrue(reply.startswith("HTTP/1.0 411") or reply.startswith("HTTP/1.1 411"), reply)

    def raw_status(self, request):
        with socket.create_connection(("127.0.0.1", self.port), timeout=10) as sock:
            sock.sendall(request)
            return sock.recv(4096).decode("utf-8", "replace").split(" ", 2)[1]

    def test_no_length_headers(self):
        self.assertEqual(self.raw_status(b"POST / HTTP/1.1\r\nHost: 127.0.0.1\r\n\r\n"), "411")

    def test_negative_length(self):
        self.assertEqual(self.raw_status(b"POST / HTTP/1.1\r\nHost: 127.0.0.1\r\nContent-Length: -1\r\n\r\n"), "400")


for _effect in tts_effects.EFFECTS:
    setattr(ServiceTest, f"test_effect_{_effect}", lambda self, effect=_effect: self.check_effect(effect))


FAKE_FFMPEG = """#!/bin/sh
# Stands in for ffmpeg: writes a partial output, then sleeps or fails depending on the input name.
for last in "$@"; do :; done
printf partial > "$last"
case "$6" in
  *sleep*) exec sleep 10 ;;
  *) exit 3 ;;
esac
"""


class FakeFfmpegTest(unittest.TestCase):
    """Timeout and failure paths, with a script standing in for ffmpeg."""

    @classmethod
    def setUpClass(cls):
        cls.tmp = tempfile.mkdtemp(prefix="tts_effects_fake_")
        cls.root = make_root(cls.tmp, "root")
        cls.seed_dir = os.path.join(cls.root, "sound", "tts_cache", "Seed")
        for name in ("sleep.ogg", "fail.ogg"):
            with open(os.path.join(cls.seed_dir, name), "wb") as input_file:
                input_file.write(b"input")
        fake = os.path.join(cls.tmp, "fake_ffmpeg")
        with open(fake, "w", encoding="utf-8") as fake_file:
            fake_file.write(FAKE_FFMPEG)
        os.chmod(fake, 0o755)
        try:
            cls.process, cls.port = start_service("--root", cls.root, "--ffmpeg", fake, "--timeout", "1")
        except Exception:
            shutil.rmtree(cls.tmp, ignore_errors=True)
            raise

    @classmethod
    def tearDownClass(cls):
        stop_service(cls.process)
        shutil.rmtree(cls.tmp, ignore_errors=True)

    def run_fake(self, input_name, existing=None):
        output = os.path.join(self.seed_dir, f"{input_name}_out.ogg")
        if existing is not None:
            with open(output, "wb") as output_file:
                output_file.write(existing)
        self.addCleanup(lambda: os.path.exists(output) and os.remove(output))
        started = time.monotonic()
        status, result = post(self.port, {"effect": "radio", "input": f"sound/tts_cache/Seed/{input_name}.ogg",
                                          "output": f"sound/tts_cache/Seed/{input_name}_out.ogg"})
        elapsed = time.monotonic() - started
        self.assertEqual([name for name in os.listdir(self.seed_dir) if name.startswith(".tts_effects_")], [])
        return status, result, output, elapsed

    def test_timeout_removes_partial_output(self):
        status, result, output, elapsed = self.run_fake("sleep")
        self.assertEqual((status, result), (500, {"ok": False, "error": "ffmpeg timeout"}))
        self.assertFalse(os.path.exists(output))
        self.assertLess(elapsed, 5)

    def test_failure_removes_partial_output(self):
        status, result, output, _elapsed = self.run_fake("fail")
        self.assertEqual((status, result), (500, {"ok": False, "error": "ffmpeg exit 3"}))
        self.assertFalse(os.path.exists(output))

    def test_failure_keeps_existing_output(self):
        # DreamDaemon's shell fallback may already have written the output; a late failure must not touch it.
        for input_name in ("fail", "sleep"):
            _status, _result, output, _elapsed = self.run_fake(input_name, existing=b"fallback output")
            with open(output, "rb") as output_file:
                self.assertEqual(output_file.read(), b"fallback output", input_name)


class FilterParityTest(unittest.TestCase):
    """The service's ffmpeg arguments match apply_sound_effect() in sound.dm byte for byte."""

    @unittest.skipUnless(os.path.isfile(SOUND_DM), "sound.dm not found")
    def test_chains_match_sound_dm(self):
        with open(SOUND_DM, encoding="utf-8") as dm_file:
            source = dm_file.read()
        proc = source[source.index("/proc/apply_sound_effect("):]
        pattern = re.compile(
            r'if\((SOUND_EFFECT_\w+)\)\n\t+output = world\.shelleo\(\{"\[taskset\] ffmpeg -y -hide_banner -loglevel error '
            r'-i \[filename_input\] -filter:a "(.*?)" ?(.*?)\[filename_output\]"\}\)'
        )
        found = {DM_EFFECT_NAMES[name]: (chain, extra.split()) for name, chain, extra in pattern.findall(proc)}
        self.assertEqual(found, tts_effects.EFFECTS)

    def test_command_has_no_shell(self):
        command = tts_effects.build_command("ffmpeg", "radio", "/r/in.ogg", "/r/out.ogg")
        self.assertEqual(
            command,
            ["ffmpeg", "-y", "-hide_banner", "-loglevel", "error", "-i", "/r/in.ogg", "-filter:a",
             tts_effects.EFFECTS["radio"][0], "/r/out.ogg"],
        )


class CpuListTest(unittest.TestCase):
    def test_parse(self):
        self.assertEqual(tts_effects.parse_cpu_list("0-3"), {0, 1, 2, 3})
        self.assertEqual(tts_effects.parse_cpu_list("1,4-6"), {1, 4, 5, 6})
        for bad in ("", "a", "3-1", "1;2", "-1"):
            with self.assertRaises(Exception, msg=bad):
                tts_effects.parse_cpu_list(bad)


class ArgsTest(unittest.TestCase):
    def parse(self, *argv):
        return tts_effects.parse_args(list(argv))

    def test_defaults(self):
        args = self.parse("--root", "/srv/game")
        self.assertEqual(args.host, "127.0.0.1")
        self.assertEqual(args.root, {"default": os.path.realpath("/srv/game")})
        self.assertEqual(args.max_jobs, 2)

    def test_named_roots_and_jobs_from_affinity(self):
        args = self.parse("--root", "main=/srv/main", "--root", "secondary=/srv/sec", "--cpu-affinity", "0-3")
        self.assertEqual(set(args.root), {"main", "secondary"})
        self.assertEqual(args.max_jobs, 4)
        self.assertEqual(self.parse("--root", "/srv/game", "--max-jobs", "1").max_jobs, 1)

    def test_rejected(self):
        bad = (
            ["--root", "a=/x", "--root", "a=/y"],
            ["--root", "bad name=/x"],
            ["--root", "=/x"],
            ["--root", "a="],
            ["--root", "../x=/x"],
            ["--root", "/x", "--max-jobs", "0"],
            ["--root", "/x", "--timeout", "0"],
        )
        with open(os.devnull, "w", encoding="utf-8") as devnull, redirect_stderr(devnull):
            for argv in bad:
                with self.assertRaises(SystemExit, msg=argv):
                    self.parse(*argv)

    def test_read_timeout_set(self):
        self.assertEqual(tts_effects.EffectsHandler.timeout, tts_effects.READ_TIMEOUT_SECONDS)
        self.assertGreater(tts_effects.READ_TIMEOUT_SECONDS, 0)

    def test_missing_cache_refused_at_start(self):
        with tempfile.TemporaryDirectory() as tmp:
            good = make_root(tmp, "good")
            config = self.parse("--root", f"good={good}", "--root", f"bad={os.path.join(tmp, 'bad')}", "--port", "0")
            with self.assertRaises(SystemExit) as caught:
                tts_effects.make_server(config)
            self.assertIn("cache directory not found", str(caught.exception))

    def test_busy_when_all_jobs_taken(self):
        jobs = threading.BoundedSemaphore(1)
        jobs.acquire()
        config = SimpleNamespace(ffmpeg="/nonexistent/ffmpeg", timeout=0.1)
        with self.assertRaises(tts_effects.RequestError) as caught:
            tts_effects.run_effect(config, "radio", "/r/in.ogg", "/r/out.ogg", jobs)
        self.assertEqual((str(caught.exception), caught.exception.status), ("busy", 503))


if __name__ == "__main__":
    unittest.main()
