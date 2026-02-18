use std::fs;

fn main() {
    // Rebuild if the file changes
    println!("cargo:rerun-if-changed=build.json");

    // Read Cargo version (language spec)
    let base_version = std::env::var("CARGO_PKG_VERSION").unwrap();

    // Read build metadata file
    let json = fs::read_to_string("build.json").expect("Failed to read build.json");
    let value: serde_json::Value = serde_json::from_str(&json).expect("Invalid build.json");

    let kind = value["kind"].as_str().unwrap_or("build");
    let number = value["number"].as_i64().unwrap_or(0);
    let git_hash = std::process::Command::new("git")
        .args(["rev-parse", "--short", "HEAD"])
        .output()
        .ok()
        .and_then(|o| String::from_utf8(o.stdout).ok())
        .unwrap_or_default();

    // Export full build verison number to the compiled binary
    println!(
        "cargo:rustc-env=NOOK_FULL_VERSION={}",
        format!("v{}+{}{}.{}", base_version, kind, number, git_hash.trim())
    );
}
