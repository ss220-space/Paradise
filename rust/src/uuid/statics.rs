use byondapi::value::ByondValue;
use slotmap::{DefaultKey, SlotMap};
use std::cell::RefCell;

thread_local! {
    pub static UUID_STORAGE: RefCell<SlotMap<DefaultKey, ByondValue>> = RefCell::new(SlotMap::with_capacity(100_000));
}
