"""Minimal DMI reader/writer used by the species fitting harness."""
import re
import struct
import subprocess
import zlib
from io import BytesIO

from PIL import Image

TRUNK_STATES = ("torso_m", "groin_m")
LIMB_STATES = ("l_arm", "r_arm", "l_hand", "r_hand", "l_leg", "r_leg", "l_foot", "r_foot")
DIR_ORDER = ("SOUTH", "NORTH", "EAST", "WEST")


def read_bytes(path, git_ref=None):
    if git_ref:
        return subprocess.run(["git", "show", f"{git_ref}:{path}"],
                              check=True, capture_output=True).stdout
    with open(path, "rb") as handle:
        return handle.read()


def _description(data):
    pos = 8
    while pos < len(data):
        length = struct.unpack(">I", data[pos:pos + 4])[0]
        chunk = data[pos + 4:pos + 8]
        payload = data[pos + 8:pos + 8 + length]
        if chunk == b"zTXt":
            _, rest = payload.split(b"\x00", 1)
            return zlib.decompress(rest[1:]).decode()
        if chunk == b"tEXt":
            _, rest = payload.split(b"\x00", 1)
            return rest.decode()
        pos += 12 + length
    raise ValueError("no description chunk")


def read_dmi(path, git_ref=None):
    data = read_bytes(path, git_ref)
    description = _description(data)
    width = int(re.search(r"\twidth = (\d+)", description).group(1))
    height = int(re.search(r"\theight = (\d+)", description).group(1))
    states, current = [], None
    for line in description.splitlines():
        stripped = line.strip()
        if stripped.startswith("state = "):
            current = {"name": stripped[8:].strip('"'), "dirs": 1, "frames": 1}
            states.append(current)
        elif current and stripped.startswith("dirs = "):
            current["dirs"] = int(stripped[7:])
        elif current and stripped.startswith("frames = "):
            current["frames"] = int(stripped[9:])
    sheet = Image.open(BytesIO(data)).convert("RGBA")
    columns = sheet.width // width
    index, out = 0, {}
    for state in states:
        frames = []
        for _ in range(state["dirs"] * state["frames"]):
            left = (index % columns) * width
            top = (index // columns) * height
            frames.append(sheet.crop((left, top, left + width, top + height)))
            index += 1
        out[state["name"]] = (state["dirs"], frames)
    return out, width, height


def frame_for_dir(sheet, state, dir_index):
    dirs, frames = sheet[state]
    return frames[dir_index] if dirs > dir_index else frames[0]


def body_mask(sheet, states, dir_index, width, height):
    mask = set()
    for state in states:
        if state not in sheet:
            continue
        image = frame_for_dir(sheet, state, dir_index)
        pixels = image.load()
        for y in range(height):
            for x in range(width):
                if pixels[x, y][3] > 0:
                    mask.add((x, y))
    return mask
