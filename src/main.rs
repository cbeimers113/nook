mod ast;
mod compiler;
mod manifest;
mod util;

use std::process::ExitCode;

use clap::{Parser, Subcommand};

/// Main CLI representation
#[derive(Parser, Debug)]
#[command(version = env!("NOOK_FULL_VERSION"), about, author)]
struct Cli {
    #[arg(long, short, global = true)]
    verbose: Option<bool>,

    #[command(subcommand)]
    command: Commands,
}

/// CLI subcommand representation
#[derive(Subcommand, Debug)]
enum Commands {
    // Manifest Management
    // --------------------------
    /// Create a new Nook project
    Init {
        /// Name of the project
        name: String,
    },

    // Build Tools
    // ---------------------------------
    /// Parse a Nook project into an AST
    Parse {
        // Directory containing Nook manifest
        manifest_dir: Option<String>,
    },

    /// Build a Nook project
    Build {
        /// Directory containing Nook manifest
        manifest_dir: Option<String>,
    },
}

fn main() -> ExitCode {
    let cli = Cli::parse();

    match &cli.command {
        Commands::Init { name } => manifest::create(name),
        Commands::Parse { manifest_dir } => {
            ast::display(manifest_dir.clone().unwrap_or(".".to_string()).as_str())
        }
        Commands::Build { manifest_dir } => {
            compiler::compile(manifest_dir.clone().unwrap_or(".".to_string()).as_str())
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_main() {
        // TODO: Write tests
        assert_eq!(main(), ExitCode::SUCCESS);
    }
}
