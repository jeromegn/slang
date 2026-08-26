# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

This shard is a library, so it doesn't have a CLI. To run tests and linting, use:

```bash
# Run all tests
crystal spec

# Run a single spec file
crystal spec spec/slang_spec.cr

# Lint
ameba
```

## Architecture

Slang is a Crystal templating language that compiles `.slang` syntax into Crystal code that generates HTML. The pipeline is:

```
Slang source → Lexer → Token stream → Parser → AST → Codegen (Visitor) → Crystal code → HTML
```

### Core pipeline

**`src/slang/lexer.cr`** — Character-by-character tokenizer. Produces `Token` objects (defined in `token.cr`) with typed enum values (`Token::Type`: EOF, Newline, Element, Doctype, Control, Output, HTML, Comment, Text). Handles element syntax (`div#id.class`), attributes, string interpolation (`#{...}`), and raw text blocks (`javascript:`, `css:`).

**`src/slang/parser.cr`** — Builds an AST (`Document` + `Node` tree) from the token stream. Parent-child relationships are determined by column numbers (indentation depth). Groups control flow branches (`if/elsif/else`, `case/when`, `begin/rescue/ensure`) into a single `Control` node.

**`src/slang/codegen.cr`** — Extends `Visitor` (visitor pattern). Traverses the AST and emits Crystal code that appends strings to a `String::Builder`. The generated code uses `__slang__` as its accumulator variable.

**`src/slang/visitor.cr`** — Base visitor class defining `visit(Document)` and `visit(Node)` with `visit_children` traversal. Subclass this to add new AST traversals without touching node classes.

### Node types (`src/slang/nodes/`)

| Node | Purpose |
|------|---------|
| `element.cr` | HTML elements; tracks self-closing tags; suppresses child escaping for `script`/`style` |
| `text.cr` | Plain text and output expressions (`=`/`==`); delegates escaping to parent element |
| `control.cr` | Control flow blocks; holds branches as child groups |
| `comment.cr` | Visible (`/`), invisible (`/!`), and IE conditional comments |
| `doctype.cr` | `doctype html` declarations |

### Public API (`src/slang.cr`)

Two entry points: `Slang.process_string(source)` and `Slang.process_file(path)`. Both return a string of generated Crystal code. Compile-time usage via macros is in `src/slang/macros.cr` (the `render`/`render_file` macros used in tests).

### Tests

`spec/slang_spec.cr` uses `render()` and `render_file()` macros that process templates at compile time, then `eval`-style execute them. Fixtures are in `spec/fixtures/`. The macro infrastructure lives in `spec/support/`.
