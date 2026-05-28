use hwlocality::{
    object::{attributes::ObjectAttributes, types::ObjectType},
    Topology,
};
#[cfg(target_os = "macos")]
use std::ffi::CString;

use sysinfo::{self};

#[derive(Debug)]
pub struct Cpu {
    system: sysinfo::System,
    cpu_info: cpu_info::CpuInfo,
    pub total_cpu_usage: f32,
    pub total_cpu_speed: u64,
    pub core_usages: Vec<f32>, // index 0 -> Core 0 ...
    pub core_speeds: Vec<u64>, // index 0 -> Core 0 ...
    pub cpu_vendor: String,
    pub cpu_brand: String,
    pub cpu_cores: usize,
    pub cpu_threads: usize,
    pub aes_support: bool,
    pub sha256_support: bool,
    pub sse_features: String, // gibt einen String mit SSE Features zurück
    pub l1_cache: u64,
    pub l2_cache: u64,
    pub l3_cache: u64,
}

impl Cpu {
    pub fn new() -> Cpu {
        let system = sysinfo::System::new_all();
        let mut cpu = Cpu {
            system: system,
            cpu_info: cpu_info::CpuInfo::new(),
            aes_support: false,
            core_speeds: Vec::new(),
            core_usages: Vec::new(),
            cpu_brand: "".to_string(),
            cpu_cores: 0,
            cpu_threads: 0,
            cpu_vendor: "".to_string(),
            l1_cache: 0,
            l2_cache: 0,
            l3_cache: 0,
            sha256_support: false,
            sse_features: "".to_string(),
            total_cpu_usage: 0.0,
            total_cpu_speed: 0,
        };
        cpu.system.refresh_cpu_all();
        cpu.get_brand();
        cpu.get_vendor();
        cpu.get_cores_and_threads();
        cpu.get_hash_acceleration();
        cpu.get_encryption_acceleration();
        cpu.get_cores_and_threads();
        cpu.get_l1_cache();
        cpu.get_l2_cache();
        cpu.get_l3_cache();
        cpu.get_sse_extensions();
        cpu
    }

    fn get_vendor(&mut self) {
        self.cpu_vendor = self.system.cpus()[0].vendor_id().to_string();
    }

    fn get_brand(&mut self) {
        self.cpu_brand = self.system.cpus()[0].brand().to_string();
    }

    pub fn fetch_data(&mut self) -> &Cpu {
        self.system.refresh_cpu_all();
        self.get_core_usages();
        self.get_cpu_speeds();
        self.get_total_cpu_usage();
        self.get_total_cpu_speed();
        self
    }

    fn get_cores_and_threads(&mut self) {
        #[cfg(any(target_arch = "x86", target_arch = "x86_64"))]
        {
            self.cpu_info = cpu_info::CpuInfo::new();
            self.cpu_cores = self.cpu_info.total_physical_cores.unwrap_or(0);
            self.cpu_threads = self.cpu_info.total_logical_cores.unwrap_or(0);
        }
        #[cfg(target_os = "macos")]
        {
            let cname_physical = CString::new("hw.physicalcpu").ok().unwrap();
            let cname_logical = CString::new("hw.logicalcpu").ok().unwrap();

            let mut value_physical: i32 = 0;
            let mut value_logical: i32 = 0;
            let mut size_physical = std::mem::size_of::<i32>();
            let mut size_logical = std::mem::size_of::<i32>();

            unsafe {
                libc::sysctlbyname(
                    cname_physical.as_ptr(),
                    &mut value_physical as *mut i32 as *mut libc::c_void,
                    &mut size_physical,
                    std::ptr::null_mut(),
                    0,
                )
            };
            unsafe {
                libc::sysctlbyname(
                    cname_logical.as_ptr(),
                    &mut value_logical as *mut i32 as *mut libc::c_void,
                    &mut size_logical,
                    std::ptr::null_mut(),
                    0,
                )
            };
            self.cpu_cores = value_physical as u64;
            self.cpu_threads = value_logical as u64;
        }
    }

    fn get_hash_acceleration(&mut self) {
        #[cfg(any(target_arch = "x86", target_arch = "x86_64"))]
        {
            cpufeatures::new!(cpu_sha, "sha");
            let token: cpu_sha::InitToken = cpu_sha::init();

            if token.get() {
                self.sha256_support = true;
                return;
            }
        }
        self.sha256_support = false;
    }

    fn get_encryption_acceleration(&mut self) {
        cpufeatures::new!(cpu_sha, "aes");
        let token: cpu_sha::InitToken = cpu_sha::init();

        if token.get() {
            self.aes_support = true;
            return;
        }
        self.aes_support = false;
    }

    fn get_sse_extensions(&mut self) {
        #[cfg(any(target_arch = "x86", target_arch = "x86_64"))]
        {
            cpufeatures::new!(cpu_sse, "sse");
            cpufeatures::new!(cpu_sse2, "sse2");
            cpufeatures::new!(cpu_sse3, "sse3");
            cpufeatures::new!(cpu_ssse3, "ssse3");
            cpufeatures::new!(cpu_sse41, "sse4.1");
            cpufeatures::new!(cpu_sse42, "sse4.2");

            let mut extensions: Vec<&str> = Vec::new();

            if cpu_sse::init().get() {
                extensions.push("SSE");
            }
            if cpu_sse2::init().get() {
                extensions.push("SSE2");
            }
            if cpu_sse3::init().get() {
                extensions.push("SSE3");
            }
            if cpu_ssse3::init().get() {
                extensions.push("SSSE3");
            }
            if cpu_sse41::init().get() {
                extensions.push("SSE4.1");
            }
            if cpu_sse42::init().get() {
                extensions.push("SSE4.2");
            }

            if extensions.is_empty() {
                self.sse_features = String::from("keine SSE-Unterstützung");
            }

            self.sse_features = extensions.join(", ");
        }
        #[cfg(not(any(target_arch = "x86", target_arch = "x86_64")))]
        {
            // ARM, RISC-V etc. haben kein SSE – das ist Intel/AMD-spezifisch
            self.sse_features = String::from("nicht verfügbar (nur x86)")
        }
    }

    fn get_l1_cache(&mut self) {
        let topo = Topology::builder()
            .with_type_filter(
                ObjectType::Die,
                hwlocality::topology::builder::TypeFilter::KeepAll,
            )
            .unwrap()
            .with_type_filter(
                ObjectType::L1ICache,
                hwlocality::topology::builder::TypeFilter::KeepAll,
            )
            .unwrap()
            .build()
            .unwrap();

        let l1i: Vec<&hwlocality::object::TopologyObject> =
            topo.objects_with_type(ObjectType::L1ICache).collect();
        let l1d: Vec<&hwlocality::object::TopologyObject> =
            topo.objects_with_type(ObjectType::L1Cache).collect();
        let count = l1d.len();

        let size_l1d = l1d
            .first()
            .and_then(|o| o.attributes())
            .and_then(|a| {
                if let ObjectAttributes::Cache(c) = a {
                    c.size().map(|s| s.get())
                } else {
                    None
                }
            })
            .unwrap_or(0);

        let size_l1i = l1i
            .first()
            .and_then(|o| o.attributes())
            .and_then(|a| {
                if let ObjectAttributes::Cache(c) = a {
                    c.size().map(|s| s.get())
                } else {
                    None
                }
            })
            .unwrap_or(0);
        self.l1_cache = (size_l1d + size_l1i) * count as u64;
    }

    fn get_l2_cache(&mut self) {
        let topo = Topology::new();
        let mut l2_cache: u64 = 0;
        match topo {
            Ok(t) => {
                for (_, obj) in t.objects_with_type(ObjectType::L2Cache).enumerate() {
                    if let Some(ObjectAttributes::Cache(attr)) = obj.attributes() {
                        let temp = attr.size().unwrap();
                        l2_cache += temp.get();
                    }
                }
            }
            Err(e) => println!("Fehler : {}", e),
        }
        self.l2_cache = l2_cache;
    }

    fn get_l3_cache(&mut self) {
        let topo = Topology::new().unwrap();
        let caches: Vec<&hwlocality::object::TopologyObject> =
            topo.objects_with_type(ObjectType::L3Cache).collect();
        let count = caches.len();

        let size = caches
            .first()
            .and_then(|o| o.attributes())
            .and_then(|a| {
                if let ObjectAttributes::Cache(c) = a {
                    c.size().map(|s| s.get())
                } else {
                    None
                }
            })
            .unwrap_or(0);

        self.l3_cache = size * count as u64;
    }

    fn get_cpu_speeds(&mut self) {
        let cpus = self.system.cpus();
        let mut freqs: Vec<u64> = Vec::new();
        for c in cpus {
            freqs.push(c.frequency());
        }
        self.core_speeds = freqs;
    }

    fn get_core_usages(&mut self) {
        let cpus = sysinfo::System::cpus(&self.system);
        let mut cpu_usages: Vec<f32> = Vec::new();

        for c in cpus {
            let usage = c.cpu_usage();
            cpu_usages.push(usage);
        }
        self.core_usages = cpu_usages;
    }

    fn get_total_cpu_usage(&mut self) {
        let mut count: f32 = 0.0;
        for f in &self.core_usages {
            count += f;
        }
        self.total_cpu_usage = count / self.core_usages.len() as f32;
    }

    fn get_total_cpu_speed(&mut self) {
        let mut count: u64 = 0;
        for s in &self.core_speeds {
            count += s;
        }
        self.total_cpu_speed = count / self.core_speeds.len() as u64;
    }
}
