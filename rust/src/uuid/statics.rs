use byondapi::value::ByondValue;
use std::cell::RefCell;
use std::collections::HashMap;
use uuid::Uuid;

thread_local! {
    pub static UUID_STORAGE: RefCell<HashMap<Uuid, ByondValue>> = RefCell::new(HashMap::new())
}
