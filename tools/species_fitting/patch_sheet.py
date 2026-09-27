"""Strip a hand-drawn species sheet down to the states the generator cannot match.

    python tools/species_fitting/patch_sheet.py --target icons/mob/human_races/r_swine.dmi \
        --trim shrink --tolerance 15 --out-dir icons/mob/clothing/species/swine/manual \
        --pair icons/mob/clothing/uniform.dmi:icons/mob/clothing/species/swine/uniform.dmi

Every state the generator matches on bare skin, erased cloth and cloth hanging off
the body is dropped; what is left is written as a small patch sheet for
/datum/species_fit/manual_sheets. A sheet with nothing left is reported as
deletable and no file is written. Run from the repository root.
"""
import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
sys.path.insert(0, str(Path(__file__).parent.parent))

from dmi_splice import get_state, load_cells, write_dmi
from measure import _state_scores, replaceable


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--target", required=True)
    parser.add_argument("--pair", action="append", required=True, help="vanilla.dmi:manual.dmi")
    parser.add_argument("--out-dir", required=True)
    parser.add_argument("--git-ref", help="read the manual sheets from this git ref")
    parser.add_argument("--target-git-ref", help="read the body sheet from this git ref")
    parser.add_argument("--trim", default="shrink", choices=("none", "rows", "body", "shrink"))
    parser.add_argument("--tolerance", type=int, default=0)
    arguments = parser.parse_args()

    pairs = [tuple(item.split(":", 1)) for item in arguments.pair]
    kept = {manual: [] for _, manual in pairs}
    for _, manual_path, state, stats in _state_scores(
            arguments.target, pairs, arguments.git_ref, arguments.target_git_ref, arguments.trim):
        if not replaceable(stats, arguments.tolerance):
            kept[manual_path].append(state)

    out_dir = Path(arguments.out_dir)
    for manual_path, states in kept.items():
        if not states:
            print(f"delete {manual_path}")
            continue
        width, height, state_list = load_cells(manual_path)
        blocks = []
        for state in states:
            found = get_state(state_list, state)
            if found is None:
                raise ValueError(f"{manual_path} has no state {state}")
            blocks.append(found)
        out_dir.mkdir(parents=True, exist_ok=True)
        out_path = out_dir / Path(manual_path).name
        write_dmi(str(out_path), width, height, blocks)
        print(f"patch  {out_path}  {len(blocks)} states kept out of {manual_path}")


if __name__ == "__main__":
    main()
