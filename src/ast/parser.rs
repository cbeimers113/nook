use crate::{
    ast::{
        expr::Expr,
        stmt::Stmt,
        token::{Token, TokenType},
        value::Value,
    },
    util::log,
};

/// Convert a vector of tokens into an abstract syntax tree.
/// If there was an error, return an error message instead
pub fn parse(tokens: Vec<Token>) -> Result<Vec<Box<Stmt>>, String> {
    let mut parser = Parser::new(tokens);
    parser.parse()
}

/// Parses a token stream into an AST
struct Parser {
    tokens: Vec<Token>, // input token stream
    pos: usize,         // current scan position
}

impl Parser {
    /// Create a new Parser
    fn new(tokens: Vec<Token>) -> Self {
        let parser = Parser {
            tokens: tokens,
            pos: 0,
        };

        parser
    }

    fn parse(&mut self) -> Result<Vec<Box<Stmt>>, String> {
        let mut statements = Vec::new();

        while !self.done() {
            match self.declaration() {
                Some(stmt) => statements.push(stmt),
                None => continue,
            }
        }

        Ok(statements)
    }

    // Statement parsing rules
    // ------------------------

    fn declaration(&mut self) -> Option<Box<Stmt>> {
        let res: Result<Box<Stmt>, String>;
        if self.matches(&vec![TokenType::Var]) {
            res = self.var_declaration();
        } else {
            res = self.statement();
        }

        match res {
            Ok(stmt) => return Some(stmt),
            Err(err) => {
                log::error(err);
                self.synchronize();
                return None;
            }
        }
    }

    fn var_declaration(&mut self) -> Result<Box<Stmt>, String> {
        let name = self.consume(&TokenType::Identifier, "Expect variable name")?;
        let mut value: Option<Box<Expr>> = None;
        if self.matches(&vec![TokenType::Equals]) {
            value = Some(self.expression()?);
        }

        self.consume(
            &TokenType::Semicolon,
            "Expect ';' after variable declaration",
        )?;
        Ok(Box::new(Stmt::Var(name, value)))
    }

    fn statement(&mut self) -> Result<Box<Stmt>, String> {
        if self.matches(&vec![TokenType::Print]) {
            return self.print_statement();
        }

        self.expression_statement()
    }

    fn print_statement(&mut self) -> Result<Box<Stmt>, String> {
        let expr = self.expression()?;
        self.consume(&TokenType::Semicolon, "Expect ';' after expression")?;
        Ok(Box::new(Stmt::Print(expr)))
    }

    fn expression_statement(&mut self) -> Result<Box<Stmt>, String> {
        let expr = self.expression()?;
        self.consume(&TokenType::Semicolon, "Expect ';' after expression")?;
        Ok(Box::new(Stmt::Expression(expr)))
    }

    // Expression parsing rules
    // ------------------------

    /// The expression rule; lowest precedence, satisfied by `equality`
    fn expression(&mut self) -> Result<Box<Expr>, String> {
        self.equality()
    }

    /// The equality rule; satisfied by `comparison (( "!=" | "==" ) comparison )*`
    fn equality(&mut self) -> Result<Box<Expr>, String> {
        let mut expr = self.comparison()?;

        while self.matches(&vec![TokenType::BangEquals, TokenType::EqualsEquals]) {
            let operator = self.previous();
            let right = self.comparison()?;
            expr = Box::new(Expr::Binary {
                left: expr,
                operator: operator,
                right: right,
            });
        }

        Ok(expr)
    }

    /// The comparison rule; satisfied by `term (( ">" | ">=" | "<" | "<=" ) term )*`
    fn comparison(&mut self) -> Result<Box<Expr>, String> {
        let mut expr = self.term()?;

        while self.matches(&vec![
            TokenType::RightAngle,
            TokenType::GreaterOrEquals,
            TokenType::LeftAngle,
            TokenType::LessOrEquals,
        ]) {
            let operator = self.previous();
            let right = self.term()?;
            expr = Box::new(Expr::Binary {
                left: expr,
                operator: operator,
                right: right,
            });
        }

        Ok(expr)
    }

    /// The term rule; satisfied by `factor (( "-" | "+" ) factor )*`
    fn term(&mut self) -> Result<Box<Expr>, String> {
        let mut expr = self.factor()?;

        while self.matches(&vec![TokenType::Minus, TokenType::Plus]) {
            let operator = self.previous();
            let right = self.factor()?;
            expr = Box::new(Expr::Binary {
                left: expr,
                operator: operator,
                right: right,
            });
        }

        Ok(expr)
    }

    /// The factor rule; satisfied by `unary (( "/" | "*" ) unary )*`
    fn factor(&mut self) -> Result<Box<Expr>, String> {
        let mut expr = self.unary()?;

        while self.matches(&vec![TokenType::Slash, TokenType::Star]) {
            let operator = self.previous();
            let right = self.unary()?;
            expr = Box::new(Expr::Binary {
                left: expr,
                operator: operator,
                right: right,
            })
        }

        Ok(expr)
    }

    /// The unary rule; satisfied by `("!" | "-") unary | primary`
    fn unary(&mut self) -> Result<Box<Expr>, String> {
        if self.matches(&vec![TokenType::Bang, TokenType::Minus]) {
            let operator = self.previous();
            let right = self.unary()?;
            return Ok(Box::new(Expr::Unary {
                operator: operator,
                operand: right,
            }));
        }

        self.primary()
    }

    /// The primary rule; satisfied by `NUMBER | STRING | "true" | "false" | "nil" | "(" expr ")" | IDENTIFIER`
    fn primary(&mut self) -> Result<Box<Expr>, String> {
        // Number
        if self.matches(&vec![TokenType::Int]) {
            return Ok(Box::new(Expr::Literal {
                value: Value::Integer(self.previous().value.parse::<i64>().unwrap()),
            }));
        }
        if self.matches(&vec![TokenType::Float]) {
            return Ok(Box::new(Expr::Literal {
                value: Value::Float(self.previous().value.parse::<f64>().unwrap()),
            }));
        }

        // Text
        if self.matches(&vec![TokenType::Char]) {
            return Ok(Box::new(Expr::Literal {
                value: Value::Char(self.previous().value.chars().nth(0).unwrap()),
            }));
        }
        if self.matches(&vec![TokenType::String]) {
            return Ok(Box::new(Expr::Literal {
                value: Value::String(self.previous().value),
            }));
        }

        // Bool
        if self.matches(&vec![TokenType::True]) {
            return Ok(Box::new(Expr::Literal {
                value: Value::Bool(true),
            }));
        }
        if self.matches(&vec![TokenType::False]) {
            return Ok(Box::new(Expr::Literal {
                value: Value::Bool(false),
            }));
        }

        // Identifier
        if self.matches(&vec![TokenType::Identifier]) {
            return Ok(Box::new(Expr::Variable {
                name: self.previous(),
            }));
        }

        // Expression grouping
        if self.matches(&vec![TokenType::LeftParen]) {
            let expr = self.expression()?;
            self.consume(&TokenType::RightParen, "Expect ')' after expression")?;
            return Ok(Box::new(Expr::Grouping { expression: expr }));
        }

        Err(format!("Expect expression, found {}", self.peek()))
    }

    // Parsing utils
    // -------------

    /// Synchronize on the next expression boundary when errors are found
    fn synchronize(&mut self) {
        self.advance();

        while !self.done() {
            if self.previous().token_type == TokenType::Semicolon {
                return;
            }

            match self.peek().token_type {
                TokenType::Struct
                | TokenType::Static
                | TokenType::Dyn
                | TokenType::Mtd
                | TokenType::Var
                | TokenType::Loop
                | TokenType::If
                | TokenType::Else
                | TokenType::Eval
                | TokenType::Continue
                | TokenType::Break
                | TokenType::Return => return,
                _ => {
                    self.advance();
                }
            }
        }
    }

    /// Check if the current token is of the given type and consume it if it is, but emit an error if it isn't
    fn consume(&mut self, token_type: &TokenType, error_message: &str) -> Result<Token, String> {
        if self.check(token_type) {
            return Ok(self.advance());
        }

        Err(format!("{}; {}", error_message, self.peek()))
    }

    /// Check if the current token is of any of the given types and consume it if it is
    fn matches(&mut self, token_types: &[TokenType]) -> bool {
        for token_type in token_types {
            if self.check(token_type) {
                self.advance();
                return true;
            }
        }

        false
    }

    /// Check if the current token is of the given type
    fn check(&self, token_type: &TokenType) -> bool {
        if self.done() {
            return false;
        }

        self.peek().token_type == *token_type
    }

    /// Advance the parser to the next token
    fn advance(&mut self) -> Token {
        if !self.done() {
            self.pos += 1;
        }

        self.previous()
    }

    /// Check if the parser has reached the end of the token stream
    fn done(&self) -> bool {
        self.peek().token_type == TokenType::EOF
    }

    /// Yields the current token
    fn peek(&self) -> Token {
        self.tokens[self.pos].clone()
    }

    /// Yields the previous token
    fn previous(&self) -> Token {
        self.tokens[self.pos - 1].clone()
    }
}
