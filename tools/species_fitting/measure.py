"""Score the generated fit against the hand-drawn species sheets.

    python measure.py --target icons/mob/human_races/r_resomi.dmi --trim shrink \
        --target-git-ref ResomiNEWVodka --git-ref ResomiNEWVodka \
        --pair icons/mob/clothing/suit.dmi:icons/mob/clothing/species/resomi/suit.dmi

Fully transparent pixels are never compared by colour: their RGB is garbage and
inflates every metric. The bare-skin axis skips the head mask, so it says nothing
about helmets, masks or glasses - read cloth over the head for those.
"""
import argparse
import re
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from dmi import DIR_ORDER, LIMB_STATES, TRUNK_STATES, body_mask, frame_for_dir, read_dmi
from fit import SpeciesFit

REFERENCE = "icons/mob/human_races/r_human.dmi"
PROFILE_SOURCE = "code/modules/mob/living/carbon/human/species/fitting/species_fits.dm"
SPECIES_SHEETS = Path("icons/mob/clothing/species")
VANILLA_SHEETS = Path("icons/mob/clothing")
NOT_WORN = ("held.dmi", "underwear.dmi")
MIN_SHARED_STATES = 8


def read_profiles():
    """Every species profile, straight out of the DM so the two cannot drift apart."""
    profiles, name = {}, None
    defines = dict(re.findall(r"#define (DEFAULT_ICON_\w+) '([^']+)'",
                              Path("code/__DEFINES/clothing.dm").read_text(encoding="utf-8")))
    section = None
    for line in Path(PROFILE_SOURCE).read_text(encoding="utf-8").splitlines():
        header = re.match(r"^/datum/species_fit/(\w+)", line)
        if header:
            section = None
            name = header.group(1)
            profiles[name] = {"target": None, "bare_parts": (), "max_squash": 0, "pixel_map": None, "manual_sheets": {}, "blocked_sheets": []}
            continue
        if not name:
            continue
        if line in ("\tmanual_sheets = list(", "\tblocked_sheets = list("):
            section = "manual_sheets" if "manual_sheets" in line else "blocked_sheets"
            continue
        if section:
            if line == "\t)":
                section = None
                continue
            entries = re.findall(r"'([^']+)'|(DEFAULT_ICON_\w+)", line)
            paths = [literal or defines[constant] for literal, constant in entries]
            if section == "manual_sheets" and len(paths) == 2:
                profiles[name][section][paths[0]] = paths[1]
            elif section == "blocked_sheets":
                profiles[name][section].extend(paths)
            continue
        target = re.match(r"	target_sheet = '([^']+)'", line)
        if target:
            profiles[name]["target"] = target.group(1)
        pixel_map = re.match(r"\tpixel_map = '([^']+)'", line)
        if pixel_map:
            profiles[name]["pixel_map"] = pixel_map.group(1)
        squash = re.match(r"	max_squash = (\d+)", line)
        if squash:
            profiles[name]["max_squash"] = int(squash.group(1))
        if line.startswith("	bare_parts = "):
            profiles[name]["bare_parts"] = tuple(
                tuple(re.findall(r'"(\w+)"', group))
                for group in re.findall(r"list\(((?:\s*\"\w+\"\s*,?)+)\)", line))
    return {name: data for name, data in profiles.items() if data["target"]}


def _sheet_names(species_name, git_ref):
    directory = SPECIES_SHEETS / species_name
    if not git_ref:
        return sorted(str(path).replace("\\", "/") for path in directory.glob("*.dmi"))
    listing = subprocess.run(["git", "ls-tree", "--name-only", git_ref, f"{directory.as_posix()}/"],
                             capture_output=True, text=True)
    return sorted(name for name in listing.stdout.split() if name.endswith(".dmi"))


def historic_ref(species_name):
    """Species whose hand-drawn sheets were deleted still have them in git, and they are the best ground truth."""
    directory = SPECIES_SHEETS / species_name
    log = subprocess.run(["git", "log", "--format=%H", "--diff-filter=D", "-1", "--",
                          f"{directory.as_posix()}/"], capture_output=True, text=True)
    commit = log.stdout.split()
    return f"{commit[0]}^" if commit else None


def discover_pairs(species_name, git_ref=None):
    """Pair each hand-drawn sheet with the vanilla sheet it shares the most state names with.

    The names do not line up by themselves: a species helmet.dmi holds head.dmi states, shoes.dmi
    holds feet.dmi ones, and held.dmi is in-hand art the worn pipeline never draws.
    """
    names = _sheet_names(species_name, git_ref)
    if not names:
        return []
    vanilla = {}
    for path in sorted(VANILLA_SHEETS.glob("*.dmi")):
        vanilla[path] = {state for state in read_dmi(str(path).replace("\\", "/"))[0] if state}
    found = []
    for manual_path in names:
        if manual_path.rsplit("/", 1)[-1] in NOT_WORN:
            continue
        try:
            states = {state for state in read_dmi(manual_path, git_ref)[0] if state}
        except Exception:
            continue
        if not states:
            continue
        best, shared = None, 0
        for vanilla_path, vanilla_states in vanilla.items():
            overlap = len(states & vanilla_states)
            if overlap > shared:
                best, shared = vanilla_path, overlap
        if best and shared >= MIN_SHARED_STATES:
            found.append((str(best).replace("\\", "/"), manual_path, shared))
    return found


def _head_mask(sheet, dir_index, width, height):
    return body_mask(sheet, ("head_m",), dir_index, width, height)


def _visible_body(target_sheet, dir_index, width, height):
    body = body_mask(target_sheet, TRUNK_STATES + LIMB_STATES, dir_index, width, height)
    head = body_mask(target_sheet, ("head_m",), dir_index, width, height)
    return body - head


def _frame_pixels(image, width, height):
    pixels = image.load()
    out = {}
    for y in range(height):
        for x in range(width):
            pixel = pixels[x, y]
            out[(x, y)] = pixel if pixel[3] > 0 else None
    return out


def _unlike(candidate, manual):
    """Pixels that differ from the artist. Transparent pixels carry garbage RGB, so only alpha counts there."""
    return sum(1 for key in manual
               if (manual[key] is None) != (candidate[key] is None)
               or (manual[key] is not None and manual[key][:3] != candidate[key][:3]))


def _state_scores(target_path, pairs, git_ref=None, target_git_ref=None, trim="shrink", remap="auto",
                  max_squash=0, head_trim=True, head_warp=True, bare_parts=(), pixel_map=None):
    reference_sheet, width, height = read_dmi(REFERENCE)
    target_sheet, _, _ = read_dmi(target_path, target_git_ref)
    fitter = SpeciesFit(reference_sheet, target_sheet, width, height, trim, remap, max_squash, head_trim,
                        head_warp, bare_parts, pixel_map)
    visible = {index: _visible_body(target_sheet, index, width, height) for index in range(4)}
    reference_head = {index: _head_mask(reference_sheet, index, width, height) for index in range(4)}
    target_head = {index: _head_mask(target_sheet, index, width, height) for index in range(4)}
    full_body = {index: body_mask(target_sheet, TRUNK_STATES + LIMB_STATES + ("head_m",), index, width, height)
                 for index in range(4)}

    for vanilla_path, manual_path in pairs:
        vanilla_sheet, _, _ = read_dmi(vanilla_path)
        manual_sheet, _, _ = read_dmi(manual_path, git_ref)
        for state, (dirs, frames) in vanilla_sheet.items():
            if state not in manual_sheet:
                continue
            if frames[0].size != (width, height):
                continue
            dresses_head = fitter.dresses_head(vanilla_sheet, state)
            dressed_parts = tuple(fitter.dresses_part(vanilla_sheet, state, part)
                                  for part in range(len(bare_parts)))
            warps_head = fitter.warps_head(vanilla_sheet, state)
            stats = {key: 0 for key in ("frames", "generated_bare", "vanilla_bare", "manual_bare",
                                        "generated_erased", "manual_erased", "exact", "untouched_by_hand",
                                        "vanilla_off_body", "generated_off_body", "manual_off_body",
                                        "vanilla_head_cloth", "generated_head_cloth", "manual_head_cloth",
                                        "generated_unlike_hand", "vanilla_unlike_hand")}
            for dir_index in range(4):
                vanilla_frame = frame_for_dir(vanilla_sheet, state, dir_index)
                manual_frame = frame_for_dir(manual_sheet, state, dir_index)
                vanilla = _frame_pixels(vanilla_frame, width, height)
                manual = _frame_pixels(manual_frame, width, height)
                generated, _ = fitter.fit_frame(vanilla_frame, dir_index, dresses_head, dressed_parts, warps_head)
                skin = visible[dir_index]
                stats["frames"] += 1
                stats["vanilla_bare"] += sum(1 for key in skin if vanilla[key] is None)
                stats["manual_bare"] += sum(1 for key in skin if manual[key] is None)
                stats["generated_bare"] += sum(1 for key in skin if generated[key] is None)
                stats["generated_erased"] += sum(
                    1 for key in vanilla if vanilla[key] is not None and generated[key] is None)
                stats["manual_erased"] += sum(
                    1 for key in vanilla if vanilla[key] is not None and manual[key] is None)
                off = [key for key in vanilla if key not in full_body[dir_index]]
                stats["vanilla_off_body"] += sum(1 for key in off if vanilla[key] is not None)
                stats["manual_off_body"] += sum(1 for key in off if manual[key] is not None)
                stats["generated_off_body"] += sum(1 for key in off if generated[key] is not None)
                stats["vanilla_head_cloth"] += sum(
                    1 for key in reference_head[dir_index] if vanilla[key] is not None)
                stats["generated_head_cloth"] += sum(
                    1 for key in target_head[dir_index] if generated[key] is not None)
                stats["manual_head_cloth"] += sum(
                    1 for key in target_head[dir_index] if manual[key] is not None)
                stats["generated_unlike_hand"] += _unlike(generated, manual)
                stats["vanilla_unlike_hand"] += _unlike(vanilla, manual)
                if all(generated[key] == manual[key] for key in manual):
                    stats["exact"] += 1
                if all(vanilla[key] == manual[key] for key in manual):
                    stats["untouched_by_hand"] += 1
            yield vanilla_path, manual_path, state, stats


def replaceable(stats, tolerance=0):
    """The generator may take over a hand-drawn state only if it is no worse on every axis."""
    return (stats["generated_bare"] <= stats["manual_bare"] + tolerance
            and stats["generated_erased"] <= stats["manual_erased"] + tolerance
            and stats["generated_off_body"] <= stats["manual_off_body"] + tolerance
            and stats["generated_head_cloth"] <= stats["manual_head_cloth"] + tolerance)


def score(target_path, pairs, git_ref=None, target_git_ref=None, trim="shrink", remap="auto", max_squash=0,
          head_trim=True, head_warp=True, bare_parts=(), pixel_map=None):
    totals = {"frames": 0, "generated_bare": 0, "vanilla_bare": 0, "manual_bare": 0,
              "generated_erased": 0, "manual_erased": 0, "exact": 0, "untouched_by_hand": 0,
              "vanilla_off_body": 0, "generated_off_body": 0, "manual_off_body": 0,
              "vanilla_head_cloth": 0, "generated_head_cloth": 0, "manual_head_cloth": 0,
              "generated_unlike_hand": 0, "vanilla_unlike_hand": 0}
    for _, _, _, stats in _state_scores(target_path, pairs, git_ref, target_git_ref, trim, remap, max_squash,
                                        head_trim, head_warp, bare_parts, pixel_map):
        for key in totals:
            totals[key] += stats[key]
    return totals


def bench(holdout, worst):
    """Score every species that has hand-drawn sheets, so a change cannot be judged on one body."""
    profiles = read_profiles()
    groups = {"train": [], "holdout": []}
    print(f"{'species':10s} {'sheets':>7s} {'frames':>7s} {'vanilla':>10s} {'generated':>10s} {'closer by':>10s}")
    for name, profile in sorted(profiles.items()):
        git_ref = None
        found = discover_pairs(name)
        if not found:
            git_ref = historic_ref(name)
            found = discover_pairs(name, git_ref) if git_ref else []
        pairs = [(vanilla, manual) for vanilla, manual, _ in found]
        if not pairs:
            continue
        totals = score(profile["target"], pairs, git_ref, None, "shrink", "auto",
                       profile["max_squash"], True, True, profile["bare_parts"], profile["pixel_map"])
        was, now = totals["vanilla_unlike_hand"], totals["generated_unlike_hand"]
        gain = (was - now) / was * 100 if was else 0
        print(f"{name:10s} {len(pairs):7d} {totals['frames']:7d} {was:10d} {now:10d} {gain:9.1f}%")
        groups["holdout" if name in holdout else "train"].append((was, now))
        if worst:
            worst_states(name, profile, pairs, git_ref, worst)
    for group, rows in groups.items():
        if not rows:
            continue
        was = sum(row[0] for row in rows)
        now = sum(row[1] for row in rows)
        gain = (was - now) / was * 100 if was else 0
        print(f"{group.upper():10s} {'':7s} {'':7s} {was:10d} {now:10d} {gain:9.1f}%")


def worst_states(name, profile, pairs, git_ref, count):
    rows = []
    for _, manual_path, state, stats in _state_scores(
            profile["target"], pairs, git_ref, None, "shrink", "auto",
            profile["max_squash"], True, True, profile["bare_parts"], profile["pixel_map"]):
        if stats["untouched_by_hand"] == stats["frames"]:
            continue
        rows.append((stats["generated_unlike_hand"] - stats["vanilla_unlike_hand"],
                     stats["generated_unlike_hand"], manual_path.rsplit("/", 1)[-1], state))
    rows.sort(reverse=True)
    for lost, unlike, sheet_name, state in rows[:count]:
        print(f"    draw by hand: {sheet_name:16s} {state:28s} worse than vanilla by {lost:5d} px")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--target")
    parser.add_argument("--pixel-map")
    parser.add_argument("--pair", action="append", default=[],
                        help="vanilla.dmi:manual.dmi")
    parser.add_argument("--all", action="store_true",
                        help="score every species that has hand-drawn sheets")
    parser.add_argument("--holdout", default="",
                        help="comma-separated species to report apart, so tuning cannot quietly fit them")
    parser.add_argument("--worst", type=int, default=0,
                        help="per species, list this many states the fitter handles worst")
    parser.add_argument("--git-ref", help="read the manual sheets from this git ref")
    parser.add_argument("--target-git-ref", help="read the body sheet from this git ref")
    parser.add_argument("--trim", default="shrink", choices=("none", "rows", "body", "shrink"))
    parser.add_argument("--remap", default="auto", choices=("none", "auto"))
    parser.add_argument("--no-head-trim", dest="head_trim", action="store_false",
                        help="keep fitter-added cloth on a head the garment does not dress")
    parser.add_argument("--no-head-warp", dest="head_warp", action="store_false",
                        help="leave head garments on the human head position")
    parser.add_argument("--bare-part", action="append", default=[],
                        help="comma-separated body states the fitter may not smear cloth onto, "
                             "mirroring bare_parts in the species profile (repeat per part)")
    parser.add_argument("--max-squash", type=int, default=0,
                        help="rows a body part may lose before the remap leaves it alone")
    parser.add_argument("--per-state", action="store_true",
                        help="print a keep/drop verdict for every hand-drawn state")
    parser.add_argument("--tolerance", type=int, default=0,
                        help="pixels per state the generator may lose before a state is kept by hand")
    arguments = parser.parse_args()
    if arguments.all:
        bench(set(filter(None, arguments.holdout.split(","))), arguments.worst)
        return
    if not arguments.target or not arguments.pair:
        parser.error("--target and --pair are required without --all")
    pairs = [tuple(item.split(":", 1)) for item in arguments.pair]
    arguments.bare_parts = tuple(tuple(part.split(",")) for part in arguments.bare_part)
    if arguments.per_state:
        per_state(arguments, pairs)
        return
    totals = score(arguments.target, pairs, arguments.git_ref, arguments.target_git_ref,
                   arguments.trim, arguments.remap, arguments.max_squash, arguments.head_trim,
                   arguments.head_warp, arguments.bare_parts, arguments.pixel_map)

    print(f"frames compared            {totals['frames']}")
    print(f"already vanilla by hand    {totals['untouched_by_hand']}")
    print(f"exact match with hand work {totals['exact']}")
    print()
    print(f"{'visible bare skin':<26} vanilla {totals['vanilla_bare']:>7}"
          f" | generated {totals['generated_bare']:>7} | hand {totals['manual_bare']:>7}")
    print(f"{'erased clothing pixels':<26} vanilla {0:>7}"
          f" | generated {totals['generated_erased']:>7} | hand {totals['manual_erased']:>7}")
    print(f"{'cloth hanging off body':<26} vanilla {totals['vanilla_off_body']:>7}"
          f" | generated {totals['generated_off_body']:>7} | hand {totals['manual_off_body']:>7}")
    print(f"{'cloth over the head':<26} vanilla {totals['vanilla_head_cloth']:>7}"
          f" | generated {totals['generated_head_cloth']:>7} | hand {totals['manual_head_cloth']:>7}")
    print(f"{'pixels unlike the artist':<26} vanilla {totals['vanilla_unlike_hand']:>7}"
          f" | generated {totals['generated_unlike_hand']:>7} | hand {0:>7}")


def per_state(arguments, pairs):
    kept = {}
    for _, manual_path, state, stats in _state_scores(
            arguments.target, pairs, arguments.git_ref, arguments.target_git_ref,
            arguments.trim, arguments.remap, arguments.max_squash, arguments.head_trim,
            arguments.head_warp, arguments.bare_parts, arguments.pixel_map):
        sheet = kept.setdefault(manual_path, {"keep": [], "drop": 0})
        if replaceable(stats, arguments.tolerance):
            sheet["drop"] += 1
            continue
        sheet["keep"].append((state, stats))

    for manual_path, sheet in kept.items():
        total = sheet["drop"] + len(sheet["keep"])
        print(f"{manual_path}  {sheet['drop']}/{total} states can be generated")
        for state, stats in sorted(sheet["keep"], key=lambda item: item[0]):
            print(f"    keep {state:<34}"
                  f" bare {stats['generated_bare']:>5}/{stats['manual_bare']:<5}"
                  f" erased {stats['generated_erased']:>5}/{stats['manual_erased']:<5}"
                  f" off-body {stats['generated_off_body']:>5}/{stats['manual_off_body']:<5}")


if __name__ == "__main__":
    main()
