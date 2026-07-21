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

public struct ParsedElement {
  public string element;
  public string content;
  public string style;
  public int level;
  public TokenType token;
  public int content_offset;
  public int offset_start;
  public int offset_end;

  public string to_markdown () {
    if (level <= 0) {
      return content;
    }

    var builder = new StringBuilder ();

    for (int i = 0; i < level; i++) {
      builder.append_c ('#');
    }

    builder.append_c (' ');
    builder.append (content);

    return builder.str;
  }

  public string to_string () {
    return "{ element: \"%s\", content: \"%s\", style: \"%s\", level: %d, token: %s}".printf (
                                                                                              element,
                                                                                              content,
                                                                                              style,
                                                                                              level,
                                                                                              token.to_string ()
    );
  }
}

public class AstParser : Object {
  private Gee.List<Token> tokens;
  private int current = 0;
  private const int MAX_HEADING_LEVEL = 6;

  public AstParser (Gee.List<Token> tokens) {
    this.tokens = tokens;
  }

  public DocumentNode parse () {
    var document = new DocumentNode ();

    while (!is_at_end ()) {
      int heading_level = consume_heading_level ();

      if (heading_level > 0) {
        document.add_child (new HeadingNode (heading_level, collect_text (false), "h%d".printf (heading_level)));
      } else if (check (TokenType.WORD) || check (TokenType.NUMBER) || check (TokenType.STRING)) {
        document.add_child (new TextNode (collect_text (false)));
      } else {
        advance ();
      }
    }

    return document;
  }

  public ParsedElement[] parse_elements () {
    ParsedElement[] elements = {};

    while (!is_at_end ()) {
      // Skip any leading newlines
      while (check (TokenType.NEWLINE)) {
        advance ();
      }

      if (is_at_end ()) {
        break;
      }

      int heading_level = consume_heading_level ();

      if (heading_level > 0) {
        string heading_text = collect_text (false);

        if (heading_text.length > 0) {
          ParsedElement heading = ParsedElement ();
          heading.element = "h%d".printf (heading_level);
          heading.content = heading_text;
          heading.style = "h%d".printf (heading_level);
          heading.level = heading_level;
          heading.token = TokenType.HASH;
          elements += heading;
        }

        // Consume the newline after heading
        if (check (TokenType.NEWLINE)) {
          advance ();
        }
      } else if (check (TokenType.WORD) || check (TokenType.NUMBER) || check (TokenType.STRING)) {
        string paragraph_text = collect_text (false);

        if (paragraph_text.length > 0) {
          ParsedElement paragraph = ParsedElement ();
          paragraph.element = "paragraph";
          paragraph.content = paragraph_text;
          paragraph.style = "p";
          paragraph.level = 0;
          paragraph.token = TokenType.STRING;
          elements += paragraph;
        }

        // Consume the newline after paragraph
        if (check (TokenType.NEWLINE)) {
          advance ();
        }
      } else if (check (TokenType.LIST)) {
        int marker_start = peek ().value.length;
        advance ();
        string lists = collect_text (true);

        ParsedElement list = ParsedElement ();
        list.element = "list";
        list.content = lists;
        list.style = "list";
        list.token = TokenType.LIST;
        list.content_offset = list.content.length;
        list.offset_start = marker_start;
        list.offset_end = 0;
        elements += list;
      } else if (check (TokenType.ITALIC)) {
        int marker_start = peek ().value.length;
        int marker_end = 0;
        advance ();
        string contents = collect_text (true);

        if (check (TokenType.ITALIC)) {
          marker_end = advance ().value.length;
        }

        ParsedElement content = ParsedElement ();
        content.element = "italic";
        content.content = contents;
        content.style = "italic";
        content.token = TokenType.ITALIC;
        content.content_offset = content.content.length;
        content.offset_start = marker_start;
        content.offset_end = marker_end;

        elements += content;
      } else if (check (TokenType.BOLD)) {
        int marker_start = peek ().value.length;
        int marker_end = 0;
        advance ();
        string contents = collect_text (true);

        if (check (TokenType.BOLD)) {
          marker_end = advance ().value.length;
        }

        ParsedElement content = ParsedElement ();
        content.element = "bold";
        content.content = contents;
        content.style = "bold";
        content.token = TokenType.BOLD;
        content.content_offset = content.content.length;
        content.offset_start = marker_start;
        content.offset_end = marker_end;

        elements += content;
      } else if (check (TokenType.BOLD_ITALIC)) {
        int marker_start = peek ().value.length;
        int marker_end = 0;
        advance ();
        string contents = collect_text (true);

        if (check (TokenType.BOLD_ITALIC)) {
          marker_end = advance ().value.length;
        }

        ParsedElement content = ParsedElement ();
        content.element = "bold-italic";
        content.content = contents;
        content.style = "bold-italic";
        content.token = TokenType.BOLD_ITALIC;
        content.content_offset = content.content.length;
        content.offset_start = marker_start;
        content.offset_end = marker_end;

        elements += content;
      } else {
        advance ();
      }
    }

    return elements;
  }

  private string collect_text (bool stop_at_formatting = true) {
    var builder = new StringBuilder ();

    while (!is_at_end ()) {
      var token = peek ();

      // Stop at hash or newline or EOF
      if (token.type == TokenType.HASH ||
          token.type == TokenType.NEWLINE ||
          token.type == TokenType.EOF) {
        break;
      }

      // Stop at formatting markers only if requested
      if (stop_at_formatting && (
                                 token.type == TokenType.BOLD ||
                                 token.type == TokenType.ITALIC ||
                                 token.type == TokenType.BOLD_ITALIC ||
                                 token.type == TokenType.LIST)) {
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

  private int consume_heading_level () {
    if (!check (TokenType.HASH)) {
      return 0;
    }

    int level = 0;

    while (!is_at_end () && check (TokenType.HASH)) {
      level += 1;

      advance ();

      if (level >= MAX_HEADING_LEVEL) {
        level = MAX_HEADING_LEVEL;
        while (!is_at_end () && check (TokenType.HASH)) {
          advance ();
        }
        break;
      }
    }

    return level;
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
