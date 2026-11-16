use rand::distr::{Bernoulli, Distribution, Uniform};
use rand::Rng;

use super::{DEF_ALIVE, DEF_DEAD};

pub(super) struct BSPNode {
    x: usize,
    y: usize,
    w: usize,
    h: usize,
    left: Option<Box<BSPNode>>,
    right: Option<Box<BSPNode>>,
    pub(super) room: Option<Room>,
}

pub(super) struct Room {
    pub(super) x: usize,
    pub(super) y: usize,
    pub(super) w: usize,
    pub(super) h: usize,
    pub(super) cx: usize,
    pub(super) cy: usize,
}

#[derive(Clone, Copy)]
pub(super) struct MSTEdge {
    pub(super) u: usize,
    pub(super) v: usize,
    pub(super) dist: f64,
}

impl BSPNode {
    pub(super) fn new(x: usize, y: usize, w: usize, h: usize) -> Self {
        BSPNode {
            x,
            y,
            w,
            h,
            left: None,
            right: None,
            room: None,
        }
    }

    pub(super) fn split(&mut self, min_size: usize, max_ratio: f64, rng: &mut impl Rng) {
        let can_split_h = self.h > min_size * 2;
        let can_split_v = self.w > min_size * 2;
        if !can_split_h && !can_split_v {
            return;
        }

        let coin = Bernoulli::new(0.5).unwrap();
        let mut split_horizontal = coin.sample(rng);
        if self.h > 0 && (self.w as f64 / self.h as f64) >= max_ratio {
            split_horizontal = false;
        }
        if self.w > 0 && (self.h as f64 / self.w as f64) >= max_ratio {
            split_horizontal = true;
        }

        if split_horizontal && !can_split_h {
            split_horizontal = false;
        } else if !split_horizontal && !can_split_v {
            split_horizontal = true;
        }
        if split_horizontal && !can_split_h {
            return;
        }
        if !split_horizontal && !can_split_v {
            return;
        }

        if split_horizontal {
            let split_y = Uniform::new(min_size, self.h - min_size)
                .unwrap()
                .sample(rng);
            let mut left = BSPNode::new(self.x, self.y, self.w, split_y);
            let mut right = BSPNode::new(self.x, self.y + split_y, self.w, self.h - split_y);
            left.split(min_size, max_ratio, rng);
            right.split(min_size, max_ratio, rng);
            self.left = Some(Box::new(left));
            self.right = Some(Box::new(right));
        } else {
            let split_x = Uniform::new(min_size, self.w - min_size)
                .unwrap()
                .sample(rng);
            let mut left = BSPNode::new(self.x, self.y, split_x, self.h);
            let mut right = BSPNode::new(self.x + split_x, self.y, self.w - split_x, self.h);
            left.split(min_size, max_ratio, rng);
            right.split(min_size, max_ratio, rng);
            self.left = Some(Box::new(left));
            self.right = Some(Box::new(right));
        }
    }
}

pub(super) fn collect_leaves(node: &BSPNode, leaves: &mut Vec<BSPNode>) {
    if node.left.is_none() && node.right.is_none() {
        leaves.push(BSPNode::new(node.x, node.y, node.w, node.h));
        return;
    }
    if let Some(ref left) = node.left {
        collect_leaves(left, leaves);
    }
    if let Some(ref right) = node.right {
        collect_leaves(right, leaves);
    }
}

pub(super) fn generate_room(
    leaf: &BSPNode,
    padding: usize,
    size_scale: f64,
    rng: &mut impl Rng,
) -> Option<Room> {
    let max_w = leaf.w.saturating_sub(padding * 2);
    let max_h = leaf.h.saturating_sub(padding * 2);
    if max_w < 3 || max_h < 3 {
        return None;
    }

    let lo_w = ((max_w as f64 * 0.3) as usize).max(1);
    let hi_w = (max_w as f64 * size_scale) as usize;
    let rw = (if hi_w > lo_w {
        Uniform::new(lo_w, hi_w).unwrap().sample(rng)
    } else {
        lo_w
    })
    .max(3)
    .min(max_w);

    let lo_h = ((max_h as f64 * 0.3) as usize).max(1);
    let hi_h = (max_h as f64 * size_scale) as usize;
    let rh = (if hi_h > lo_h {
        Uniform::new(lo_h, hi_h).unwrap().sample(rng)
    } else {
        lo_h
    })
    .max(3)
    .min(max_h);

    let rx = {
        let lo = padding;
        let hi = leaf.w.saturating_sub(rw + padding);
        let offset = if hi > lo {
            Uniform::new(lo, hi).unwrap().sample(rng)
        } else {
            lo
        };
        leaf.x + offset
    };
    let ry = {
        let lo = padding;
        let hi = leaf.h.saturating_sub(rh + padding);
        let offset = if hi > lo {
            Uniform::new(lo, hi).unwrap().sample(rng)
        } else {
            lo
        };
        leaf.y + offset
    };

    Some(Room {
        x: rx,
        y: ry,
        w: rw,
        h: rh,
        cx: rx + rw / 2,
        cy: ry + rh / 2,
    })
}

pub(super) fn build_adjacency_edges(leaves: &[BSPNode]) -> Vec<MSTEdge> {
    let mut edges = Vec::new();
    let n = leaves.len();
    for i in 0..n {
        for j in (i + 1)..n {
            if !rectangles_adjacent(&leaves[i], &leaves[j]) {
                continue;
            }
            let (ra, rb) = match (leaves[i].room.as_ref(), leaves[j].room.as_ref()) {
                (Some(a), Some(b)) => (a, b),
                _ => continue,
            };
            let dist = distance(ra.cx, ra.cy, rb.cx, rb.cy);
            edges.push(MSTEdge { u: i, v: j, dist });
        }
    }
    edges
}

fn rectangles_adjacent(a: &BSPNode, b: &BSPNode) -> bool {
    let a_right = a.x + a.w;
    let a_bottom = a.y + a.h;
    let b_right = b.x + b.w;
    let b_bottom = b.y + b.h;
    ((a.x == b_right || b.x == a_right) && !(a.y >= b_bottom || b.y >= a_bottom))
        || ((a.y == b_bottom || b.y == a_bottom) && !(a.x >= b_right || b.x >= a_right))
}

fn distance(x1: usize, y1: usize, x2: usize, y2: usize) -> f64 {
    let dx = x1 as f64 - x2 as f64;
    let dy = y1 as f64 - y2 as f64;
    (dx * dx + dy * dy).sqrt()
}

pub(super) fn kruskal_mst(
    n: usize,
    edges: &[MSTEdge],
    loop_percent: usize,
    rng: &mut impl Rng,
) -> Vec<MSTEdge> {
    let mut sorted = edges.to_vec();
    sorted.sort_by(|a, b| a.dist.partial_cmp(&b.dist).unwrap());

    let mut parent: Vec<usize> = (0..n).collect();
    let mut result = Vec::with_capacity(sorted.len());
    let loop_coin = Bernoulli::new((loop_percent as f64 / 100.0).clamp(0.0, 1.0)).unwrap();

    for edge in &sorted {
        let ru = uf_find(&parent, edge.u);
        let rv = uf_find(&parent, edge.v);
        if ru != rv {
            uf_union(&mut parent, edge.u, edge.v);
            result.push(*edge);
        } else if loop_coin.sample(rng) {
            result.push(*edge);
        }
    }
    result
}

fn uf_find(parent: &[usize], mut x: usize) -> usize {
    while parent[x] != x {
        x = parent[x];
    }
    x
}

fn uf_union(parent: &mut [usize], a: usize, b: usize) {
    let ra = uf_find(parent, a);
    let rb = uf_find(parent, b);
    if ra != rb {
        parent[ra] = rb;
    }
}

pub(super) fn carve_corridor(
    grid: &mut [Vec<u8>],
    fixed: &mut [Vec<bool>],
    start: (usize, usize),
    end: (usize, usize),
    cw: usize,
    rng: &mut impl Rng,
) {
    let coin = Bernoulli::new(0.5).unwrap();
    let go_x_first = coin.sample(rng);
    let mut cx = start.0 as i32;
    let mut cy = start.1 as i32;
    let tx = end.0 as i32;
    let ty = end.1 as i32;
    let cw_i = cw as i32;

    if go_x_first {
        while cx != tx {
            cx += (tx - cx).signum();
            paint_brush(grid, fixed, cx, cy, cw_i);
        }
        while cy != ty {
            cy += (ty - cy).signum();
            paint_brush(grid, fixed, cx, cy, cw_i);
        }
    } else {
        while cy != ty {
            cy += (ty - cy).signum();
            paint_brush(grid, fixed, cx, cy, cw_i);
        }
        while cx != tx {
            cx += (tx - cx).signum();
            paint_brush(grid, fixed, cx, cy, cw_i);
        }
    }
}

#[inline]
fn paint_brush(grid: &mut [Vec<u8>], fixed: &mut [Vec<bool>], cx: i32, cy: i32, cw: i32) {
    let width = grid.len();
    for i in 0..cw {
        for j in 0..cw {
            let nx = cx + i;
            let ny = cy + j;
            if nx >= 0 && ny >= 0 {
                let nx = nx as usize;
                let ny = ny as usize;
                let height = grid.get(nx).map_or(0, |col| col.len());
                if nx < width && ny < height && grid[nx][ny] != DEF_DEAD {
                    grid[nx][ny] = DEF_ALIVE;
                    fixed[nx][ny] = true;
                }
            }
        }
    }
}
