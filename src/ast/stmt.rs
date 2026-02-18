use crate::ast::{expr::Expr, token::Token};

pub enum Stmt {
    Print(Box<Expr>),
    Expression(Box<Expr>),
    Var(Token, Option<Box<Expr>>),
}
