
pub fn get_total_ram() -> u64 {
    let mut sys = sysinfo::System::new_all();
    sys.refresh_memory();
    sys.total_memory()
}

pub fn get_free_ram() -> u64 {
    let mut sys =  sysinfo::System::new_all();
    sys.refresh_memory();
    sys.free_memory()
}

pub fn get_available_ram() -> u64 {
    let mut sys = sysinfo::System::new_all();
    sys.refresh_memory();
    sys.available_memory()
}

pub fn get_used_memory() -> u64 {
    let mut sys = sysinfo::System::new_all();
    sys.refresh_memory();
    sys.used_memory()
}

pub fn get_total_swap() -> u64 {
    let mut sys = sysinfo::System::new_all();
    sys.refresh_memory();
    sys.total_swap()
}

pub fn get_free_swap() -> u64 {
    let mut sys = sysinfo::System::new_all();
    sys.refresh_memory();
    sys.free_swap()
}

pub fn get_used_swap() -> u64 {
    let mut sys = sysinfo::System::new_all();
    sys.refresh_memory();
    sys.used_swap()
}