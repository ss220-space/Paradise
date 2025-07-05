use byondapi::value::ByondValue;
use std::cell::Cell;
use std::cell::RefCell;
use std::collections::HashMap;

thread_local! {
    pub static UUID_COUNTER: Cell<u32> = Cell::new(0);
    pub static UUID_STORAGE: RefCell<HashMap<u32, ByondValue>> = RefCell::new(HashMap::new());
}
