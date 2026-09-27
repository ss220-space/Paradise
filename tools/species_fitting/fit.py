"""Python mirror of /datum/species_fit, used to measure fit quality before writing DM.

Pipeline order and every heuristic here must stay identical to
code/modules/mob/living/carbon/human/species/fitting/, otherwise the numbers lie.
"""
from dmi import LIMB_STATES, TRUNK_STATES, body_mask, frame_for_dir

TIER_STATES = (("head_m",), ("l_foot", "r_foot"), ("l_hand", "r_hand"), TRUNK_STATES,
               ("l_leg", "r_leg"), ("l_arm", "r_arm"))

FULL_STATES = TRUNK_STATES + LIMB_STATES + ("head_m",)

TRANSPARENT = None

PART_GARMENT_SHARE = 0.25

HEAD_WARP_SHARE = 0.25


def _nearest_line(lines, line):
    best, best_distance = line, 1 << 30
    for candidate in lines:
        distance = abs(candidate - line)
        if distance < best_distance:
            best, best_distance = candidate, distance
    return best


def _row_runs(pixels, y, width):
    runs, start = [], None
    for x in range(width):
        if pixels[(x, y)] is not None:
            if start is None:
                start = x
        elif start is not None:
            runs.append((start, x - 1))
            start = None
    if start is not None:
        runs.append((start, width - 1))
    return runs


def _stretch_segments(counts, extra):
    if extra <= 0:
        return
    first = 1 if len(counts) > 2 else 0
    last = len(counts) - 2 if len(counts) > 2 else len(counts) - 1
    weight = sum(counts[first:last + 1])
    if not weight:
        counts[max(len(counts) // 2, 0)] += extra
        return
    given, remainders = 0, [0] * len(counts)
    for segment in range(first, last + 1):
        share = int(extra * counts[segment] / weight)
        remainders[segment] = (extra * counts[segment]) % weight
        counts[segment] += share
        given += share
    while given < extra:
        best = max(range(first, last + 1), key=lambda index: remainders[index])
        counts[best] += 1
        remainders[best] = -1
        given += 1
    while given > extra:
        best = max(range(first, last + 1), key=lambda index: counts[index])
        counts[best] -= 1
        given -= 1


def _rebuild_run(source, y, from_column, to_column, target_width):
    colors, counts = [], []
    for x in range(from_column, to_column + 1):
        pixel = source[(x, y)]
        if colors and colors[-1] == pixel:
            counts[-1] += 1
            continue
        colors.append(pixel)
        counts.append(1)
    _stretch_segments(counts, target_width - (to_column - from_column + 1))
    rebuilt = []
    for color, count in zip(colors, counts):
        rebuilt.extend([color] * count)
    return rebuilt[:target_width]


def _flip_keys(keys, height):
    return {(x, height - 1 - y) for (x, y) in keys}


DIRECTION_NAMES = ("South", "North", "East", "West")


def _read_pixel_map(path, width, height):
    """AdaptiveDMITool export: the output pixel is `source`, read from input pixel `target`."""
    if not path:
        return {index: {} for index in range(4)}
    import json
    from pathlib import Path
    data = json.loads(Path(path).read_text(encoding="utf-8-sig"))
    if data.get("version") != 1 or data.get("supportedDirections") not in ("four", "eight"):
        raise ValueError("unsupported pixel map format")
    resolution = data.get("resolution") or {}
    if resolution.get("width") != width or resolution.get("height") != height:
        raise ValueError("pixel map is %sx%s, body is %sx%s"
                         % (resolution.get("width"), resolution.get("height"), width, height))
    mappings = data.get("mappings") or {}
    maps = {}
    for index, name in enumerate(DIRECTION_NAMES):
        built = {}
        for pair in mappings.get(name) or ():
            out = pair["source"]
            if (type(out["x"]) is not int or type(out["y"]) is not int
                    or not (0 <= out["x"] < width and 0 <= out["y"] < height)):
                raise ValueError("invalid output coordinate")
            key = (out["x"], height - 1 - out["y"])
            into = pair["target"]
            if into is None:
                built[key] = None
                continue
            if (type(into["x"]) is not int or type(into["y"]) is not int
                    or not (0 <= into["x"] < width and 0 <= into["y"] < height)):
                raise ValueError("invalid input coordinate")
            built[key] = (into["x"], height - 1 - into["y"])
        maps[index] = built
    return maps


def _refit_rows(source, adapted, width, height, rows):
    from collections import Counter
    counts = Counter(pixel for grid in (source, adapted) for pixel in grid.values() if pixel)
    edge = set()
    for grid in (source, adapted):
        for (x, y), pixel in grid.items():
            if pixel and any(grid.get((x + dx, y + dy)) is None
                             for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                edge.add(pixel)
    light = {pixel: 299 * pixel[0] + 587 * pixel[1] + 114 * pixel[2] for pixel in counts}
    result = dict(adapted)
    for y in rows:
        original = [source[x, y] for x in range(width)]
        current = [adapted[x, y] for x in range(width)]
        original_span = [x for x, pixel in enumerate(original) if pixel]
        current_span = [x for x, pixel in enumerate(current) if pixel]
        if not original_span or not current_span or original == current:
            continue
        original = original[original_span[0]:original_span[-1] + 1]
        current = current[current_span[0]:current_span[-1] + 1]
        extra = len(current) - len(original)
        if extra < 0 or extra > 8:
            continue
        rebuilt = list(original)
        if extra:
            candidates = []
            for gap in range(1, len(original)):
                left, right = original[gap - 1], original[gap]
                if left is None or right is None:
                    continue
                if left == right:
                    color, cost = left, 0
                else:
                    high, low = (left, right) if light[left] >= light[right] else (right, left)
                    color, cost = high if counts[high] >= 4 else low, 4
                cost += 8 if color in edge else 0
                cost += 3 if counts[color] < 8 else 0
                candidates.append((gap, color, cost))
            if not candidates:
                continue
            insertions = {}
            for number in range(extra):
                ideal = (number + 1) * len(original) / (extra + 1)
                gap, color, _ = min(candidates, key=lambda item:
                    (item[2] + 0.6 * abs(item[0] - ideal), abs(item[0] - ideal)))
                insertions.setdefault(gap, []).append(color)
            rebuilt = []
            for index, pixel in enumerate(original):
                rebuilt.extend(insertions.get(index, ()))
                rebuilt.append(pixel)
        for index, pixel in enumerate(rebuilt):
            if pixel is not None or current[index] is None:
                continue
            neighbours = [rebuilt[other] for other in (index - 1, index + 1)
                          if 0 <= other < len(rebuilt) and rebuilt[other] is not None]
            rebuilt[index] = max(neighbours, key=light.get) if neighbours else current[index]
        for index, pixel in enumerate(rebuilt):
            result[current_span[0] + index, y] = pixel
    return result


def _span_endpoints(mask, line, size, along_rows):
    hits = [index for index in range(size)
            if ((line, index) if along_rows else (index, line)) in mask]
    return (hits[0], hits[-1]) if hits else None


class SpeciesFit:
    def __init__(self, reference_sheet, target_sheet, width=32, height=32, trim="shrink", remap="auto",
                 max_squash=0, head_trim=True, head_warp=True, bare_parts=(), pixel_map=None):
        self.width, self.height = width, height
        self.trim = trim
        self.remap = remap
        self.max_squash = max_squash
        self.head_trim = head_trim
        self.head_warp = head_warp
        self.bare_parts = tuple(bare_parts)
        self.pixel_maps = _read_pixel_map(pixel_map, width, height)
        self.floating_rows = {}
        self.target_full = {}
        self.reference_full = {}
        self.shrunk = {}
        self.reference_trunk, self.reference_body = {}, {}
        self.target_trunk, self.target_body = {}, {}
        self.warp_maps, self.row_maps = {}, {}
        self.reference_head, self.target_head = {}, {}
        self.reference_tiers, self.target_tiers = {}, {}
        self.span_maps, self.pixel_tiers = {}, {}
        self.head_shifts = {}
        self.reference_bare, self.target_bare = {}, {}
        for dir_index in range(4):
            self.reference_trunk[dir_index] = _flip_keys(
                body_mask(reference_sheet, TRUNK_STATES, dir_index, width, height), height)
            self.reference_body[dir_index] = _flip_keys(body_mask(
                reference_sheet, TRUNK_STATES + LIMB_STATES, dir_index, width, height), height)
            self.target_trunk[dir_index] = _flip_keys(
                body_mask(target_sheet, TRUNK_STATES, dir_index, width, height), height)
            self.target_body[dir_index] = _flip_keys(body_mask(
                target_sheet, TRUNK_STATES + LIMB_STATES, dir_index, width, height), height)
            self.reference_head[dir_index] = _flip_keys(
                body_mask(reference_sheet, ("head_m",), dir_index, width, height), height)
            self.target_head[dir_index] = _flip_keys(
                body_mask(target_sheet, ("head_m",), dir_index, width, height), height)
            self.reference_tiers[dir_index] = [
                _flip_keys(body_mask(reference_sheet, states, dir_index, width, height), height)
                for states in TIER_STATES]
            self.target_tiers[dir_index] = [
                _flip_keys(body_mask(target_sheet, states, dir_index, width, height), height)
                for states in TIER_STATES]
            self.reference_bare[dir_index] = [
                _flip_keys(body_mask(reference_sheet, states, dir_index, width, height), height)
                for states in self.bare_parts]
            self.target_bare[dir_index] = [
                _flip_keys(body_mask(target_sheet, states, dir_index, width, height), height)
                for states in self.bare_parts]
            self.head_shifts[dir_index] = self._build_head_shifts(dir_index)
            self.warp_maps[dir_index] = self._build_warp_map(dir_index)
            self.row_maps[dir_index] = self._build_row_map(dir_index)
            self.target_full[dir_index] = _flip_keys(
                body_mask(target_sheet, FULL_STATES, dir_index, width, height), height)
            self.reference_full[dir_index] = _flip_keys(
                body_mask(reference_sheet, FULL_STATES, dir_index, width, height), height)
            reference_rows = {y for _, y in self.reference_full[dir_index]}
            target_rows = {y for _, y in self.target_full[dir_index]}
            self.floating_rows[dir_index] = reference_rows - target_rows
            self.shrunk[dir_index] = self.reference_full[dir_index] - self.target_full[dir_index]
        for dir_index in range(4):
            self.span_maps[dir_index] = self._build_span_map(dir_index)

    def _build_head_shifts(self, dir_index):
        reference_head, target_head = self.reference_head[dir_index], self.target_head[dir_index]
        if not reference_head or not target_head:
            return {}
        reference_columns = sorted(x for x, _ in reference_head)
        target_columns = sorted(x for x, _ in target_head)
        shift = (target_columns[len(target_columns) // 2]
                 - reference_columns[len(reference_columns) // 2])
        if not shift:
            return {}
        first_row = max(min(y for _, y in reference_head), min(y for _, y in target_head))
        return {y: shift for y in range(first_row, self.height)}

    def _head_warp(self, working, dir_index):
        shifted = dict(working)
        for y, shift in self.head_shifts[dir_index].items():
            for x in range(self.width):
                column = x - shift
                shifted[(x, y)] = working[(column, y)] if 0 <= column < self.width else None
        return shifted

    def _build_warp_map(self, dir_index):
        reference_trunk, reference_body = self.reference_trunk[dir_index], self.reference_body[dir_index]
        target_trunk, target_body = self.target_trunk[dir_index], self.target_body[dir_index]
        warp_map = {}
        for y in range(self.height):
            trunk_columns = [x for x in range(self.width) if (x, y) in reference_trunk]
            body_columns = [x for x in range(self.width) if (x, y) in reference_body]
            for x in range(self.width):
                if (x, y) in target_trunk and trunk_columns:
                    warp_map[(x, y)] = _nearest_line(trunk_columns, x)
                elif (x, y) in target_body and body_columns:
                    warp_map[(x, y)] = _nearest_line(body_columns, x)
                else:
                    warp_map[(x, y)] = x
        return warp_map

    def _build_span_map(self, dir_index):
        span_map, claimed = {}, {}
        self.pixel_tiers[dir_index] = claimed
        for x in range(self.width):
            for tier, (reference_mask, target_mask) in enumerate(
                    zip(self.reference_tiers[dir_index], self.target_tiers[dir_index])):
                target = _span_endpoints(target_mask, x, self.height, True)
                if not target:
                    continue
                reference = _span_endpoints(reference_mask, x, self.height, True)
                first_reference, last_reference = reference if reference else (0, 0)
                first_target, last_target = target
                grown = first_target <= first_reference and last_target >= last_reference
                squashed = (last_reference - first_reference) - (last_target - first_target)
                for y in range(first_target, last_target + 1):
                    if (x, y) in claimed or (x, y) not in target_mask:
                        continue
                    claimed[(x, y)] = tier
                    if not reference or grown or squashed > self.max_squash:
                        continue
                    if last_target == first_target:
                        span_map[(x, y)] = first_reference
                        continue
                    span_map[(x, y)] = first_reference + int(
                        (y - first_target) * (last_reference - first_reference)
                        / (last_target - first_target) + 0.5)
        return span_map

    def _span_remap(self, working, dir_index):
        remapped = dict(working)
        for (x, y), source_row in self.span_maps[dir_index].items():
            remapped[(x, y)] = working[(x, source_row)]
        return remapped

    def _build_row_map(self, dir_index):
        reference_trunk, reference_body = self.reference_trunk[dir_index], self.reference_body[dir_index]
        target_trunk, target_body = self.target_trunk[dir_index], self.target_body[dir_index]
        trunk_rows = sorted({y for _, y in reference_trunk})
        body_rows = sorted({y for _, y in reference_body})
        row_map = {}
        for x in range(self.width):
            for y in range(self.height):
                if (x, y) in target_trunk:
                    rows = trunk_rows
                elif (x, y) in target_body:
                    rows = body_rows
                else:
                    rows = None
                if not rows or rows[0] <= y <= rows[-1]:
                    continue
                row_map[(x, y)] = _nearest_line(rows, y)
        return row_map

    def _covered_share(self, sheet, state, masks):
        best = 0.0
        for dir_index in range(4):
            mask = masks[dir_index]
            if not mask:
                return 1.0
            pixels = frame_for_dir(sheet, state, dir_index).load()
            covered = sum(1 for (x, y) in mask if pixels[x, self.height - 1 - y][3] > 0)
            best = max(best, covered / len(mask))
        return best

    def dresses_head(self, sheet, state):
        return self._covered_share(sheet, state, self.reference_head) >= PART_GARMENT_SHARE

    def warps_head(self, sheet, state):
        return self._covered_share(sheet, state, self.reference_head) >= HEAD_WARP_SHARE

    def dresses_part(self, sheet, state, part):
        masks = {dir_index: self.reference_bare[dir_index][part] for dir_index in range(4)}
        return self._covered_share(sheet, state, masks) >= PART_GARMENT_SHARE

    def fit_frame(self, image, dir_index, dresses_head, dressed_parts, warps_head):
        pixels = image.load()
        source = {}
        for y in range(self.height):
            for x in range(self.width):
                pixel = pixels[x, self.height - 1 - y]
                source[(x, y)] = pixel if pixel[3] > 0 else None
        dirty = self._mark_bare_skin(source, dir_index)
        working = self._warp(dict(source), dirty, dir_index)
        working = self._edge_repair(working, source, dirty, dir_index)
        if self.remap == "auto":
            working = self._span_remap(working, dir_index)
        working = self._vertical_warp(working, dir_index)
        working = self._cover_skin(working, dir_index)
        floating = self.floating_rows[dir_index] if self.trim == "rows" else frozenset()
        remapped = self.span_maps[dir_index] if self.remap == "auto" else {}
        tiers = self.pixel_tiers.get(dir_index, {})
        for key, pixel in source.items():
            if key in remapped and not self._holed(working, tiers, key):
                continue
            if working[key] is None and pixel is not None and key[1] not in floating:
                working[key] = pixel
        for y in floating:
            for x in range(self.width):
                working[(x, y)] = None
        if self.head_warp and warps_head:
            working = self._head_warp(working, dir_index)
        if self.trim == "body":
            for key in working:
                if key not in self.target_full[dir_index]:
                    working[key] = None
        elif self.trim == "shrink":
            for key in self.shrunk[dir_index]:
                if source[key] is None:
                    working[key] = None
        if self.head_trim and not dresses_head:
            for key in self.target_head[dir_index]:
                if source[key] is None:
                    working[key] = None
        for part, mask in enumerate(self.target_bare[dir_index]):
            if part < len(dressed_parts) and dressed_parts[part]:
                continue
            for key in mask:
                if source[key] is None:
                    working[key] = None
        mapping = self.pixel_maps[dir_index]
        if mapping:
            mapped = dict(source)
            for key, origin in mapping.items():
                mapped[key] = source[origin] if origin is not None else None
            rows = {y for (x, y), origin in mapping.items() if origin is not None and origin[1] == y}
            rows -= {y for (x, y), origin in mapping.items() if origin is not None and origin[1] != y}
            corrected = _refit_rows(source, mapped, self.width, self.height, rows) if rows else mapped
            for key in working:
                if key in mapping or corrected[key] != mapped[key]:
                    working[key] = None if key in mapping and mapping[key] is None else corrected[key]
        return {(x, self.height - 1 - y): pixel for (x, y), pixel in working.items()}, working != source

    def _mark_bare_skin(self, working, dir_index):
        reference_body, target_body = self.reference_body[dir_index], self.target_body[dir_index]
        dirty = [False] * self.height
        for y in range(self.height):
            for x in range(self.width):
                if (x, y) in target_body and (x, y) not in reference_body and working[(x, y)] is None:
                    dirty[y] = True
                    break
        return dirty

    def _warp(self, working, dirty, dir_index):
        warp_map = self.warp_maps[dir_index]
        warped = dict(working)
        for y in range(self.height):
            if not dirty[y]:
                continue
            for x in range(self.width):
                warped[(x, y)] = working[(warp_map[(x, y)], y)]
        return warped

    def _edge_repair(self, working, source, dirty, dir_index):
        warp_map = self.warp_maps[dir_index]
        for y in range(self.height):
            if not dirty[y]:
                continue
            for start, end in _row_runs(working, y, self.width):
                from_column, to_column = warp_map[(start, y)], warp_map[(end, y)]
                while from_column > 0 and source[(from_column - 1, y)] is not None:
                    from_column -= 1
                while to_column < self.width - 1 and source[(to_column + 1, y)] is not None:
                    to_column += 1
                if to_column < from_column:
                    continue
                new_width = end - start + 1
                if new_width <= to_column - from_column + 1:
                    continue
                rebuilt = _rebuild_run(source, y, from_column, to_column, new_width)
                for offset, pixel in enumerate(rebuilt):
                    if pixel is not None:
                        working[(start + offset, y)] = pixel
        return working

    def _vertical_warp(self, working, dir_index):
        stretched = dict(working)
        for (x, y), source_row in self.row_maps[dir_index].items():
            if working[(x, y)] is None:
                stretched[(x, y)] = working[(x, source_row)]
        return stretched

    def _holed(self, working, tiers, key):
        x, y = key
        tier = tiers.get(key)
        for neighbour in ((x, y - 1), (x, y + 1)):
            if neighbour not in working or working[neighbour] is None:
                continue
            if tiers.get(neighbour) == tier:
                return True
        return False

    def _cover_skin(self, working, dir_index):
        reference_body, target_body = self.reference_body[dir_index], self.target_body[dir_index]
        for y in range(self.height):
            for x in range(self.width):
                if working[(x, y)] is not None or (x, y) not in target_body or (x, y) in reference_body:
                    continue
                if x > 0 and working[(x - 1, y)] is not None:
                    working[(x, y)] = working[(x - 1, y)]
                elif x < self.width - 1 and working[(x + 1, y)] is not None:
                    working[(x, y)] = working[(x + 1, y)]
        return working
