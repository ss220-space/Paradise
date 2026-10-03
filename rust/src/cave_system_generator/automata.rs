use rayon::iter::{IntoParallelIterator, ParallelIterator};
use std::collections::VecDeque;

use super::{ALIVE, DEAD, DEF_ALIVE, DEF_DEAD};

pub(super) fn ca_step(
    grid: &mut Vec<Vec<u8>>,
    width: usize,
    height: usize,
    birth_limit: usize,
    survival_limit: usize,
    edge_is_alive: bool,
) {
    let grid_ref: &Vec<Vec<u8>> = grid;
    let new_grid: Vec<Vec<u8>> = (0..width)
        .into_par_iter()
        .map(|x| {
            (0..height)
                .map(|y| {
                    let cell = grid_ref[x][y];
                    if cell == DEF_ALIVE || cell == DEF_DEAD {
                        return cell;
                    }
                    let count =
                        count_alive_neighbors(grid_ref, x, y, width, height, edge_is_alive);
                    if cell == ALIVE {
                        if count >= survival_limit {
                            ALIVE
                        } else {
                            DEAD
                        }
                    } else if count >= birth_limit {
                        ALIVE
                    } else {
                        DEAD
                    }
                })
                .collect()
        })
        .collect();
    *grid = new_grid;
}

fn count_alive_neighbors(
    grid: &[Vec<u8>],
    x: usize,
    y: usize,
    width: usize,
    height: usize,
    edge_is_alive: bool,
) -> usize {
    let mut count = 0;
    for dx in -1i32..=1 {
        for dy in -1i32..=1 {
            if dx == 0 && dy == 0 {
                continue;
            }
            let nx = x as i32 + dx;
            let ny = y as i32 + dy;
            if nx >= 0 && nx < width as i32 && ny >= 0 && ny < height as i32 {
                let neighbor = grid[nx as usize][ny as usize];
                if neighbor == ALIVE || neighbor == DEF_ALIVE {
                    count += 1;
                }
            } else if edge_is_alive {
                count += 1;
            }
        }
    }
    count
}

pub(super) fn flood_fill_island_removal(
    grid: &mut [Vec<u8>],
    width: usize,
    height: usize,
    start: (usize, usize),
) {
    let (sx, sy) = start;
    if sx >= width || sy >= height {
        return;
    }

    let mut visited = vec![vec![false; height]; width];
    let mut queue: VecDeque<(usize, usize)> = VecDeque::new();
    visited[sx][sy] = true;
    queue.push_back((sx, sy));

    while let Some((cx, cy)) = queue.pop_front() {
        for (ddx, ddy) in [(0i32, 1i32), (0, -1), (1, 0), (-1, 0)] {
            let nx = cx as i32 + ddx;
            let ny = cy as i32 + ddy;
            if nx >= 0 && nx < width as i32 && ny >= 0 && ny < height as i32 {
                let nx = nx as usize;
                let ny = ny as usize;
                if !visited[nx][ny] && grid[nx][ny] != DEAD {
                    visited[nx][ny] = true;
                    queue.push_back((nx, ny));
                }
            }
        }
    }

    let mut component_visited = vec![vec![false; height]; width];
    for x in 0..width {
        for y in 0..height {
            if visited[x][y] || component_visited[x][y] {
                continue;
            }
            let cell = grid[x][y];
            if cell != ALIVE && cell != DEF_ALIVE {
                continue;
            }
            let mut alive_cells: Vec<(usize, usize)> = Vec::new();
            let mut has_def_alive = false;
            let mut comp_queue: VecDeque<(usize, usize)> = VecDeque::new();
            component_visited[x][y] = true;
            comp_queue.push_back((x, y));
            while let Some((cx, cy)) = comp_queue.pop_front() {
                match grid[cx][cy] {
                    DEF_ALIVE => has_def_alive = true,
                    ALIVE => alive_cells.push((cx, cy)),
                    _ => {}
                }
                for (ddx, ddy) in [(0i32, 1i32), (0, -1), (1, 0), (-1, 0)] {
                    let nx = cx as i32 + ddx;
                    let ny = cy as i32 + ddy;
                    if nx >= 0 && nx < width as i32 && ny >= 0 && ny < height as i32 {
                        let nx = nx as usize;
                        let ny = ny as usize;
                        if !visited[nx][ny]
                            && !component_visited[nx][ny]
                            && (grid[nx][ny] == ALIVE || grid[nx][ny] == DEF_ALIVE)
                        {
                            component_visited[nx][ny] = true;
                            comp_queue.push_back((nx, ny));
                        }
                    }
                }
            }
            if !has_def_alive {
                for (ax, ay) in alive_cells {
                    grid[ax][ay] = DEAD;
                }
            }
        }
    }
}
