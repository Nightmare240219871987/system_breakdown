use std::time::Duration;
use std::thread::sleep;
use sysinfo::{self, System};

pub fn get_all_processes() -> Vec<(i32, String, f32)>  {
    let mut sys = System::new_all();

    sys.refresh_all();
    sleep(Duration::from_millis(200));
    sys.refresh_all();
    
    let processes = sysinfo::System::processes(&sys);
    let mut procs: Vec<(i32, String, f32)> = Vec::new();
    for (pid, process) in processes.iter() {
        procs.push((pid.as_u32() as i32, String::from(process.name().to_str().unwrap()), process.cpu_usage()));
    }
    procs
}