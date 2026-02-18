use crate::ast::{token::Token, value::Value};

/// Represents an expression of a given type
#[derive(Clone)]
pub enum Expr {
    Assign {
        name: Token,
        value: Box<Expr>,
    },

    Binary {
        left: Box<Expr>,
        operator: Token,
        right: Box<Expr>,
    },

    Call {
        callee: Box<Expr>,
        paren: Token,
        args: Vec<Expr>,
    },

    Get {
        object: Box<Expr>,
        property: Token,
    },

    Grouping {
        expression: Box<Expr>,
    },

    Literal {
        value: Value,
    },

    Logical {
        left: Box<Expr>,
        operator: Token,
        right: Box<Expr>,
    },

    Set {
        object: Box<Expr>,
        property: Token,
        value: Box<Expr>,
    },

    Unary {
        operator: Token,
        operand: Box<Expr>,
    },

    Variable {
        name: Token,
    },
}
