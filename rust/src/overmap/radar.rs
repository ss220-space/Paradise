use super::cloud_noise;
use indexmap::IndexSet;
use meowtonin::{byond_fn, ByondError, ByondResult, ByondValue};
use rayon::prelude::*;
use std::collections::{HashMap, HashSet};
use std::fmt::Write;

type Tile = (i32, i32);

fn coordinates(value: &ByondValue) -> ByondResult<Vec<(f32, f32)>> {
    let values = value.read_list()?;
    let pairs = values.chunks_exact(2);
    if !pairs.remainder().is_empty() {
        return Err(ByondError::boxed(std::io::Error::other(
            "incomplete overmap coordinate pair",
        )));
    }
    pairs
        .map(|p| Ok((p[0].get_number()?, p[1].get_number()?)))
        .collect()
}

#[byond_fn]
fn overmap_radar_outline(
    cells: ByondValue,
    center_x: ByondValue,
    center_y: ByondValue,
    step: ByondValue,
) -> ByondResult<ByondValue> {
    let (cx, cy, step) = (
        center_x.get_number()?,
        center_y.get_number()?,
        step.get_number()?,
    );
    let occupied: HashSet<Tile> = coordinates(&cells)?
        .into_iter()
        .map(|(x, y)| {
            (
                ((x - cx) / step).floor() as i32,
                ((y - cy) / step).floor() as i32,
            )
        })
        .collect();
    let mut edges = Vec::new();
    for &(x, y) in &occupied {
        for (neighbor, edge) in [
            ((x - 1, y), ('v', x, y)),
            ((x + 1, y), ('v', x + 1, y)),
            ((x, y - 1), ('h', y, x)),
            ((x, y + 1), ('h', y + 1, x)),
        ] {
            if !occupied.contains(&neighbor) {
                edges.push(edge);
            }
        }
    }
    edges.sort_unstable();
    let mut edges = edges.into_iter().peekable();
    let mut path = String::new();
    while let Some((axis, line, start)) = edges.next() {
        let mut end = start + 1;
        while edges.next_if_eq(&(axis, line, end)).is_some() {
            end += 1;
        }
        let (x, y) = if axis == 'h' {
            (start, line)
        } else {
            (line, start)
        };
        let x = x as f32 * step - 0.5;
        let y = y as f32 * step - 0.5;
        let length = (end - start) as f32 * step;
        if !path.is_empty() {
            path.push(' ');
        }
        write!(&mut path, "M{x} {y}{axis}{length}").unwrap();
    }
    Ok(ByondValue::new_string(path))
}

fn occupied_sample((ix, iy): Tile, counts: &HashMap<Tile, usize>, span: f32) -> bool {
    let x = ((ix as f32 + 0.5) * span / 8.0) / span;
    let y = ((iy as f32 + 0.5) * span / 8.0) / span;
    let mut strength = 0.0;
    for fx in x.floor() as i32..=x.floor() as i32 + 1 {
        for fy in y.floor() as i32..=y.floor() as i32 + 1 {
            if let Some(&count) = counts.get(&(fx, fy)) {
                let contribution =
                    (1.0 - ((x - fx as f32).powi(2) + (y - fy as f32).powi(2)) / 0.8).max(0.0);
                for _ in 0..count {
                    strength += contribution;
                }
            }
        }
    }
    strength - 0.42 + cloud_noise(x, y) > 0.0
}

#[byond_fn]
fn overmap_hazard_rings(
    fields: ByondValue,
    contributors: ByondValue,
    origin_x: ByondValue,
    origin_y: ByondValue,
    span: ByondValue,
) -> ByondResult<ByondValue> {
    let (origin_x, origin_y, span) = (
        origin_x.get_number()?,
        origin_y.get_number()?,
        span.get_number()?,
    );
    let mut counts = HashMap::new();
    for (x, y) in coordinates(&contributors)? {
        *counts.entry((x as i32, y as i32)).or_default() += 1;
    }
    let mut candidates = IndexSet::new();
    for (x, y) in coordinates(&fields)? {
        for ix in x as i32 * 8 - 7..=x as i32 * 8 + 6 {
            for iy in y as i32 * 8 - 7..=y as i32 * 8 + 6 {
                candidates.insert((ix, iy));
            }
        }
    }
    let points: Vec<_> = candidates.into_iter().collect();
    let sample = |p: &Tile| occupied_sample(*p, &counts, span);
    let samples: IndexSet<_> = if points.len() < 4096 {
        points.into_iter().filter(sample).collect()
    } else {
        let chunks: Vec<Vec<_>> = points
            .par_chunks(points.len().div_ceil(4).max(2048))
            .map(|chunk| chunk.iter().copied().filter(sample).collect())
            .collect();
        chunks.into_iter().flatten().collect()
    };
    let mut edges: HashMap<Tile, Vec<Tile>> = HashMap::new();
    let mut starts = Vec::new();
    for &(x, y) in &samples {
        for (neighbor, from, to) in [
            ((x, y - 1), (x, y), (x + 1, y)),
            ((x + 1, y), (x + 1, y), (x + 1, y + 1)),
            ((x, y + 1), (x + 1, y + 1), (x, y + 1)),
            ((x - 1, y), (x, y + 1), (x, y)),
        ] {
            if !samples.contains(&neighbor) {
                edges
                    .entry(from)
                    .or_insert_with(|| {
                        starts.push(from);
                        Vec::new()
                    })
                    .push(to);
            }
        }
    }
    let mut rings = Vec::new();
    for start in starts {
        while edges.get(&start).is_some_and(|out| !out.is_empty()) {
            let mut ring = Vec::new();
            let mut cursor = start;
            while let Some(next) = edges.get_mut(&cursor).and_then(Vec::pop) {
                ring.push(ByondValue::new_num(cursor.0 as f32 / 8.0 - origin_x + 1.0));
                ring.push(ByondValue::new_num(cursor.1 as f32 / 8.0 - origin_y + 1.0));
                cursor = next;
                if cursor == start {
                    break;
                }
            }
            if ring.len() >= 6 {
                let mut list = ByondValue::new_list()?;
                list.write_list(ring)?;
                rings.push(list);
            }
        }
    }
    let mut result = ByondValue::new_list()?;
    result.write_list(rings)?;
    Ok(result)
}
