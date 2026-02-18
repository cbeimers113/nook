use std::fmt;

use colored::Colorize;

/// Represents all the different types of tokens in the source code
#[derive(strum_macros::Display, PartialEq, Clone, Debug)]
pub enum TokenType {
    // Single-char tokens
    Hash,         // #
    Dollar,       // $
    LeftParen,    // (
    RightParen,   // )
    LeftBracket,  // [
    RightBracket, // ]
    LeftBrace,    // {
    RightBrace,   // }
    Comma,        // ,
    Question,     // ?
    Underscore,   // _
    Semicolon,    // ;
    Dot,          // .

    // Single or double-char tokens by initial char
    Bang,          // !
    BangEquals,    // !=
    Percent,       // %
    PercentEquals, // %=
    And,           // &
    AndAnd,        // &&
    AndEquals,     // &=
    Star,          // *
    StarEquals,    // *=
    Plus,          // +
    PlusEquals,    // +=
    Minus,         // -
    MinusEquals,   // -=
    RightArrow,    // ->
    Slash,         // /
    SlashEquals,   // /=
    Comment,       // //
    Colon,         // :
    ColonColon,    // ::
    Equals,        // =
    EqualsEquals,  // ==
    Caret,         // ^
    CaretEquals,   // ^=
    Pipe,          // |
    PipeEquals,    // |=
    PipePipe,      // ||
    Tilde,         // ~
    TildeEquals,   // ~=

    // Single, double, or triple-char tokens by initial char
    LeftAngle,        // <
    LeftShift,        // <<
    LessOrEquals,     // <=
    LeftShiftEquals,  // <<=
    RightAngle,       // >
    GreaterOrEquals,  // >=
    RightShift,       // >>
    RightShiftEquals, // >>=

    // Literals
    Identifier, // begins with a-zA-Z
    String,     // begins with "
    Char,       // begins with '
    Int,        // sequence of only 0-9
    Float,      // sequence of only 0-9 and exactly 1 non-initial, non-final .
    True,       // literal 'true'
    False,      // literal 'false'
    Nil,        // literal 'nil'
    None,       // literal 'none'

    // Keywords
    // Flow control
    If,
    Else,
    Eval,
    Loop,
    Return,
    Continue,
    Break,

    // Declarations
    Pkg,
    Struct,
    Var,
    Const,
    Static,
    Dyn,
    Mtd,
    Own,
    Ref,

    // Builtins
    New,
    Drop,
    Copy,
    Clone,
    Print,

    // Other
    EOF, // end of file
}

/// Returns the matching TokenType for a string representation of an operator, if applicable
pub fn parse_op(op: &str) -> Option<TokenType> {
    match op {
        // Single char
        "#" => Some(TokenType::Hash),
        "$" => Some(TokenType::Dollar),
        "(" => Some(TokenType::LeftParen),
        ")" => Some(TokenType::RightParen),
        "[" => Some(TokenType::LeftBracket),
        "]" => Some(TokenType::RightBracket),
        "{" => Some(TokenType::LeftBrace),
        "}" => Some(TokenType::RightBrace),
        "," => Some(TokenType::Comma),
        "?" => Some(TokenType::Question),
        "_" => Some(TokenType::Underscore),
        ";" => Some(TokenType::Semicolon),
        "." => Some(TokenType::Dot),

        // Single and double-char
        "~=" => Some(TokenType::TildeEquals),
        "~" => Some(TokenType::Tilde),
        "|=" => Some(TokenType::PipeEquals),
        "||" => Some(TokenType::PipePipe),
        "|" => Some(TokenType::Pipe),
        "^=" => Some(TokenType::CaretEquals),
        "^" => Some(TokenType::Caret),
        "==" => Some(TokenType::EqualsEquals),
        "=" => Some(TokenType::Equals),
        "::" => Some(TokenType::ColonColon),
        ":" => Some(TokenType::Colon),
        "/=" => Some(TokenType::SlashEquals),
        "/" => Some(TokenType::Slash),
        "//" => Some(TokenType::Comment),
        "->" => Some(TokenType::RightArrow),
        "-=" => Some(TokenType::MinusEquals),
        "-" => Some(TokenType::Minus),
        "+=" => Some(TokenType::PlusEquals),
        "+" => Some(TokenType::Plus),
        "*=" => Some(TokenType::StarEquals),
        "*" => Some(TokenType::Star),
        "&=" => Some(TokenType::AndEquals),
        "&&" => Some(TokenType::AndAnd),
        "&" => Some(TokenType::And),
        "%=" => Some(TokenType::PercentEquals),
        "%" => Some(TokenType::Percent),
        "!=" => Some(TokenType::BangEquals),
        "!" => Some(TokenType::Bang),

        // Single, double and triple-char
        "<<=" => Some(TokenType::LeftShiftEquals),
        "<<" => Some(TokenType::LeftShift),
        "<=" => Some(TokenType::LessOrEquals),
        "<" => Some(TokenType::LeftAngle),
        ">>=" => Some(TokenType::RightShiftEquals),
        ">>" => Some(TokenType::RightShift),
        ">=" => Some(TokenType::GreaterOrEquals),
        ">" => Some(TokenType::RightAngle),

        _ => None,
    }
}

/// Returns the matching TokenType for a string representation of a keyword, if applicable
pub fn parse_keyword(keyword: &str) -> TokenType {
    match keyword {
        // Flow control
        "if" => TokenType::If,
        "else" => TokenType::Else,
        "eval" => TokenType::Eval,
        "loop" => TokenType::Loop,
        "return" => TokenType::Return,
        "continue" => TokenType::Continue,
        "break" => TokenType::Break,

        // Declarations
        "pkg" => TokenType::Pkg,
        "struct" => TokenType::Struct,
        "var" => TokenType::Var,
        "const" => TokenType::Const,
        "static" => TokenType::Static,
        "dyn" => TokenType::Dyn,
        "mtd" => TokenType::Mtd,
        "own" => TokenType::Own,
        "ref" => TokenType::Ref,

        // Builtins
        "new" => TokenType::New,
        "drop" => TokenType::Drop,
        "copy" => TokenType::Copy,
        "clone" => TokenType::Clone,
        "print" => TokenType::Print,

        _ => TokenType::Identifier,
    }
}

/// Represents an individual semantic unit in the source code
#[derive(Clone, Debug)]
pub struct Token {
    pub token_type: TokenType,
    pub value: String,
    line: i32,
    col: i32,
}

impl Token {
    /// Create a new Token
    pub fn new(value: String, token_type: TokenType, line: i32, col: i32) -> Self {
        Token {
            token_type: token_type,
            value: value,
            line: line,
            col: col,
        }
    }
}

/// Allow pretty-printing of Tokens
impl fmt::Display for Token {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(
            f,
            "{} {} ({}, {})",
            self.value.bold(),
            format!("{}", self.token_type).italic(),
            self.line,
            self.col
        )
    }
}
