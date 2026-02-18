mod expr;
mod lexer;
mod parser;
mod print;
mod stmt;
mod token;
mod value;

use std::{fs, process::ExitCode};

use crate::{ast::stmt::Stmt, util::log};

/// Produces and pretty-prints an AST from input source code
pub fn display(manifest_dir: &str) -> ExitCode {
    let ast = match generate(manifest_dir) {
        Ok(ast) => ast,
        Err(e) => {
            log::error(e);
            return ExitCode::FAILURE;
        }
    };

    print::print_stmt_tree(&ast);
    ExitCode::SUCCESS
}

/// Parses input source code into an AST
pub fn generate(manifest_dir: &str) -> Result<Vec<Box<Stmt>>, String> {
    // Find and read main.nk
    let main_file = format!("{}/main.nk", manifest_dir);
    let source_code = match fs::read_to_string(main_file) {
        Ok(source_code) => source_code,
        Err(e) => {
            return Err(format!("Error reading main.nk: {}", e));
        }
    };

    let tokens = match lexer::scan(&source_code) {
        Ok(tokens) => tokens,
        Err(e) => {
            return Err(format!("Error scanning source code: {}", e));
        }
    };

    let ast = match parser::parse(tokens) {
        Ok(ast) => ast,
        Err(e) => {
            return Err(format!("Error parsing tokens: {}", e));
        }
    };

    Ok(ast)
}
