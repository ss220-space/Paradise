mod collision;
mod navigation;
mod radar;

use meowtonin::{byond_fn, ByondError, ByondResult, ByondValue, ByondValueType};
use rand::{rngs::SmallRng, RngExt, SeedableRng};
use std::cell::RefCell;
use std::collections::{BTreeMap, HashMap};

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
    indices: Vec<u32>,
    hit_index: Option<Box<[u32; 256]>>,
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
            while x < 16 && row & (1 << x) != 0 {
                x += 1;
            }
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
        strength - 0.42 + cloud_noise(cx, cy) > minimum + 0.002
    }

    fn generate(&self, seed: u64) -> Vec<[i32; 2]> {
        let mut rng = SmallRng::seed_from_u64(seed);
        let density = self.density;
        let mut budget = if self.carp {
            density * 24
        } else {
            ((self.span * self.span) as f64 * (0.9 * (density * density) as f64 / 64.0)).round()
                as usize
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
                    && centers
                        .iter()
                        .any(|c| (c[0] - x).abs() < 10 && (c[1] - y).abs() < 10)
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

fn cloud_noise(x: f32, y: f32) -> f32 {
    ((x * 361.0 + y * 173.0) as f64).to_radians().sin() as f32 * 0.08
        + ((x * 719.0 - y * 431.0) as f64).to_radians().sin() as f32 * 0.05
}

#[byond_fn]
fn overmap_scatter_create(
    owner: ByondValue,
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
        return Err(ByondError::boxed(std::io::Error::other(
            "overmap_scatter: invalid cell span",
        )));
    }
    let mut neighbors = Vec::new();
    for peer in peers.read_list()? {
        let values = peer.read_list()?;
        if values.len() != 3 {
            return Err(ByondError::boxed(std::io::Error::other(
                "overmap_scatter: invalid neighbor",
            )));
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
    let owner = object_id(&owner)?;
    let mut scatter = Scatter::default();
    let health = if field.carp { 40.0 } else { 100.0 };
    let points = field.generate(seed.get_number()? as u64);
    scatter.points.reserve_exact(points.len());
    for [x, y] in points {
        let chunk = scatter
            .chunks
            .entry((x.div_euclid(16), y.div_euclid(16)))
            .or_default();
        chunk.indices.push(scatter.points.len() as u32);
        chunk.rows[y.rem_euclid(16) as usize] |= 1 << x.rem_euclid(16);
        scatter.points.push(Point { x, y, health });
    }
    let mut radar = ByondValue::new_list()?;
    for (&(cx, cy), chunk) in &scatter.chunks {
        let mut geometry = ByondValue::new_list()?;
        geometry.write_list_index("x", (cx * 16) as f32)?;
        geometry.write_list_index("y", (cy * 16) as f32)?;
        geometry.write_list_index("carp", field.carp)?;
        geometry.write_list_index("runs", chunk.radar_runs()?)?;
        radar.write_list_index(format!("{cx},{cy}"), geometry)?;
    }
    FIELDS.with_borrow_mut(|fields| fields.insert(owner, scatter));
    Ok(radar)
}

fn object_id(value: &ByondValue) -> ByondResult<u32> {
    match value.get_type() {
        ByondValueType::Obj | ByondValueType::Datum => Ok(value.ref_id().unwrap_or(0)),
        _ => Err(ByondError::boxed(std::io::Error::other(
            "overmap: invalid owner",
        ))),
    }
}

struct Point {
    x: i32,
    y: i32,
    health: f32,
}

#[derive(Default)]
struct Scatter {
    points: Vec<Point>,
    chunks: BTreeMap<(i32, i32), Chunk>,
}

thread_local! {
    static FIELDS: RefCell<HashMap<u32, Scatter>> = RefCell::default();
}

impl Chunk {
    fn radar_runs(&self) -> ByondResult<ByondValue> {
        let mut result = ByondValue::new_list()?;
        result.write_list(row_runs(&self.rows))?;
        Ok(result)
    }
}

fn point_id(index: u32) -> f32 {
    (index * 3 + 1) as f32
}

fn point_index(id: &ByondValue) -> ByondResult<Option<usize>> {
    let id = id.get_number()?;
    Ok((id >= 1.0 && (id - 1.0) % 3.0 == 0.0).then(|| ((id - 1.0) / 3.0) as usize))
}

#[byond_fn]
fn overmap_scatter_drop(owner: ByondValue) -> ByondResult<ByondValue> {
    let id = object_id(&owner)?;
    FIELDS.with_borrow_mut(|fields| fields.remove(&id));
    Ok(ByondValue::NULL)
}

#[byond_fn]
fn overmap_scatter_near(
    owner: ByondValue,
    x: ByondValue,
    y: ByondValue,
    reach: ByondValue,
    circle: ByondValue,
) -> ByondResult<ByondValue> {
    let id = object_id(&owner)?;
    let (x, y, reach) = (x.get_number()?, y.get_number()?, reach.get_number()?);
    let circle = circle.get_number()? != 0.0;
    let mut values = Vec::new();
    FIELDS.with_borrow(|fields| {
        let Some(field) = fields.get(&id) else { return };
        for cx in ((x - reach) / 16.0).floor() as i32..=((x + reach) / 16.0).floor() as i32 {
            for cy in ((y - reach) / 16.0).floor() as i32..=((y + reach) / 16.0).floor() as i32 {
                let Some(chunk) = field.chunks.get(&(cx, cy)) else {
                    continue;
                };
                for &i in &chunk.indices {
                    let p = &field.points[i as usize];
                    let (px, py) = (p.x as f32, p.y as f32);
                    if p.health > 0.0
                        && (!circle || (px - x).powi(2) + (py - y).powi(2) <= reach * reach)
                    {
                        values.extend([point_id(i), px, py].map(ByondValue::new_num));
                    }
                }
            }
        }
    });
    let mut result = ByondValue::new_list()?;
    result.write_list(values)?;
    Ok(result)
}

#[byond_fn]
fn overmap_scatter_at(owner: ByondValue, x: ByondValue, y: ByondValue) -> ByondResult<ByondValue> {
    let id = object_id(&owner)?;
    let (x, y) = (x.get_number()? as i32, y.get_number()? as i32);
    let hit = FIELDS.with_borrow_mut(|fields| {
        let field = fields.get_mut(&id)?;
        let chunk = field
            .chunks
            .get_mut(&(x.div_euclid(16), y.div_euclid(16)))?;
        let row = y.rem_euclid(16) as usize;
        let col = x.rem_euclid(16) as usize;
        if chunk.rows[row] & (1 << col) == 0 {
            return None;
        }
        let indices = chunk.hit_index.get_or_insert_with(|| {
            let mut slots = Box::new([0; 256]);
            for &i in &chunk.indices {
                let point = &field.points[i as usize];
                slots[(point.y.rem_euclid(16) * 16 + point.x.rem_euclid(16)) as usize] = i;
            }
            slots
        });
        Some(point_id(indices[row * 16 + col]))
    });
    Ok(hit.map_or(ByondValue::NULL, ByondValue::new_num))
}

#[byond_fn]
fn overmap_scatter_health(owner: ByondValue, index: ByondValue) -> ByondResult<ByondValue> {
    let owner = object_id(&owner)?;
    let index = point_index(&index)?;
    let health =
        FIELDS.with_borrow(|fields| fields.get(&owner)?.points.get(index?).map(|p| p.health));
    Ok(ByondValue::new_num(health.unwrap_or(0.0)))
}

#[byond_fn]
fn overmap_scatter_damage(
    owner: ByondValue,
    index: ByondValue,
    damage: ByondValue,
) -> ByondResult<ByondValue> {
    let owner = object_id(&owner)?;
    let index = point_index(&index)?;
    let damage = damage.get_number()?;
    let destroyed = FIELDS.with_borrow_mut(|fields| {
        let field = fields.get_mut(&owner)?;
        let p = field.points.get_mut(index?)?;
        if p.health <= 0.0 || damage <= 0.0 {
            return None;
        }
        p.health = (p.health - damage).max(0.0);
        if p.health > 0.0 {
            return None;
        }
        let key = (p.x.div_euclid(16), p.y.div_euclid(16));
        field.chunks.get_mut(&key)?.rows[p.y.rem_euclid(16) as usize] &= !(1 << p.x.rem_euclid(16));
        Some(format!("{},{}", key.0, key.1))
    });
    Ok(destroyed.map_or(ByondValue::NULL, ByondValue::new_string))
}

#[byond_fn]
fn overmap_scatter_runs(
    owner: ByondValue,
    x: ByondValue,
    y: ByondValue,
) -> ByondResult<ByondValue> {
    let owner = object_id(&owner)?;
    let key = (x.get_number()? as i32, y.get_number()? as i32);
    FIELDS.with_borrow(
        |fields| match fields.get(&owner).and_then(|field| field.chunks.get(&key)) {
            Some(chunk) => chunk.radar_runs(),
            None => ByondValue::new_list(),
        },
    )
}
