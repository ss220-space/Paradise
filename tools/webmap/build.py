#!/usr/bin/env python3
"""Slice rendered station PNGs into Leaflet tile pyramids and emit the static site."""

import argparse
import hashlib
import json
import math
import shutil
import urllib.request
from pathlib import Path

from PIL import Image

LEAFLET_VERSION = "1.9.4"
LEAFLET_FILES = [
    "leaflet.js",
    "leaflet.css",
    "images/layers.png",
    "images/layers-2x.png",
    "images/marker-icon.png",
    "images/marker-icon-2x.png",
    "images/marker-shadow.png",
]

Image.MAX_IMAGE_PIXELS = None


def render_candidates(dmm_path, z):
    stem = Path(dmm_path).stem
    return [
        f"{stem}-{z}.png",
        f"{stem}_nanomap_z{z}.png",
        f"{stem.capitalize()}_nanomap_z{z}.png",
    ]


def find_render(renders, dmm_path, z):
    names = render_candidates(dmm_path, z)
    for name in names:
        candidate = renders / name
        if candidate.exists():
            return candidate
    return None


def source_version(path):
    digest = hashlib.md5()
    with open(path, "rb") as handle:
        for chunk in iter(lambda: handle.read(1 << 20), b""):
            digest.update(chunk)
    return digest.hexdigest()[:10]


def build_pyramid(image, out_dir, tile_size):
    width, height = image.size
    max_zoom = max(0, math.ceil(math.log2(max(width, height) / tile_size)))
    written = 0
    for zoom in range(max_zoom, -1, -1):
        scale = 2 ** (max_zoom - zoom)
        level_w = max(1, math.ceil(width / scale))
        level_h = max(1, math.ceil(height / scale))
        level = image if scale == 1 else image.resize((level_w, level_h), Image.LANCZOS)
        cols = math.ceil(level_w / tile_size)
        rows = math.ceil(level_h / tile_size)
        for x in range(cols):
            col_dir = out_dir / str(zoom) / str(x)
            col_dir.mkdir(parents=True, exist_ok=True)
            for y in range(rows):
                box = (
                    x * tile_size,
                    y * tile_size,
                    min((x + 1) * tile_size, level_w),
                    min((y + 1) * tile_size, level_h),
                )
                tile = level.crop(box)
                if tile.size != (tile_size, tile_size):
                    padded = Image.new("RGBA", (tile_size, tile_size), (0, 0, 0, 0))
                    padded.paste(tile, (0, 0))
                    tile = padded
                if tile.getbbox() is None:
                    continue
                tile.save(col_dir / f"{y}.png", optimize=True)
                written += 1
            if not any(col_dir.iterdir()):
                col_dir.rmdir()
        if level is not image:
            level.close()
    return max_zoom, written


def vendor_leaflet(out_root, allow_offline):
    target = out_root / "leaflet"
    if (target / "leaflet.js").exists():
        return True
    (target / "images").mkdir(parents=True, exist_ok=True)
    for name in LEAFLET_FILES:
        url = f"https://unpkg.com/leaflet@{LEAFLET_VERSION}/dist/{name}"
        try:
            with urllib.request.urlopen(url, timeout=30) as response:
                (target / name).write_bytes(response.read())
        except Exception as error:
            if allow_offline:
                print(f"  ! leaflet download failed ({error}), page will not render until vendored")
                return False
            raise SystemExit(f"failed to download {url}: {error}")
    return True


def render_template(path, replacements):
    text = path.read_text(encoding="utf-8")
    for key, value in replacements.items():
        text = text.replace("{{" + key + "}}", value)
    return text


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--maps", default="tools/webmap/maps.json")
    parser.add_argument("--renders", default="data/nanomaps")
    parser.add_argument("--out", default="dist/webmap")
    parser.add_argument("--skip-missing", action="store_true")
    parser.add_argument("--allow-offline", action="store_true")
    parser.add_argument("--pixels-per-turf", type=int)
    args = parser.parse_args()

    config = json.loads(Path(args.maps).read_text(encoding="utf-8"))
    tile_size = config.get("tile_size", 256)
    pixels_per_turf = args.pixels_per_turf or config.get("pixels_per_turf", 32)
    templates = Path(args.maps).parent / "template"
    renders = Path(args.renders)
    out_root = Path(args.out)
    out_root.mkdir(parents=True, exist_ok=True)
    css_version = source_version(templates / "webmap.css")

    built = []
    for entry in config["maps"]:
        levels = []
        for level in entry["levels"]:
            source = find_render(renders, entry["dmm"], level["z"])
            if source is None:
                message = f"missing render {renders / render_candidates(entry['dmm'], level['z'])[0]}"
                if args.skip_missing:
                    print(f"  ! {entry['key']}: {message}, skipped")
                    continue
                raise SystemExit(message)
            map_dir = out_root / entry["key"]
            tiles_dir = map_dir / "tiles" / f"z{level['z']}"
            if tiles_dir.exists():
                shutil.rmtree(tiles_dir)
            with Image.open(source) as raw:
                image = raw.convert("RGBA")
            max_zoom, count = build_pyramid(image, tiles_dir, tile_size)
            print(f"  {entry['key']} z{level['z']}: {image.size[0]}x{image.size[1]}px, {count} tiles, max zoom {max_zoom}")
            levels.append(
                {
                    "z": level["z"],
                    "label": level["label"],
                    "width": image.size[0],
                    "height": image.size[1],
                    "max_zoom": max_zoom,
                    "version": source_version(source),
                }
            )
            image.close()
        if not levels:
            continue

        page_config = {
            "key": entry["key"],
            "name": entry["name"],
            "station_name": entry["station_name"],
            "tile_size": tile_size,
            "pixels_per_turf": pixels_per_turf,
            "levels": levels,
        }
        page = render_template(
            templates / "map.html",
            {
                "TITLE": f"{entry['station_name']} ({entry['name']}) — Dark Paradise",
                "STATION_NAME": entry["station_name"],
                "MAP_NAME": entry["name"],
                "CONFIG": json.dumps(page_config, ensure_ascii=False),
                "CSS_VERSION": css_version,
                "LEAFLET_VERSION": LEAFLET_VERSION,
            },
        )
        (out_root / entry["key"] / "index.html").write_text(page, encoding="utf-8")
        built.append(entry)

    cards = "\n".join(
        f'      <a class="card" href="{entry["key"]}/">'
        f'<span class="card-station">{entry["station_name"]}</span>'
        f'<span class="card-name">{entry["name"]}</span></a>'
        for entry in built
    )
    index = render_template(
        templates / "index.html",
        {
            "TITLE": config["site_title"],
            "SITE_TITLE": config["site_title"],
            "CARDS": cards,
            "CSS_VERSION": css_version,
        },
    )
    (out_root / "index.html").write_text(index, encoding="utf-8")
    shutil.copy(templates / "webmap.css", out_root / "webmap.css")
    shutil.copy(templates / "space.png", out_root / "space.png")
    shutil.copy(templates / "favicon.ico", out_root / "favicon.ico")
    shutil.copy(templates / "apple-touch-icon.png", out_root / "apple-touch-icon.png")
    vendor_leaflet(out_root, args.allow_offline)

    print(f"built {len(built)} maps into {out_root}")


if __name__ == "__main__":
    main()
