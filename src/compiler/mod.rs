use std::process::ExitCode;

use crate::util::log;

pub fn compile(manifest_dir: &str) -> ExitCode {
    log::debug(format!("Compile {} (TODO)", manifest_dir));
    ExitCode::SUCCESS
}
