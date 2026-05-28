use sysinfo::{self};

pub struct Processes {
    system: sysinfo::System,
}

pub struct Process {
    pub name: String,
    pub usage: f32,
    pub pid: u32,
    pub memory: u64,
}

impl Processes {
    pub fn new() -> Processes {
        let mut system = sysinfo::System::new_all();
        system.refresh_processes(sysinfo::ProcessesToUpdate::All, true);
        let handle: Processes = Processes { system: system };
        handle
    }

    pub fn get_all_processes(&mut self) -> Vec<Process> {
        self.system
            .refresh_processes(sysinfo::ProcessesToUpdate::All, true);
        let processes = self.system.processes();
        let mut procs = Vec::new();
        for (pid, process) in processes.iter() {
            let name_match = process.name().to_str();
            let mut name = "";
            match name_match {
                Some(s) => name = s,
                None => (),
            }
            procs.push(Process {
                name: name.to_string(),
                usage: process.cpu_usage(),
                pid: pid.as_u32(),
                memory: process.memory(),
            });
        }
        procs
    }
}
