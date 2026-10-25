use meowtonin::{byond_fn, ByondError, ByondResult, ByondValue};
use once_cell::sync::Lazy;
use std::error::Error;
use std::sync::Mutex;

use crate::logging::setup_panic_handler;

static FOG: Lazy<Mutex<FogWorld>> = Lazy::new(|| Mutex::new(FogWorld::new()));

const FOG_MAX_RADIUS: i32 = 32;

struct Grid {
    width: usize,
    height: usize,
    bits: Vec<u64>,
}

impl Grid {
    fn new(width: usize, height: usize) -> Self {
        let cells = width * height;
        Grid {
            width,
            height,
            bits: vec![0u64; cells.div_ceil(64)],
        }
    }

    fn clear(&mut self) {
        for word in self.bits.iter_mut() {
            *word = 0;
        }
    }

    fn index(&self, x: i32, y: i32) -> Option<usize> {
        if x < 1 || y < 1 {
            return None;
        }
        let (x, y) = (x as usize, y as usize);
        if x > self.width || y > self.height {
            return None;
        }
        Some((y - 1) * self.width + (x - 1))
    }

    fn set(&mut self, x: i32, y: i32, blocked: bool) {
        if let Some(index) = self.index(x, y) {
            let bit = 1u64 << (index % 64);
            let word = &mut self.bits[index / 64];
            if blocked {
                *word |= bit;
            } else {
                *word &= !bit;
            }
        }
    }

    fn get(&self, x: i32, y: i32) -> bool {
        match self.index(x, y) {
            Some(index) => self.bits[index / 64] & (1u64 << (index % 64)) != 0,
            None => false,
        }
    }

}

struct FogWorld {
    maxx: usize,
    maxy: usize,
    maxz: usize,

    grids: Vec<Option<Grid>>,
}

impl FogWorld {
    fn new() -> Self {
        FogWorld {
            maxx: 0,
            maxy: 0,
            maxz: 0,
            grids: Vec::new(),

        }
    }

    fn ensure_grid(&mut self, z: i32) -> bool {
        if z < 1 || self.maxx == 0 || self.maxy == 0 {
            return false;
        }
        let slot = z as usize;
        if slot >= self.grids.len() {

            self.grids.resize_with(slot + 1, || None);
            if slot > self.maxz {
                self.maxz = slot;
            }
        }
        if self.grids[slot].is_none() {
            self.grids[slot] = Some(Grid::new(self.maxx, self.maxy));
        }
        true
    }
}

fn step(current: (i32, i32), target: (i32, i32)) -> (i32, i32) {
    let dx = target.0 - current.0;
    let dy = target.1 - current.1;
    (current.0 + dx.signum(), current.1 + dy.signum())
}

fn line_of_sight(grid: &Grid, from: (i32, i32), to: (i32, i32)) -> bool {
    if from == to {
        return true;
    }
    let steps = (to.0 - from.0).abs().max((to.1 - from.1).abs());
    let mut current = from;
    for _ in 0..steps {
        current = step(current, to);
        if current == to {
            return true;
        }
        if grid.get(current.0, current.1) {
            return false;
        }
    }
    true
}

fn line_of_sight_straight(grid: &Grid, from: (i32, i32), to: (i32, i32)) -> bool {
    if from == to {
        return true;
    }
    let (mut current_x, mut current_y) = from;
    let x_distance = to.0 - current_x;
    let y_distance = to.1 - current_y;
    let (abs_x, abs_y) = (x_distance.abs(), y_distance.abs());
    let (x_sign, y_sign) = (x_distance.signum(), y_distance.signum());
    let (mut x, mut y) = (abs_x >> 1, abs_y >> 1);

    if abs_x >= abs_y {
        for _ in 0..abs_x {
            y += abs_y;
            if y >= abs_x {
                y -= abs_x;
                current_y += y_sign;
            }
            current_x += x_sign;
            if current_x == to.0 && current_y == to.1 {
                return true;
            }
            if grid.get(current_x, current_y) {
                return false;
            }
        }
    } else {
        for _ in 0..abs_y {
            x += abs_x;
            if x >= abs_y {
                x -= abs_x;
                current_x += x_sign;
            }
            current_y += y_sign;
            if current_x == to.0 && current_y == to.1 {
                return true;
            }
            if grid.get(current_x, current_y) {
                return false;
            }
        }
    }
    true
}

fn line_of_sight_union(grid: &Grid, from: (i32, i32), to: (i32, i32)) -> bool {
    line_of_sight(grid, from, to) || line_of_sight_straight(grid, from, to)
}

const FOG_MODEL_UNION: i32 = 2;

fn line_of_sight_for(grid: &Grid, from: (i32, i32), to: (i32, i32), model: i32) -> bool {
    match model {
        1 => line_of_sight(grid, from, to),
        3 => line_of_sight_straight(grid, from, to),
        _ => line_of_sight_union(grid, from, to),
    }
}

fn cast(grid: &Grid, x: i32, y: i32, radius: i32, model: i32) -> String {
    let side = (radius * 2 + 1) as usize;
    let mut visible = vec![false; side * side];
    let index = |dx: i32, dy: i32| ((dy + radius) as usize) * side + ((dx + radius) as usize);

    for dy in -radius..=radius {
        for dx in -radius..=radius {
            if line_of_sight_for(grid, (x, y), (x + dx, y + dy), model) {
                visible[index(dx, dy)] = true;
            }
        }
    }

    let mut out = String::with_capacity(side * side);
    for dy in -radius..=radius {
        for dx in -radius..=radius {
            let (tx, ty) = (x + dx, y + dy);
            if grid.index(tx, ty).is_none() {
                out.push('2');
                continue;
            }
            if visible[index(dx, dy)] {
                out.push('0');
                continue;
            }

            let mut on_the_edge = false;
            if grid.get(tx, ty) {
                'neighbours: for ny in -1..=1 {
                    for nx in -1..=1 {
                        if nx == 0 && ny == 0 {
                            continue;
                        }
                        let (px, py) = (dx + nx, dy + ny);
                        if px.abs() > radius || py.abs() > radius {
                            continue;
                        }
                        if visible[index(px, py)] {
                            on_the_edge = true;
                            break 'neighbours;
                        }
                    }
                }
            }
            out.push(if on_the_edge { '0' } else { '1' });
        }
    }
    out
}

fn overlay_grid(base: &Grid, x: i32, y: i32, radius: i32, packed: &str) -> Grid {
    let side = (radius * 2 + 1) as usize;
    let mut grid = Grid::new(side, side);
    let virtual_grid = packed.starts_with("virtual;");
    let packed = packed.strip_prefix("virtual;").unwrap_or(packed);
    if !virtual_grid {
        for dy in -radius..=radius {
            for dx in -radius..=radius {
                grid.set(dx + radius + 1, dy + radius + 1, base.get(x + dx, y + dy));
            }
        }
    }
    for entry in packed.split(';') {
        let mut fields = entry.split(',');
        let bx = fields.next().and_then(|value| value.parse::<i32>().ok());
        let by = fields.next().and_then(|value| value.parse::<i32>().ok());
        if let (Some(bx), Some(by)) = (bx, by) {
            grid.set(bx - x + radius + 1, by - y + radius + 1, true);
        }
    }
    grid
}

fn lock_error() -> ByondError {
    ByondError::Boxed(Box::<dyn Error + Send + Sync>::from("fog: the world grid lock is poisoned"))
}

fn err<T>(message: String) -> ByondResult<T> {
    Err(ByondError::Boxed(Box::<dyn Error + Send + Sync>::from(message)))
}

fn whole_number(value: &ByondValue, name: &str) -> ByondResult<i32> {

    let number = value.get_number()?;
    if number.fract() != 0.0 || number < i32::MIN as f32 || number > i32::MAX as f32 {
        return err(format!("fog: {name} must be a whole number, got {number}"));
    }
    Ok(number as i32)
}

#[byond_fn]
fn fog_init(maxx: ByondValue, maxy: ByondValue, maxz: ByondValue) -> ByondResult<ByondValue> {
    setup_panic_handler();
    let (maxx, maxy, maxz) = (
        whole_number(&maxx, "maxx")?,
        whole_number(&maxy, "maxy")?,
        whole_number(&maxz, "maxz")?,
    );
    if maxx < 1 || maxy < 1 || maxz < 1 {
        return err(format!("fog_init: bad world size {maxx}x{maxy}x{maxz}"));
    }
    let mut world = FOG.lock().map_err(|_| lock_error())?;
    world.maxx = maxx as usize;
    world.maxy = maxy as usize;
    world.maxz = maxz as usize;
    world.grids = (0..=maxz as usize).map(|_| None).collect();
    drop(world);
    Ok(ByondValue::new_string("OK".to_string()))
}

#[byond_fn]
fn fog_reset() -> ByondResult<ByondValue> {
    let mut world = FOG.lock().map_err(|_| lock_error())?;
    for slot in world.grids.iter_mut() {
        *slot = None;
    }
    drop(world);
    Ok(ByondValue::new_string("OK".to_string()))
}

#[byond_fn]
fn fog_load_z(z: ByondValue, packed: ByondValue) -> ByondResult<ByondValue> {
    let z = whole_number(&z, "z")?;
    let packed = packed.get_string()?;
    let mut world = FOG.lock().map_err(|_| lock_error())?;
    if !world.ensure_grid(z) {
        return err(format!("fog_load_z: z{z} is outside the world the library was initialised with"));
    }
    let mut blocked = 0u32;
    if let Some(grid) = world.grids[z as usize].as_mut() {
        grid.clear();
        for entry in packed.split(';') {
            if entry.is_empty() {
                continue;
            }
            let mut fields = entry.split(',');
            let x = fields.next().and_then(|field| field.parse::<i32>().ok());
            let y = fields.next().and_then(|field| field.parse::<i32>().ok());
            if let (Some(x), Some(y)) = (x, y) {
                grid.set(x, y, true);
                blocked += 1;
            }
        }
    }
    drop(world);
    Ok(ByondValue::new_string(blocked.to_string()))
}

#[byond_fn]
fn fog_set(x: ByondValue, y: ByondValue, z: ByondValue, blocked: ByondValue) -> ByondResult<ByondValue> {
    let (x, y, z) = (
        whole_number(&x, "x")?,
        whole_number(&y, "y")?,
        whole_number(&z, "z")?,
    );
    let blocked = blocked.get_number()? != 0.0;
    let mut world = FOG.lock().map_err(|_| lock_error())?;
    if !world.ensure_grid(z) {
        return err(format!("fog_set: z{z} is outside the world the library was initialised with"));
    }
    if let Some(grid) = world.grids[z as usize].as_mut() {
        grid.set(x, y, blocked);
    }
    drop(world);
    Ok(ByondValue::new_string("OK".to_string()))
}

#[byond_fn]
fn fog_apply_batch(packed: ByondValue) -> ByondResult<ByondValue> {
    let packed = packed.get_string()?;
    let mut world = FOG.lock().map_err(|_| lock_error())?;
    let mut applied = 0u32;
    for entry in packed.split(';') {
        if entry.is_empty() {
            continue;
        }
        let mut fields = entry.split(',');
        let x = fields.next().and_then(|field| field.parse::<i32>().ok());
        let y = fields.next().and_then(|field| field.parse::<i32>().ok());
        let z = fields.next().and_then(|field| field.parse::<i32>().ok());
        let blocked = fields.next().map(|field| field == "1").unwrap_or(false);
        if let (Some(x), Some(y), Some(z)) = (x, y, z) {
            if world.ensure_grid(z) {
                if let Some(grid) = world.grids[z as usize].as_mut() {
                    grid.set(x, y, blocked);
                    applied += 1;
                }
            }
        }
    }
    drop(world);
    Ok(ByondValue::new_string(applied.to_string()))
}

fn hidden_runs(bits: &str, radius: i32) -> Vec<f32> {
    let side = (2 * radius + 1) as usize;
    let mut runs = Vec::new();
    for (y, row) in bits.as_bytes().chunks_exact(side).enumerate() {
        let mut x = 0;
        while x < side {
            if row[x] != b'1' {
                x += 1;
                continue;
            }
            let start = x;
            while x < side && row[x] == b'1' {
                x += 1;
            }
            runs.extend([
                start as f32 - radius as f32,
                y as f32 - radius as f32,
                (x - start) as f32,
            ]);
        }
    }
    runs
}

#[byond_fn]
fn fog_hidden_runs(
    x: ByondValue,
    y: ByondValue,
    z: ByondValue,
    radius: ByondValue,
    packed: ByondValue,
) -> ByondResult<ByondValue> {
    let (x, y, z, radius) = (
        whole_number(&x, "x")?,
        whole_number(&y, "y")?,
        whole_number(&z, "z")?,
        whole_number(&radius, "radius")?,
    );
    if !(0..=FOG_MAX_RADIUS).contains(&radius) {
        return err(format!("fog_hidden_runs: invalid radius {radius}"));
    }
    let packed = packed.get_string()?;
    if packed.starts_with("virtual;") {
        let overlay = overlay_grid(&Grid::new(0, 0), x, y, radius, &packed);
        let bits = cast(&overlay, radius + 1, radius + 1, radius, FOG_MODEL_UNION);
        let mut out = ByondValue::new_list()?;
        out.write_list(hidden_runs(&bits, radius).into_iter().map(ByondValue::new_num))?;
        return Ok(out);
    }
    let mut world = FOG.lock().map_err(|_| lock_error())?;
    if !world.ensure_grid(z) {
        return err(format!("fog_hidden_runs: invalid z{z}"));
    }
    let Some(base) = world.grids[z as usize].as_ref() else {
        return err(format!("fog_hidden_runs: no grid for z{z}"));
    };
    let bits = if packed.is_empty() {
        cast(base, x, y, radius, FOG_MODEL_UNION)
    } else {
        let overlay = overlay_grid(base, x, y, radius, &packed);
        cast(&overlay, radius + 1, radius + 1, radius, FOG_MODEL_UNION)
    };
    drop(world);
    let mut out = ByondValue::new_list()?;
    out.write_list(hidden_runs(&bits, radius).into_iter().map(ByondValue::new_num))?;
    Ok(out)
}
