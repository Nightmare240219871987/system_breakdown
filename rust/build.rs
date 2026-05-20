fn main() {
    #[cfg(target_os = "macos")]
    {
        // Homebrew Pfad für Apple Silicon
        println!("cargo:rustc-link-search=native=/opt/homebrew/lib");

        // macOS Frameworks
        println!("cargo:rustc-link-lib=framework=OpenDirectory");
        println!("cargo:rustc-link-lib=framework=CoreFoundation");
        println!("cargo:rustc-link-lib=framework=IOKit");

        // hwloc explizit linken
        println!("cargo:rustc-link-lib=hwloc");
    }
}
