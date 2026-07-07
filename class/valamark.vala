public class Valamark {
  private string m_buffer;
  private Lexer lexer = new Lexer ("");

  public Lexer read_file (string path) {
    try {
      FileUtils.get_contents (path, out m_buffer);
      lexer = new Lexer (m_buffer);
      return lexer;
    } catch (FileError e) {
      stderr.printf ("Error reading file: %s\n", e.message);
    }
    return lexer;
  }
}
