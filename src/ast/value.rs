/// Represents a literal value of a given type in an abstract syntax tree
#[derive(Clone, Debug)]
pub enum Value {
    Bool(bool),
    Integer(i64),
    Float(f64),
    String(String),
    FormString(String),
    Char(char),
    Nil,
}
