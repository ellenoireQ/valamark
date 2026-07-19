# Valamark - Valamarkdown

A lightweight Markdown parser written in Vala that converts Markdown documents into an readable objects for [ideas](https://github.com/ellenoireQ/ideas).

## Features

- [x] `h1`, `h2`, `h3`, `h4`, `h5`, `h6`
- [ ] `---`
- [ ] `paragraph`
- [x] `List`
- [ ] `Table`
- [x] `bold`
- [x] `italic`
- [x] `bold-italic`
- `etc`

## Usage

The public API provides a simple interface to parse Markdown files:

```vala
var parser = new Valamark("path/to/file.md");
var elements = parser.value(); //returned ParsedElement[]
```

### Components

- **Lexer**: Tokenizes the input Markdown text
- **Parser**: Builds an AST from tokens
- **AST Nodes**: Various node types (Heading, Document, etc.) for representing Markdown elements

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
