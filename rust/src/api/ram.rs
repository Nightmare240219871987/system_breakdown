use smbioslib::*;

pub struct Ram {
    sys: sysinfo::System,
    pub total_ram: u64,
    pub free_ram: u64,
    pub used_ram: u64,
    pub available_ram: u64,
    pub ram_type: Vec<String>,
    pub ram_speed: Vec<u64>,
    pub ram_speed_configured: Vec<u64>,
    pub ram_band_width: Vec<u64>,
    pub total_swap: u64,
    pub free_swap: u64,
    pub used_swap: u64,
}

impl Ram {
    pub fn new() -> Ram {
        let sys = sysinfo::System::new_all();
        let mut ram = Ram {
            sys: sys,
            available_ram: 0,
            free_ram: 0,
            free_swap: 0,
            total_ram: 0,
            total_swap: 0,
            used_ram: 0,
            used_swap: 0,
            ram_speed: Vec::new(),
            ram_speed_configured: Vec::new(),
            ram_band_width: Vec::new(),
            ram_type: Vec::new(),
        };
        ram.fetch_data();
        ram
    }

    pub fn fetch_data(&mut self) {
        self.sys.refresh_memory();
        self.available_ram = self.sys.available_memory();
        self.free_ram = self.sys.free_memory();
        self.used_ram = self.sys.used_memory();
        self.total_ram = self.sys.total_memory();
        self.total_swap = self.sys.total_swap();
        self.used_swap = self.sys.used_swap();
        self.free_swap = self.sys.free_swap();
        self.ram_speed = self.get_ram_speed_current();
        self.ram_speed_configured = self.get_ram_speed_configured();
        self.ram_band_width = self.get_ram_band_width();
        self.ram_type = self.get_ram_type();
    }

    fn get_ram_speed_current(&mut self) -> Vec<u64> {
        let data_tmp = smbioslib::table_load_from_device();
        let sm_bios_data;
        let mut result: Vec<u64> = Vec::new();
        match data_tmp {
            Ok(data) => sm_bios_data = data,
            Err(_) => return Vec::new(),
        }
        for mem in sm_bios_data.collect::<SMBiosMemoryDevice>() {
            let speed = match mem.speed() {
                Some(MemorySpeed::MTs(v)) => v as u64,
                _ => 0 as u64,
            };
            result.push(speed);
        }
        result
    }

    fn get_ram_speed_configured(&mut self) -> Vec<u64> {
        let data_tmp = smbioslib::table_load_from_device();
        let sm_bios_data;
        let mut result: Vec<u64> = Vec::new();
        match data_tmp {
            Ok(data) => sm_bios_data = data,
            Err(_) => return Vec::new(),
        }
        for mem in sm_bios_data.collect::<SMBiosMemoryDevice>() {
            let speed = match mem.configured_memory_speed() {
                Some(MemorySpeed::MTs(v)) => v as u64,
                _ => 0 as u64,
            };
            result.push(speed);
        }
        result
    }

    fn get_ram_band_width(&mut self) -> Vec<u64> {
        let data_tmp = smbioslib::table_load_from_device();
        let mut result: Vec<u64> = Vec::new();
        let data = match data_tmp {
            Ok(v) => v,
            _ => return Vec::new(),
        };
        for mem in data.collect::<SMBiosMemoryDevice>() {
            let data_width = match mem.data_width() {
                Some(v) => v as u64,
                None => 0 as u64,
            };
            if data_width == 0xFFFF {
                result.push(0); // Unbekannt oder nicht belegt
            } else {
                result.push(data_width);
            }
        }
        result
    }

    fn get_ram_type(&mut self) -> Vec<String> {
        let data_tmp = smbioslib::table_load_from_device();
        let mut result: Vec<String> = Vec::new();
        let data = match data_tmp {
            Ok(v) => v,
            _ => return Vec::new(),
        };
        for mem in data.collect::<SMBiosMemoryDevice>() {
            let mem_type = match mem.memory_type() {
                Some(t) => format!("{:#?}", t.value),
                None => "Unknown".to_string(),
            };
            result.push(mem_type.to_uppercase())
        }
        result
    }
}
