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

fn visit_contacts(
    source: &Hull,
    target: &Hull,
    frame: [f32; 10],
    mut accept: impl FnMut([f32; 4]) -> bool,
) -> bool {
    let [x, y, cos, sin, ox, oy, oc, os, cx, cy] = frame;
    for (i, [lx, ly]) in source.edges.iter().copied().enumerate() {
        let wx = x + lx * cos + ly * sin;
        let wy = y - lx * sin + ly * cos;
        let (dx, dy) = (wx - ox, wy - oy);
        let tx = (cx + dx * oc - dy * os + 0.5).floor() as i32;
        let ty = (cy + dx * os + dy * oc + 0.5).floor() as i32;
        if let Some(j) = target.solid.get(&(tx, ty)) {
            if accept([(i + 1) as f32, *j as f32, wx, wy]) {
                return true;
            }
        }
    }
    false
}

#[byond_fn]
fn overmap_hull_contacts(
    owner: ByondValue,
    target: ByondValue,
    frame: ByondValue,
) -> ByondResult<ByondValue> {
    let owner = object_id(&owner)?;
    let target = object_id(&target)?;
    let frame = numbers(&frame)?;
    let mut hits = Vec::new();
    HULLS.with_borrow(|cache| {
        let (Some(source), Some(target)) = (cache.get(&owner), cache.get(&target)) else {
            return;
        };
        visit_contacts(source, target, frame, |hit| {
            hits.extend(hit.map(ByondValue::new_num));
            false
        });
    });
    let mut out = ByondValue::new_list()?;
    out.write_list(hits)?;
    Ok(out)
}

#[byond_fn]
fn overmap_hull_impact(
    owner: ByondValue,
    target: ByondValue,
    sweep: ByondValue,
) -> ByondResult<ByondValue> {
    let owner = object_id(&owner)?;
    let target = object_id(&target)?;
    let [x, y, angle, dx, dy, rotation, ox, oy, other_angle, odx, ody, other_rotation, cx, cy, steps, refinements] =
        numbers(&sweep)?;
    let frame_at = |t: f32| {
        let trig = |degrees: f32| match degrees.rem_euclid(360.0) {
            0.0 => (0.0, 1.0),
            90.0 => (1.0, 0.0),
            180.0 => (0.0, -1.0),
            270.0 => (-1.0, 0.0),
            _ => {
                let (sin, cos) = f64::from(degrees).to_radians().sin_cos();
                (sin as f32, cos as f32)
            }
        };
        let (sin, cos) = trig(angle + rotation * t);
        let (os, oc) = trig(other_angle + other_rotation * t);
        [
            x + dx * t,
            y + dy * t,
            cos,
            sin,
            ox + odx * t,
            oy + ody * t,
            oc,
            os,
            cx,
            cy,
        ]
    };
    let mut hits = Vec::new();
    let found = HULLS.with_borrow(|cache| {
        let (Some(source), Some(target)) = (cache.get(&owner), cache.get(&target)) else {
            return false;
        };
        let mut safe = 0.0;
        for step in 1..=steps as usize {
            let mut hit = step as f32 / steps;
            if !visit_contacts(source, target, frame_at(hit), |_| true) {
                safe = hit;
                continue;
            }
            for _ in 0..refinements as usize {
                let middle = (safe + hit) / 2.0;
                if visit_contacts(source, target, frame_at(middle), |_| true) {
                    hit = middle;
                } else {
                    safe = middle;
                }
            }
            hits.push(ByondValue::new_num(safe));
            visit_contacts(source, target, frame_at(hit), |contact| {
                hits.extend(contact.map(ByondValue::new_num));
                false
            });
            break;
        }
        true
    });
    if !found {
        return Ok(ByondValue::NULL);
    }
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
