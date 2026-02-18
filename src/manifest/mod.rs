use std::process::ExitCode;

use serde::{Deserialize, Serialize};

use crate::util::log;

const FILE_NAME: &str = "nook.manifest";

/// A Nook project manifest
#[derive(Debug, Deserialize, Serialize)]
pub struct Manifest {
    name: String,
    version: String,
    authors: Vec<String>,
    description: String,
    build_target: String,
}

/// Create a new manifest file with the given name
pub fn create(name: &str) -> ExitCode {
    let manifest = Manifest {
        name: name.to_string(),
        version: "0.1.0".to_string(),
        authors: vec!["".to_string()],
        description: "A Nook project".to_string(),
        build_target: name.to_string(),
    };

    let content = match toml::to_string(&manifest) {
        Ok(content) => content,
        Err(err) => {
            log::error(format!("Failed to serialize manifest: {}", err));
            return ExitCode::FAILURE;
        }
    };

    match std::fs::write(FILE_NAME, content) {
        Ok(()) => return ExitCode::SUCCESS,
        Err(err) => {
            log::error(format!("Failed to write manifest file: {}", err));
            return ExitCode::FAILURE;
        }
    };
}

/// Read the manifest file in the given directory
pub fn read(dir: &str) -> Result<Manifest, String> {
    match std::fs::read_to_string(format!("{}/{}", dir, FILE_NAME)) {
        Ok(content) => match toml::from_str(&content) {
            Ok(manifest) => Ok(manifest),
            Err(err) => Err(format!("Failed to deserialize manifest: {}", err)),
        },
        Err(err) => Err(format!("Failed to read manifest file: {}", err)),
    }
}
