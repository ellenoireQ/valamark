public enum TokenType {
  STRING, WORD, NUMBER, HASH, EOF;
  public string to_string() {
    switch (this) {
    case STRING:
      return "STRING";
    case WORD:
      return "WORD";
    case NUMBER:
      return "NUMBER";
    case HASH:
      return "HASH";
    case EOF:
      return "EOF";
    default:
      assert_not_reached();
    }
  }
}

public class Token {
  public TokenType type;
  public string value;

  public Token(TokenType type, string value) {
    this.type = type;
    this.value = value;
  }

  public string toString() {
    string fmt = "Token(%s, %s)".printf(type.to_string(), value);
    return fmt;
  }
}
