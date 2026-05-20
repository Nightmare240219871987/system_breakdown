use hwlocality::{
    object::{attributes::ObjectAttributes, types::ObjectType},
    Topology,
};

use std::thread::sleep;
use std::time::Duration;
use sysinfo::{self, System};

pub fn get_core_usages() -> Vec<f32> {
    let mut sys = System::new_all();
    sys.refresh_cpu_usage();
    sleep(Duration::from_millis(200));
    sys.refresh_cpu_usage();

    let cpus = sysinfo::System::cpus(&sys);
    let mut cpu_usages: Vec<f32> = Vec::new();

    let mut count: f32 = 0.0;
    for c in cpus {
        let usage = c.cpu_usage();
        count += usage;
        cpu_usages.push(usage);
    }

    cpu_usages.insert(0, count / (cpus.len() as f32));
    cpu_usages
}

pub fn get_cpus_speed() -> Vec<u64> {
    let mut sys = sysinfo::System::new_all();
    sys.refresh_cpu_all();
    sleep(Duration::from_millis(200));
    sys.refresh_cpu_all();
    let cpus = sys.cpus();
    let mut freqs: Vec<u64> = Vec::new();
    for c in cpus {
        freqs.push(c.frequency());
    }
    freqs.insert(0, get_cpu_speed(&freqs));
    freqs
}

pub fn get_vendor() -> String {
    let sys = sysinfo::System::new_all();
    String::from(sys.cpus()[0].vendor_id())
}

pub fn get_brand() -> String {
    let sys = sysinfo::System::new_all();
    String::from(sys.cpus()[0].brand())
}

pub fn get_physical_cores() -> usize {
    #[cfg(any(target_arch = "x86", target_arch = "x86_64"))]
    {
        let info = cpu_info::CpuInfo::new();
        let mut physical_cores: usize = 0;
        match info.total_physical_cores {
            Some(c) => physical_cores = c,
            None => (),
        }
        physical_cores
    }

    #[cfg(target_os = "macos")]
    {
        use std::ffi::CString;
        let cname = CString::new("hw.physicalcpu").ok().unwrap();

        let mut value: i32 = 0;
        let mut size = std::mem::size_of::<i32>();

        unsafe {
            libc::sysctlbyname(
                cname.as_ptr(),
                &mut value as *mut i32 as *mut libc::c_void,
                &mut size,
                std::ptr::null_mut(),
                0,
            )
        };

        value as usize
    }
}

pub fn get_threads() -> usize {
    #[cfg(any(target_arch = "x86", target_arch = "x86_64"))]
    {
        let info = cpu_info::CpuInfo::new();
        let mut threads: usize = 0;
        match info.total_logical_cores {
            Some(t) => threads = t,
            None => (),
        }
        threads
    }
    #[cfg(target_os = "macos")]
    {
        use std::ffi::CString;
        let cname = CString::new("hw.logicalcpu").ok().unwrap();

        let mut value: i32 = 0;
        let mut size = std::mem::size_of::<i32>();

        unsafe {
            libc::sysctlbyname(
                cname.as_ptr(),
                &mut value as *mut i32 as *mut libc::c_void,
                &mut size,
                std::ptr::null_mut(),
                0,
            )
        };

        value as usize
    }
}

pub fn get_l1_cache() -> (u64, usize) {
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
    ((size_l1d + size_l1i), count)
}

pub fn get_l2_cache() -> u64 {
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
    l2_cache
}

pub fn get_l3_cache() -> (u64, usize) {
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

    (size, count)
}

pub fn get_hash_acceleration() -> bool {
    #[cfg(any(target_arch = "x86", target_arch = "x86_64"))]
    {
        cpufeatures::new!(cpu_sha, "sha");
        let token: cpu_sha::InitToken = cpu_sha::init();

        if token.get() {
            return true;
        }
    }
    false
}

pub fn get_encryption_acceleration() -> bool {
    cpufeatures::new!(cpu_sha, "aes");
    let token: cpu_sha::InitToken = cpu_sha::init();

    if token.get() {
        return true;
    }
    false
}

pub fn get_sse_extensions() -> String {
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
            return String::from("keine SSE-Unterstützung");
        }

        extensions.join(", ")
    }
    #[cfg(not(any(target_arch = "x86", target_arch = "x86_64")))]
    {
        // ARM, RISC-V etc. haben kein SSE – das ist Intel/AMD-spezifisch
        String::from("nicht verfügbar (nur x86)")
    }
}

fn get_cpu_speed(frequencies: &Vec<u64>) -> u64 {
    let mut count: u64 = 0;
    for f in frequencies {
        count += f;
    }
    count / frequencies.len() as u64
}
