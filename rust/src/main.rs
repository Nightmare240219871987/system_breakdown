use crate::api::cpu::get_l1_cache;

pub mod api;

fn main() {
    let (size, count) = get_l1_cache();
    println!("L1 size: {} KiB, count: {}", size / 1024, count );     
}