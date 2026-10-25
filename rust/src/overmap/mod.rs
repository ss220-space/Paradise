use meowtonin::{byond_fn, ByondError, ByondResult, ByondValue};
use rand::{rngs::SmallRng, RngExt, SeedableRng};
use std::collections::BTreeMap;

struct Field {
    x: i32,
    y: i32,
    span: i32,
    density: usize,
    carp: bool,
    peers: Vec<(i32, i32, bool)>,
}

#[derive(Default)]
struct Chunk {
    indices: Vec<ByondValue>,
    rows: [u16; 16],
}

fn row_runs(rows: &[u16; 16]) -> Vec<ByondValue> {
    let mut out = Vec::new();
    for (y, row) in rows.iter().enumerate() {
        let mut x = 0;
        while x < 16 {
            if row & (1 << x) == 0 {
                x += 1;
                continue;
            }
            let start = x;
            while x < 16 && row & (1 << x) != 0 { x += 1; }
            out.extend([
                ByondValue::new_num(start as f32),
                ByondValue::new_num(y as f32),
                ByondValue::new_num((x - start) as f32),
            ]);
        }
    }
    out
}

impl Field {
    fn accepts(&self, dx: i32, dy: i32, minimum: f32) -> bool {
        let own = dx * dx + dy * dy;
        let scale = 0.8 * (self.span * self.span) as f32;
        let mut strength = 0.0_f32;
        for &(px, py, earlier) in &self.peers {
            let distance = (dx - px).pow(2) + (dy - py).pow(2);
            if distance < own || (distance == own && earlier) {
                return false;
            }
            strength += (1.0 - distance as f32 / scale).max(0.0);
        }
        let cx = (self.x * self.span + dx) as f32 / self.span as f32;
        let cy = (self.y * self.span + dy) as f32 / self.span as f32;
        let noise = ((cx * 361.0 + cy * 173.0) as f64).to_radians().sin() as f32 * 0.08
            + ((cx * 719.0 - cy * 431.0) as f64).to_radians().sin() as f32 * 0.05;
        strength - 0.42 + noise > minimum + 0.002
    }

    fn generate(&self, seed: u64) -> Vec<[i32; 2]> {
        let mut rng = SmallRng::seed_from_u64(seed);
        let density = self.density;
        let mut budget = if self.carp {
            density * 24
        } else {
            ((self.span * self.span) as f64
                * (0.9 * (density * density) as f64 / 64.0))
                .round() as usize
        };
        let islands = if self.carp {
            density * 4
        } else {
            (density * 8).max(budget.div_ceil(90 * density * density) * 3)
        };
        let edge = (self.span as f64 * 0.9).ceil() as i32;
        let side = (edge * 2 + 1) as usize;
        let index = |x: i32, y: i32| (y + edge) as usize * side + (x + edge) as usize;
        let in_bounds = |x: i32, y: i32| x.abs() < edge && y.abs() < edge;
        let mut occupied = vec![false; side * side];
        let mut queued = vec![0; side * side];
        let mut points = Vec::with_capacity(budget);
        let mut centers: Vec<[i32; 2]> = Vec::new();
        let extent = (self.span as f64 * 0.8).round() as i32;
        let mut frontier = Vec::new();
        for island in 1..=islands {
            if budget < 2 {
                break;
            }
            let center = (0..24).find_map(|_| {
                let x = rng.random_range(-extent..=extent);
                let y = rng.random_range(-extent..=extent);
                if self.carp
                    && centers.iter().any(|c| (c[0] - x).abs() < 10 && (c[1] - y).abs() < 10)
                {
                    return None;
                }
                (!occupied[index(x, y)] && self.accepts(x, y, 0.15)).then_some([x, y])
            });
            let Some([cx, cy]) = center else {
                continue;
            };
            if self.carp {
                centers.push([cx, cy]);
            }
            frontier.clear();
            frontier.push([cx, cy]);
            queued[index(cx, cy)] = island;
            let mut remaining = if self.carp {
                rng.random_range(3..=6)
            } else {
                budget.min(rng.random_range(90..=150) * density * density)
            };
            let start = points.len();
            while !frontier.is_empty() && remaining > 0 {
                let chosen = rng.random_range(0..frontier.len());
                let [dx, dy] = frontier.swap_remove(chosen);
                let slot = index(dx, dy);
                if occupied[slot] {
                    continue;
                }
                occupied[slot] = true;
                if !self.accepts(dx, dy, 0.0) {
                    continue;
                }
                points.push([self.x * self.span + dx, self.y * self.span + dy]);
                remaining -= 1;
                budget -= 1;
                for [nx, ny] in [[dx + 1, dy], [dx - 1, dy], [dx, dy + 1], [dx, dy - 1]] {
                    if !in_bounds(nx, ny) {
                        continue;
                    }
                    let next = index(nx, ny);
                    if occupied[next] || queued[next] == island {
                        continue;
                    }
                    queued[next] = island;
                    frontier.push([nx, ny]);
                }
            }
            if points.len() == start + 1 {
                points.pop();
                budget += 1;
            }
        }
        points
    }
}

#[byond_fn]
fn overmap_scatter(
    x: ByondValue,
    y: ByondValue,
    span: ByondValue,
    density: ByondValue,
    carp: ByondValue,
    peers: ByondValue,
    seed: ByondValue,
) -> ByondResult<ByondValue> {
    let span = span.get_number()? as i32;
    if !(1..=1024).contains(&span) {
        return Err(ByondError::boxed(std::io::Error::other("overmap_scatter: invalid cell span")));
    }
    let mut neighbors = Vec::new();
    for peer in peers.read_list()? {
        let values = peer.read_list()?;
        if values.len() != 3 {
            return Err(ByondError::boxed(std::io::Error::other("overmap_scatter: invalid neighbor")));
        }
        neighbors.push((
            values[0].get_number()? as i32,
            values[1].get_number()? as i32,
            values[2].get_number()? != 0.0,
        ));
    }
    let field = Field {
        x: x.get_number()? as i32,
        y: y.get_number()? as i32,
        span,
        density: (density.get_number()? as usize).clamp(1, 8),
        carp: carp.get_number()? != 0.0,
        peers: neighbors,
    };
    let points = field.generate(seed.get_number()? as u64);
    let mut chunks: BTreeMap<(i32, i32), Chunk> = BTreeMap::new();
    let mut flat = Vec::with_capacity(points.len() * 3);
    for [px, py] in points {
        let chunk = chunks.entry((px.div_euclid(16), py.div_euclid(16))).or_default();
        chunk.indices.push(ByondValue::new_num((flat.len() + 1) as f32));
        chunk.rows[py.rem_euclid(16) as usize] |= 1 << px.rem_euclid(16);
        flat.extend([
            ByondValue::new_num(px as f32),
            ByondValue::new_num(py as f32),
            ByondValue::new_num(if field.carp { 40.0_f32 } else { 100.0_f32 }),
        ]);
    }
    let mut positions = ByondValue::new_list()?;
    positions.write_list(flat)?;
    let mut lookup = ByondValue::new_list()?;
    let mut radar = ByondValue::new_list()?;
    for ((cx, cy), chunk) in chunks {
        let mut entries = ByondValue::new_list()?;
        entries.write_list(chunk.indices)?;
        lookup.write_list_index(format!("{cx},{cy}"), entries)?;
        let mut runs = ByondValue::new_list()?;
        runs.write_list(row_runs(&chunk.rows))?;
        let mut geometry = ByondValue::new_list()?;
        geometry.write_list_index("x", cx as f32 * 16.0)?;
        geometry.write_list_index("y", cy as f32 * 16.0)?;
        geometry.write_list_index("carp", field.carp)?;
        geometry.write_list_index("runs", runs)?;
        radar.write_list_index(format!("{cx},{cy}"), geometry)?;
    }
    let mut out = ByondValue::new_list()?;
    out.write_list([positions, lookup, radar])?;
    Ok(out)
}
