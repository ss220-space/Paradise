use super::sun::Sun;
use std::sync::Mutex;

pub static SUN: Mutex<Sun> = Mutex::new(Sun::default());
