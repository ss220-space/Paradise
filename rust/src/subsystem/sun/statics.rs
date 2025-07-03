use super::sun::Sun;
use std::cell::Cell;
use std::cell::RefCell;
use std::collections::HashMap;

thread_local! {
    pub static SUN: Sun = Sun {
            rate: Cell::new(0.0),
            dx: Cell::new(0.0),
            dy: Cell::new(0.0),
            angle: Cell::new(0.0),
            solars: RefCell::new(HashMap::new())
        }
}
