use std::sync::atomic::{AtomicBool, Ordering};

use colored::{ColoredString, Colorize};

static VERBOSE: AtomicBool = AtomicBool::new(false);

/// Set the verbose flag for logging
pub fn set_verbose(verbose: bool) {
    VERBOSE.store(verbose, Ordering::Relaxed);
}

/// Get the verbose flag
fn verbose() -> bool {
    VERBOSE.load(Ordering::Relaxed)
}

/// Utility logging function
fn log(msg: ColoredString, is_error: bool) {
    if is_error {
        eprintln!("{}", msg);
    } else {
        println!("{}", msg);
    }
}

/// Log a message to stdout
pub fn info(msg: String) {
    log(msg.green(), false);
}

/// Log a message to stdout, only emitted when verbose mode is enabled
pub fn debug(msg: String) {
    if !verbose() {
        return;
    }

    log(msg.blue(), false);
}

/// Log a message to stderr
pub fn error(msg: String) {
    log(msg.red(), true);
}
