using Gee;

public abstract class AstNode : Object {
  public abstract string to_string (int indent = 0);

  protected string indent_string (int indent) {
    var builder = new StringBuilder ();

    for (int i = 0; i < indent; i++) {
      builder.append ("  ");
    }

    return builder.str;
  }
}

public class DocumentNode : AstNode {
  public ArrayList<AstNode> children { get; private set; }

  public DocumentNode () {
    children = new ArrayList<AstNode> ();
  }

  public void add_child (AstNode node) {
    children.add (node);
  }

  public override string to_string (int indent = 0) {
    var builder = new StringBuilder ();
    builder.append_printf ("%sDocument\n", indent_string (indent));

    foreach (var child in children) {
      builder.append (child.to_string (indent + 1));
    }

    return builder.str;
  }
}

public class HeadingNode : AstNode {
  public int level { get; private set; }
  public string text { get; private set; }
  public string style { get; private set; }

  public HeadingNode (int level, string text, string style) {
    this.level = level;
    this.text = text;
    this.style = style;
  }

  public override string to_string (int indent = 0) {
    return "%sHeading(level=%d, text=\"%s\", style=\"%s\")\n".printf (
                                                                      indent_string (indent),
                                                                      level,
                                                                      text, style
    );
  }
}

public class HashNode : AstNode {
  public string value { get; private set; }

  public HashNode (string value) {
    this.value = value;
  }

  public override string to_string (int indent = 0) {
    return "%sHash(\"%s\")\n".printf (indent_string (indent), value);
  }
}

public class TextNode : AstNode {
  public string text { get; private set; }

  public TextNode (string text) {
    this.text = text;
  }

  public override string to_string (int indent = 0) {
    return "%sText(\"%s\")\n".printf (indent_string (indent), text);
  }
}

public class AstParser : Object {
  private Gee.List<Token> tokens;
  private int current = 0;

  public AstParser (Gee.List<Token> tokens) {
    this.tokens = tokens;
  }

  public DocumentNode parse () {
    var document = new DocumentNode ();

    while (!is_at_end ()) {
      if (match (TokenType.HASH)) {
        document.add_child (new HeadingNode (1, collect_text (), "headings-one"));
      } else if (match (TokenType.DOUBLEHASH)) {
        document.add_child (new HeadingNode (2, collect_text (), "headings-two"));
      } else if (check (TokenType.WORD) || check (TokenType.NUMBER) || check (TokenType.STRING)) {
        document.add_child (new TextNode (collect_text ()));
      } else {
        advance ();
      }
    }

    return document;
  }

  private string collect_text () {
    var builder = new StringBuilder ();

    while (!is_at_end ()) {
      if (check (TokenType.HASH) || check (TokenType.DOUBLEHASH)) {
        break;
      }

      var token = peek ();

      if (token.type == TokenType.EOF) {
        break;
      }

      if (token.type == TokenType.WORD || token.type == TokenType.NUMBER || token.type == TokenType.STRING) {
        if (builder.len > 0) {
          builder.append_c (' ');
        }

        builder.append (advance ().value);
      } else {
        advance ();
      }
    }

    return builder.str.strip ();
  }

  private bool match (TokenType type) {
    if (!check (type)) {
      return false;
    }

    advance ();
    return true;
  }

  private bool check (TokenType type) {
    if (is_at_end ()) {
      return false;
    }

    return peek ().type == type;
  }

  private Token advance () {
    if (!is_at_end ()) {
      current++;
    }

    return previous ();
  }

  private bool is_at_end () {
    return peek ().type == TokenType.EOF;
  }

  private Token peek () {
    return tokens.get (current);
  }

  private Token previous () {
    return tokens.get (current - 1);
  }
}
