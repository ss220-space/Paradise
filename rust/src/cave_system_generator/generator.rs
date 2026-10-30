use rand::distr::{Bernoulli, Distribution};

use super::automata::{ca_step, flood_fill_island_removal};
use super::config::{GeneratorConfig, PrefabConfig};
use super::layout::{build_adjacency_edges, carve_corridor, collect_leaves, generate_room, kruskal_mst, BSPNode};
use super::{Result, ALIVE, DEAD, DEF_ALIVE, DEF_DEAD};

pub(super) fn generate_cave_system(
    width: usize,
    height: usize,
    prefabs_json: &str,
    config: GeneratorConfig,
) -> Result<String> {
    if width == 0 || height == 0 {
        return Ok(String::new());
    }

    let prefabs: Vec<PrefabConfig> = if prefabs_json.is_empty() || prefabs_json == "[]" {
        Vec::new()
    } else {
        serde_json::from_str(prefabs_json)?
    };

    let GeneratorConfig {
        min_bsp_size,
        max_ratio,
        padding,
        room_fill_percent,
        corridor_width,
        loop_percent,
        noise_percent,
        ca_steps,
        birth_limit,
        survival_limit,
        edge_is_alive,
    } = config;

    let size_scale = (room_fill_percent as f64 / 100.0).clamp(0.0, 1.0);
    let mut rng = rand::rng();
    let mut grid: Vec<Vec<u8>> = vec![vec![DEAD; height]; width];
    let mut fixed: Vec<Vec<bool>> = vec![vec![false; height]; width];

    for prefab in &prefabs {
        apply_prefab(&mut grid, &mut fixed, prefab, width, height);
    }

    let mut root = BSPNode::new(0, 0, width, height);
    root.split(min_bsp_size, max_ratio, &mut rng);
    let mut leaves: Vec<BSPNode> = Vec::new();
    collect_leaves(&root, &mut leaves);
    if leaves.is_empty() {
        leaves.push(BSPNode::new(0, 0, width, height));
    }
    for leaf in &mut leaves {
        leaf.room = generate_room(leaf, padding, size_scale, &mut rng);
    }
    let edges = build_adjacency_edges(&leaves);
    let mst_edges = kruskal_mst(leaves.len(), &edges, loop_percent, &mut rng);
    leaves.iter().for_each(|leaf| {
        if let Some(ref room) = leaf.room {
            (0..room.w).for_each(|dx| {
                (0..room.h).for_each(|dy| {
                    let gx = room.x + dx;
                    let gy = room.y + dy;
                    if gx < width && gy < height && !fixed[gx][gy] {
                        grid[gx][gy] = DEF_ALIVE;
                        fixed[gx][gy] = true;
                    }
                });
            });
        }
    });
    for edge in &mst_edges {
        if let (Some(ra), Some(rb)) = (leaves[edge.u].room.as_ref(), leaves[edge.v].room.as_ref()) {
            carve_corridor(
                &mut grid,
                &mut fixed,
                (ra.cx, ra.cy),
                (rb.cx, rb.cy),
                corridor_width,
                &mut rng,
            );
        }
    }
    let prob = Bernoulli::new((noise_percent as f64 / 100.0).clamp(0.0, 1.0)).unwrap();
    for x in 0..width {
        for y in 0..height {
            if !fixed[x][y] {
                grid[x][y] = if prob.sample(&mut rng) { ALIVE } else { DEAD };
            }
        }
    }
    for _ in 0..ca_steps {
        ca_step(
            &mut grid,
            width,
            height,
            birth_limit,
            survival_limit,
            edge_is_alive,
        );
    }
    if let Some(start) = leaves
        .iter()
        .find_map(|leaf| leaf.room.as_ref().map(|room| (room.cx, room.cy)))
    {
        flood_fill_island_removal(&mut grid, width, height, start);
    }
    let grid_string: String = (0..height)
        .flat_map(|y| (0..width).map(move |x| (x, y)))
        .map(|(x, y)| match grid[x][y] {
            ALIVE | DEF_ALIVE => '1',
            _ => '0',
        })
        .collect();

    Ok(grid_string)
}
fn apply_prefab(
    grid: &mut [Vec<u8>],
    fixed: &mut [Vec<bool>],
    prefab: &PrefabConfig,
    width: usize,
    height: usize,
) {
    let px = prefab.x.saturating_sub(1);
    let py = prefab.y.saturating_sub(1);
    let pw = prefab.w.min(width.saturating_sub(px));
    let ph = prefab.h.min(height.saturating_sub(py));

    for dy in 0..ph {
        for dx in 0..pw {
            let gx = px + dx;
            let gy = py + dy;
            if gx < width && gy < height {
                if prefab.is_enclosed {
                    grid[gx][gy] = DEF_DEAD;
                } else {
                    grid[gx][gy] = DEF_ALIVE;
                }
                fixed[gx][gy] = true;
            }
        }
    }
}
