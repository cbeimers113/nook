# Conventions

Project structure, naming, and code style conventions

---

## Project Structure

* Source files are **snake_case** with the `.nk` extension
* The entry point for binary projects must be called `main.nk`
* The `main.nk` file should be in
  * Project root for single-entry point projects
  * A subdirectory of `main/` in the project root
* Internal source code should go in the `src/` directory
* Exported source code should go in the `exp/` directory
* A project must have a `nook.toml` file in the root

---

## Naming Conventions

* Struct, interface, and type alias names should be **PascalCase**
* Variable and function names should be **snake_case**
* Constant names should be **SCREAMING_SNAKE_CASE**
* Identifiers should be concise but descriptive

---

## Code Style

* Max one line of whitespace separating lines
* Source files should group content in this order:
  * Imports
    * Stdlib > 3rd party > internal
  * Global constant definitions
  * Global variable definitions
  * Struct definitions
    * Structs required by others defined first
  * Dynamic function definitions
  * Static function definitions
* Lines of code should be grouped by whitespace into small regions when possible
* Parenthesized expressions should be followed by a single space or newline
* Unary operators should not have whitespace between operator and operand
* Binary operators should have whitespace between operator and operands, except:
  * Multiplication, division, exponentiation
* All functions should have a brief descriptive comment above the signature
* Struct definitions should include a brief descriptive comment below the name

---

[Data Types](./1-data-types.md) ➡️
