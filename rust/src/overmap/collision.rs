use super::{navigation::numbers, object_id};
use meowtonin::{byond_fn, ByondError, ByondResult, ByondValue};
use std::cell::RefCell;
use std::collections::HashMap;

struct Hull {
    edges: Vec<[f32; 2]>,
    solid: HashMap<(i32, i32), usize>,
}

thread_local! {
    static HULLS: RefCell<HashMap<u32, Hull>> = RefCell::default();
}

fn coordinates(values: &ByondValue) -> ByondResult<Vec<[f32; 2]>> {
    let list = values.read_list()?;
    if list.len() % 2 != 0 {
        return Err(ByondError::boxed(std::io::Error::other(
            "incomplete hull coordinates",
        )));
    }
    list.chunks_exact(2)
        .map(|p| Ok([p[0].get_number()?, p[1].get_number()?]))
        .collect()
}

#[byond_fn]
fn overmap_hull_upload(
    owner: ByondValue,
    edges: ByondValue,
    solid: ByondValue,
) -> ByondResult<ByondValue> {
    let owner = object_id(&owner)?;
    let edges = coordinates(&edges)?;
    let solid = coordinates(&solid)?
        .into_iter()
        .enumerate()
        .map(|(i, [x, y])| ((x as i32, y as i32), i + 1))
        .collect();
    HULLS.with_borrow_mut(|cache| cache.insert(owner, Hull { edges, solid }));
    Ok(ByondValue::new_num(1.0_f32))
}

#[byond_fn]
fn overmap_hull_drop(owner: ByondValue) -> ByondResult<ByondValue> {
    let owner = object_id(&owner)?;
    HULLS.with_borrow_mut(|cache| cache.remove(&owner));
    Ok(ByondValue::NULL)
}

#[byond_fn]
fn overmap_hull_contacts(
    owner: ByondValue,
    target: ByondValue,
    frame: ByondValue,
) -> ByondResult<ByondValue> {
    let owner = object_id(&owner)?;
    let target = object_id(&target)?;
    let [x, y, cos, sin, ox, oy, oc, os, cx, cy] = numbers(&frame)?;
    let mut hits = Vec::new();
    HULLS.with_borrow(|cache| {
        let (Some(source), Some(target)) = (cache.get(&owner), cache.get(&target)) else {
            return;
        };
        for (i, [lx, ly]) in source.edges.iter().copied().enumerate() {
            let wx = x + lx * cos + ly * sin;
            let wy = y - lx * sin + ly * cos;
            let (dx, dy) = (wx - ox, wy - oy);
            let tx = (cx + dx * oc - dy * os + 0.5).floor() as i32;
            let ty = (cy + dx * os + dy * oc + 0.5).floor() as i32;
            if let Some(j) = target.solid.get(&(tx, ty)) {
                hits.extend([(i + 1) as f32, *j as f32, wx, wy].map(ByondValue::new_num));
            }
        }
    });
    let mut out = ByondValue::new_list()?;
    out.write_list(hits)?;
    Ok(out)
}

struct Body {
    index: u32,
    sector: u32,
    x: f32,
    y: f32,
    radius: f32,
    travel: f32,
}

#[byond_fn]
fn overmap_collision_pairs(input: ByondValue) -> ByondResult<ByondValue> {
    let input = input.read_list()?;
    if input.len() % 6 != 0 {
        return Err(ByondError::boxed(std::io::Error::other(
            "incomplete collision snapshot",
        )));
    }
    let mut bodies = Vec::with_capacity(input.len() / 6);
    for row in input.chunks_exact(6) {
        bodies.push(Body {
            index: row[0].get_number()? as u32,
            sector: object_id(&row[1])?,
            x: row[2].get_number()?,
            y: row[3].get_number()?,
            radius: row[4].get_number()?,
            travel: row[5].get_number()?,
        });
    }
    let left = |b: &Body| b.x - (b.radius + b.travel + 1.0);
    bodies.sort_unstable_by(|a, b| {
        a.sector
            .cmp(&b.sector)
            .then_with(|| left(a).total_cmp(&left(b)))
    });
    let mut pairs = Vec::new();
    for (i, a) in bodies.iter().enumerate() {
        let right = a.x + (a.radius + a.travel + 1.0);
        for b in &bodies[i + 1..] {
            if a.sector != b.sector || left(b) > right {
                break;
            }
            let (first, second) = if a.index < b.index { (a, b) } else { (b, a) };
            let reach = first.radius + second.radius + first.travel + second.travel;
            let dx = a.x - b.x;
            let dy = a.y - b.y;
            if (dx * dx + dy * dy).sqrt() <= reach {
                pairs.push((first.index, second.index));
            }
        }
    }
    pairs.sort_unstable();
    let mut out = ByondValue::new_list()?;
    out.write_list(
        pairs
            .into_iter()
            .flat_map(|(a, b)| [ByondValue::new_num(a as f32), ByondValue::new_num(b as f32)])
            .collect::<Vec<_>>(),
    )?;
    Ok(out)
}
