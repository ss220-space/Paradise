use meowtonin::{byond_fn, ByondError, ByondResult, ByondValue};
use std::collections::HashMap;

type Point = [f32; 2];
type Bounds = [f32; 4];

pub(super) fn numbers<const N: usize>(list: &ByondValue) -> ByondResult<[f32; N]> {
    let values = list.read_list()?;
    if values.len() != N {
        return Err(ByondError::boxed(std::io::Error::other(
            "invalid overmap geometry",
        )));
    }
    let mut result = [0.0; N];
    for (slot, value) in result.iter_mut().zip(values) {
        *slot = value.get_number()?;
    }
    Ok(result)
}

fn inside(p: Point, b: &Bounds) -> bool {
    p[0] >= b[0] && p[1] >= b[1] && p[0] <= b[2] && p[1] <= b[3]
}

fn intersects(a: Point, b: Point, rect: &Bounds) -> bool {
    let (mut enter, mut leave) = (0.0_f32, 1.0_f32);
    for axis in 0..2 {
        let delta = b[axis] - a[axis];
        if delta.abs() < 0.00001 {
            if a[axis] < rect[axis] || a[axis] > rect[axis + 2] {
                return false;
            }
        } else {
            let low = (rect[axis] - a[axis]) / delta;
            let high = (rect[axis + 2] - a[axis]) / delta;
            enter = enter.max(low.min(high));
            leave = leave.min(low.max(high));
            if enter > leave {
                return false;
            }
        }
    }
    true
}

fn corners([x1, y1, x2, y2]: Bounds) -> [Point; 4] {
    [
        [x1 - 1.0, y1 - 1.0],
        [x1 - 1.0, y2 + 1.0],
        [x2 + 1.0, y1 - 1.0],
        [x2 + 1.0, y2 + 1.0],
    ]
}

fn squared_distance(a: Point, b: Point) -> f32 {
    (a[0] - b[0]).powi(2) + (a[1] - b[1]).powi(2)
}

fn find_route(
    mut start: Point,
    finish: Point,
    boxes: &[Bounds],
    limits: Option<Bounds>,
) -> Option<Vec<Point>> {
    let in_limits = |p| limits.is_none_or(|bounds| inside(p, &bounds));
    if !in_limits(finish) || boxes.iter().any(|b| inside(finish, b)) {
        return None;
    }
    let clear = |a, b| !boxes.iter().any(|rect| intersects(a, b, rect));
    let mut path = Vec::new();
    if boxes.iter().any(|b| inside(start, b)) {
        let mut closest = f32::INFINITY;
        let mut exit = None;
        for rect in boxes.iter().filter(|b| inside(start, b)) {
            let [x1, y1, x2, y2] = *rect;
            let x = start[0].clamp(x1, x2);
            let y = start[1].clamp(y1, y2);
            let sides = [[x1 - 1.0, y], [x2 + 1.0, y], [x, y1 - 1.0], [x, y2 + 1.0]];
            for p in sides.into_iter().chain(corners(*rect)) {
                let distance = squared_distance(start, p);
                if distance < closest
                    && in_limits(p)
                    && clear(p, p)
                    && !boxes
                        .iter()
                        .any(|b| !inside(start, b) && intersects(start, p, b))
                {
                    closest = distance;
                    exit = Some(p);
                }
            }
        }
        start = exit?;
        path.push(start);
    }
    if clear(start, finish) {
        path.push(finish);
        return Some(path);
    }
    let mut nodes = vec![start, finish];
    for rect in boxes {
        nodes.extend(
            corners(*rect)
                .into_iter()
                .filter(|&p| in_limits(p) && clear(p, p)),
        );
        if nodes.len() > 512 {
            return None;
        }
    }
    let mut costs = vec![f32::INFINITY; nodes.len()];
    let mut scores = vec![f32::INFINITY; nodes.len()];
    let mut parents = vec![0; nodes.len()];
    let mut closed = vec![false; nodes.len()];
    let mut open = vec![0];
    costs[0] = 0.0;
    scores[0] = squared_distance(start, finish).sqrt();
    while !open.is_empty() {
        let best_slot =
            (0..open.len()).min_by(|&a, &b| scores[open[a]].total_cmp(&scores[open[b]]))?;
        let mut best = open.remove(best_slot);
        if best == 1 {
            let offset = path.len();
            while best != 0 {
                path.push(nodes[best]);
                best = parents[best];
            }
            path[offset..].reverse();
            return Some(path);
        }
        closed[best] = true;
        for next in 1..nodes.len() {
            if closed[next] {
                continue;
            }
            let cost = costs[best] + squared_distance(nodes[best], nodes[next]).sqrt();
            if cost >= costs[next] || !clear(nodes[best], nodes[next]) {
                continue;
            }
            if costs[next].is_infinite() {
                open.push(next);
            }
            costs[next] = cost;
            parents[next] = best;
            scores[next] = cost + squared_distance(nodes[next], finish).sqrt();
        }
    }
    None
}

#[byond_fn]
fn overmap_sector_path(
    start: ByondValue,
    finish: ByondValue,
    boxes: ByondValue,
    limits: ByondValue,
) -> ByondResult<ByondValue> {
    let boxes = boxes
        .read_list()?
        .iter()
        .map(numbers)
        .collect::<ByondResult<Vec<_>>>()?;
    let limits = (!limits.is_null()).then(|| numbers(&limits)).transpose()?;
    let Some(path) = find_route(numbers(&start)?, numbers(&finish)?, &boxes, limits) else {
        return Ok(ByondValue::NULL);
    };
    let mut points = Vec::with_capacity(path.len());
    for p in path {
        let mut point = ByondValue::new_list()?;
        point.write_list(p.map(ByondValue::new_num))?;
        points.push(point);
    }
    let mut result = ByondValue::new_list()?;
    result.write_list(points)?;
    Ok(result)
}

#[byond_fn]
fn overmap_portal_crossings(
    previous: ByondValue,
    current: ByondValue,
    portals: ByondValue,
) -> ByondResult<ByondValue> {
    let [x, y] = numbers(&previous)?;
    let [end_x, end_y] = numbers(&current)?;
    let mut hits = Vec::new();
    for (i, portal) in portals.read_list()?.chunks_exact(3).enumerate() {
        let threshold = portal[1].get_number()?;
        if threshold < y || threshold > end_y {
            continue;
        }
        let fraction = (threshold - y) / (end_y - y);
        if (x + (end_x - x) * fraction - portal[0].get_number()?).abs() <= portal[2].get_number()? {
            hits.extend([
                ByondValue::new_num((i + 1) as f32),
                ByondValue::new_num(fraction),
            ]);
        }
    }
    if hits.is_empty() {
        return Ok(ByondValue::NULL);
    }
    let mut result = ByondValue::new_list()?;
    result.write_list(hits)?;
    Ok(result)
}

struct TerrainScan<'a> {
    grid: &'a ByondValue,
    chunks: HashMap<(i32, i32), [u16; 16]>,
    bounds: [i32; 4],
    footprint: Bounds,
    frame: [f32; 6],
}

impl TerrainScan<'_> {
    fn point_clear(&mut self, point: Point) -> ByondResult<bool> {
        let x = (point[0] + self.frame[0]) - self.frame[2] + self.frame[4];
        let y = (point[1] + self.frame[1]) - self.frame[3] + self.frame[5];
        let x1 = self.bounds[0].max((x + self.footprint[0]).ceil() as i32);
        let x2 = self.bounds[2].min((x + self.footprint[2]).floor() as i32);
        let y1 = self.bounds[1].max((y + self.footprint[1]).ceil() as i32);
        let y2 = self.bounds[3].min((y + self.footprint[3]).floor() as i32);
        if x1 > x2 || y1 > y2 {
            return Ok(true);
        }
        for cx in x1 / 16..=x2 / 16 {
            let left = (x1 - cx * 16).max(0);
            let right = (x2 - cx * 16).min(15);
            let mask = (u16::MAX << left) & (u16::MAX >> (15 - right));
            for cy in y1 / 16..=y2 / 16 {
                let rows = match self.chunks.entry((cx, cy)) {
                    std::collections::hash_map::Entry::Occupied(entry) => entry.into_mut(),
                    std::collections::hash_map::Entry::Vacant(entry) => {
                        let chunk: ByondValue =
                            self.grid.call("terrain_rows", [cx as f32, cy as f32])?;
                        entry.insert(numbers::<16>(&chunk)?.map(|row| row as u16))
                    }
                };
                let bottom = (y1 - cy * 16).max(0) as usize;
                let top = (y2 - cy * 16).min(15) as usize;
                if rows[bottom..=top].iter().any(|row| row & mask != 0) {
                    return Ok(false);
                }
            }
        }
        Ok(true)
    }

    fn segment_clear(&mut self, from: Point, to: Point) -> ByondResult<bool> {
        let steps = (squared_distance(from, to).sqrt() * 2.0).ceil().max(1.0) as i32;
        for i in 0..=steps {
            let p = [
                from[0] + (to[0] - from[0]) * i as f32 / steps as f32,
                from[1] + (to[1] - from[1]) * i as f32 / steps as f32,
            ];
            if !self.point_clear(p)? {
                return Ok(false);
            }
        }
        Ok(true)
    }
}

#[byond_fn]
fn overmap_grid_segments(
    grid: ByondValue,
    start: ByondValue,
    ends: ByondValue,
    bounds: ByondValue,
    footprint: ByondValue,
    frame: ByondValue,
) -> ByondResult<ByondValue> {
    let mut scan = TerrainScan {
        grid: &grid,
        chunks: HashMap::new(),
        bounds: numbers(&bounds)?.map(|n| n as i32),
        footprint: numbers(&footprint)?,
        frame: numbers(&frame)?,
    };
    let from = numbers(&start)?;
    let mut mask = 0_u32;
    for (i, end) in ends.read_list()?.iter().enumerate().take(8) {
        if !end.is_null() && scan.segment_clear(from, numbers(end)?)? {
            mask |= 1 << i;
        }
    }
    Ok(ByondValue::new_num(mask as f32))
}
