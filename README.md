# Nook

A programming language project.

**Current Status:** *Parser development*

- [Roadmap](./docs/roadmap.md)
- [Design docs](./docs/design/0-conventions.md)

## Versioning

* Semantic versioning for language spec
  * Ie `v1.2.3`
  * Currently tracked in `Cargo.toml` for Rust bootstrap phase
* Build type and number as semver metadata for compiler iterations
  * Ie `bootstrap1`
  * Tracked in `build.json`
* Git commit of latest build included as final component in build metadata
  * Ie `deadbeef`
