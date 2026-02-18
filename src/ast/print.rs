use crate::ast::{expr::Expr, stmt::Stmt};

pub fn print_stmt_tree(stmts: &[Box<Stmt>]) {
    for stmt in stmts {
        print_stmt(stmt, "", true);
    }
}

fn print_stmt(stmt: &Box<Stmt>, prefix: &str, is_last: bool) {
    let connector = if is_last { "└─ " } else { "├─ " };
    match &**stmt {
        Stmt::Print(expr) => {
            println!("{}{}Print", prefix, connector);
            print_expr(
                expr,
                &format!("{}{}", prefix, if is_last { "   " } else { "│  " }),
                true,
            );
        }
        Stmt::Expression(expr) => {
            println!("{}{}Expression", prefix, connector);
            print_expr(
                expr,
                &format!("{}{}", prefix, if is_last { "   " } else { "│  " }),
                true,
            );
        }
        Stmt::Var(name, initializer) => {
            println!("{}{}Var({})", prefix, connector, name.value);
            if let Some(init) = initializer {
                print_expr(
                    init,
                    &format!("{}{}", prefix, if is_last { "   " } else { "│  " }),
                    true,
                );
            }
        }
    }
}

fn print_expr(expr: &Box<Expr>, prefix: &str, is_last: bool) {
    let connector = if is_last { "└─ " } else { "├─ " };
    match &**expr {
        Expr::Assign { name, value } => {
            println!("{}{}Assign({})", prefix, connector, name.value);
            print_expr(
                value,
                &format!("{}{}", prefix, if is_last { "   " } else { "│  " }),
                true,
            );
        }

        Expr::Binary {
            left,
            operator,
            right,
        } => {
            println!("{}{}Binary({})", prefix, connector, operator.value);
            print_expr(
                left,
                &format!("{}{}", prefix, if is_last { "   " } else { "│  " }),
                false,
            );
            print_expr(
                right,
                &format!("{}{}", prefix, if is_last { "   " } else { "│  " }),
                true,
            );
        }

        Expr::Call { callee, args, .. } => {
            println!("{}{}Call", prefix, connector);
            print_expr(
                callee,
                &format!("{}{}", prefix, if is_last { "   " } else { "│  " }),
                args.is_empty(),
            );
            for (i, arg) in args.iter().enumerate() {
                let last = i == args.len() - 1;
                print_expr(
                    &Box::new(arg.clone()),
                    &format!("{}{}", prefix, if is_last { "   " } else { "│  " }),
                    last,
                );
            }
        }

        Expr::Get { object, property } => {
            println!("{}{}Get({})", prefix, connector, property.value);
            print_expr(
                object,
                &format!("{}{}", prefix, if is_last { "   " } else { "│  " }),
                true,
            );
        }

        Expr::Set {
            object,
            property,
            value,
        } => {
            println!("{}{}Set({})", prefix, connector, property.value);
            print_expr(
                object,
                &format!("{}{}", prefix, if is_last { "   " } else { "│  " }),
                false,
            );
            print_expr(
                value,
                &format!("{}{}", prefix, if is_last { "   " } else { "│  " }),
                true,
            );
        }

        Expr::Grouping { expression } => {
            println!("{}{}Grouping", prefix, connector);
            print_expr(
                expression,
                &format!("{}{}", prefix, if is_last { "   " } else { "│  " }),
                true,
            );
        }

        Expr::Literal { value } => {
            println!("{}{}Literal({:?})", prefix, connector, value);
        }

        Expr::Logical {
            left,
            operator,
            right,
        } => {
            println!("{}{}Logical({})", prefix, connector, operator.value);
            print_expr(
                left,
                &format!("{}{}", prefix, if is_last { "   " } else { "│  " }),
                false,
            );
            print_expr(
                right,
                &format!("{}{}", prefix, if is_last { "   " } else { "│  " }),
                true,
            );
        }

        Expr::Unary { operator, operand } => {
            println!("{}{}Unary({})", prefix, connector, operator.value);
            print_expr(
                operand,
                &format!("{}{}", prefix, if is_last { "   " } else { "│  " }),
                true,
            );
        }

        Expr::Variable { name } => {
            println!("{}{}Variable({})", prefix, connector, name.value);
        }
    }
}
