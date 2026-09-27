#!/usr/bin/env python3
"""Update and compile the production TGServer instance through its local API.

This is installed as a root-owned forced SSH command on the game server. Its
credentials live in /etc/darkparadise/tgs-deploy.json, outside the repository.
"""

import base64
import json
import os
import re
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path


CONFIG_PATH = Path("/etc/darkparadise/tgs-deploy.json")
EXPECTED_ORIGIN = "https://github.com/KINGDICE666/DarkParadise"
EXPECTED_BRANCH = "master220"


class DeploymentError(Exception):
    pass


class TgsClient:
    def __init__(self, config):
        self.base_url = "http://127.0.0.1:5000/api"
        self.instance_id = str(config["instance_id"])
        self.username = config["username"]
        self.password = config["password"]
        self.api_version = "4.0.0.0"
        self.bearer = None

    def request(self, method, route, body=None, auth=None):
        headers = {
            "Accept": "application/json",
            "Api": f"Tgstation.Server.Api/{self.api_version}",
            "User-Agent": "DarkParadise-Deploy/1.0",
        }
        if route != "":
            headers["Instance"] = self.instance_id
        if auth:
            headers["Authorization"] = auth
        elif self.bearer:
            headers["Authorization"] = f"Bearer {self.bearer}"
        data = None if body is None else json.dumps(body).encode("utf-8")
        if data is not None:
            headers["Content-Type"] = "application/json"
        request = urllib.request.Request(
            f"{self.base_url}{route}", data=data, headers=headers, method=method
        )
        try:
            with urllib.request.urlopen(request, timeout=30) as response:
                payload = response.read()
                return json.loads(payload) if payload else {}
        except urllib.error.HTTPError as error:
            raise DeploymentError(f"TGServer {method} {route}: HTTP {error.code}") from error
        except urllib.error.URLError as error:
            raise DeploymentError(f"TGServer {method} {route}: connection failed") from error

    def login(self):
        info = self.request("GET", "")
        self.api_version = info["apiVersion"]
        credentials = base64.b64encode(
            f"{self.username}:{self.password}".encode("utf-8")
        ).decode("ascii")
        token = self.request("POST", "", body={}, auth=f"Basic {credentials}")
        self.bearer = token["bearer"]

    def wait_for_job(self, job_id, timeout_seconds):
        deadline = time.monotonic() + timeout_seconds
        while time.monotonic() < deadline:
            job = self.request("GET", f"/Job/{job_id}")
            if job.get("stoppedAt"):
                if job.get("cancelled") or job.get("errorCode") is not None:
                    raise DeploymentError(f"TGServer job {job_id} failed")
                return
            time.sleep(5)
        raise DeploymentError(f"TGServer job {job_id} timed out")


def parse_command():
    original = os.environ.get("SSH_ORIGINAL_COMMAND")
    if original is not None:
        command = original
    elif len(sys.argv) == 2 and sys.argv[1] == "--check":
        command = "check"
    else:
        raise DeploymentError("expected check or deploy <commit SHA>")
    if command == "check":
        return None
    match = re.fullmatch(r"deploy ([0-9a-f]{40})", command)
    if not match:
        raise DeploymentError("expected check or deploy <commit SHA>")
    return match.group(1)


def verify_repository(repository):
    origin = repository.get("origin", "").removesuffix(".git").rstrip("/")
    if origin != EXPECTED_ORIGIN or repository.get("reference") != EXPECTED_BRANCH:
        raise DeploymentError("TGServer repository or branch differs from DarkParadise")
    if repository.get("activeJob"):
        raise DeploymentError("TGServer repository already has an active job")
    revision = repository.get("revisionInformation") or {}
    if revision.get("activeTestMerges"):
        raise DeploymentError("TGServer has active test merges; deployment stopped")
    return revision.get("commitSha")


def main():
    target_sha = parse_command()
    config = json.loads(CONFIG_PATH.read_text(encoding="utf-8"))
    client = TgsClient(config)
    client.login()
    repository = client.request("GET", "/Repository")
    current_sha = verify_repository(repository)
    if target_sha is None:
        print(f"TGServer ready: {EXPECTED_BRANCH} at {current_sha}")
        return

    print(f"Updating {EXPECTED_BRANCH} to {target_sha}", flush=True)
    update = client.request("POST", "/Repository", {"updateFromOrigin": True})
    update_job = (update.get("activeJob") or {}).get("id")
    if update_job:
        client.wait_for_job(update_job, 1200)

    repository = client.request("GET", "/Repository")
    actual_sha = verify_repository(repository)
    if actual_sha != target_sha:
        raise DeploymentError(
            f"TGServer reached {actual_sha}, but workflow requested {target_sha}"
        )

    print("Compiling on TGServer", flush=True)
    compile_job = client.request("PUT", "/DreamMaker", {})
    job_id = compile_job.get("id")
    if not job_id:
        raise DeploymentError("TGServer did not return a compile job")
    client.wait_for_job(job_id, 3900)

    daemon = client.request("GET", "/DreamDaemon")
    staged = (daemon.get("activeCompileJob") or {}).get("revisionInformation") or {}
    if staged.get("commitSha") != target_sha:
        raise DeploymentError("compiled revision does not match the requested commit")
    print(f"Compiled {target_sha}; TGServer will use it on the next game round")


if __name__ == "__main__":
    try:
        main()
    except (DeploymentError, KeyError, OSError, ValueError) as error:
        print(f"Deployment error: {error}", file=sys.stderr)
        sys.exit(1)
