public class Valamark {
  private string m_buffer;
  private Lexer lexer = new Lexer ("");

  public Valamark (string path) {
    read_file (path);
  }

  private Lexer read_file (string path) {
    try {
      FileUtils.get_contents (path, out m_buffer);
      lexer = new Lexer (m_buffer);
      return lexer;
    } catch (FileError e) {
      stderr.printf ("Error reading file: %s\n", e.message);
    }
    return lexer;
  }

  public ParsedElement[] value () {
    AstParser parser = new AstParser (lexer.tokenize ());
    return parser.parse_elements ();
  }
}
