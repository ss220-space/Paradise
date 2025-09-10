import os
import sys
from pathlib import Path
from . import dmm

def find_dmm_files(root_dir):
    return [str(p) for p in Path(root_dir).rglob('*.dmm')]

def should_ignore_combination(found_objects, ignore_combinations):
    found_set = set(found_objects)
    return any(set(combo).issubset(found_set) for combo in ignore_combinations)

def extract_objects_from_tile(tile_contents, to_check):
    found_objects = []

    if hasattr(tile_contents, 'objects') and tile_contents.objects:
        for obj in to_check:
            if obj in tile_contents.objects:
                found_objects.append(obj)
    elif hasattr(tile_contents, '__iter__') and not isinstance(tile_contents, str):
        for item in tile_contents:
            if hasattr(item, 'path') and item.path in to_check:
                found_objects.append(item.path)
            elif str(item) in to_check:
                found_objects.append(str(item))
    elif hasattr(tile_contents, 'path') and tile_contents.path in to_check:
        found_objects.append(tile_contents.path)
    tile_str = str(tile_contents)
    for obj in to_check:
        if obj in tile_str and obj not in found_objects:
            found_objects.append(obj)

    return found_objects

def main(root_dir):
    dmm_files = find_dmm_files(root_dir)
    if not dmm_files:
        print(f"No .dmm files found in: {root_dir}")
        return 0

    print(f"Found {len(dmm_files)} .dmm files:")

    to_check = [
        "/obj/structure/lattice",
        "/obj/structure/lattice/catwalk",
        "/obj/structure/lattice/catwalk/mapping",
        "/obj/structure/girder"
    ]

    ignore_combinations = [
        ["/obj/structure/lattice", "/obj/structure/lattice/catwalk"],
        ["/obj/structure/lattice", "/obj/structure/lattice/catwalk/mapping"],
        ["/obj/structure/lattice", "/obj/structure/girder"]
    ]

    bad_maps = {}
    processed = 0

    for full_path in dmm_files:
        rel_path = os.path.relpath(full_path, root_dir)

        try:
            if not os.path.exists(full_path):
                print(f"  File does not exist: {full_path}")
                continue

            index_map = dmm.DMM.from_file(full_path)
            keys_with_multiple_objects = []

            for key, tile_contents in index_map.dictionary.items():
                found_objects = extract_objects_from_tile(tile_contents, to_check)

                if len(found_objects) >= 2:
                    if not should_ignore_combination(found_objects, ignore_combinations):
                        keys_with_multiple_objects.append({
                            'key': dmm.num_to_key(key, index_map.key_length),
                            'count': len(found_objects),
                            'objects': found_objects,
                        })

            if keys_with_multiple_objects:
                bad_maps[full_path] = keys_with_multiple_objects

            processed += 1

        except Exception as e:
            print(f"  Error processing {rel_path}: {e}")

    print(f"Processed {processed}/{len(dmm_files)} files")

    for map_path, keys_list in bad_maps.items():
        print(f"\n{map_path}:")
        for result in keys_list:
            print(f"  Key {result['key']}: {result['count']} objects - {result['objects']}")

if __name__ == '__main__':
    try:
        root_dir = Path.cwd().parent.parent.resolve()
        if not os.path.exists(root_dir):
            print(f"Error: Root directory does not exist: {root_dir}")
            sys.exit(1)
        main(root_dir)
        sys.exit(0)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)
