using Gee;
public enum TokenType {
    STRING,WORD, NUMBER, HASH, EOF;
    public string to_string(){
      switch(this){
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
public class Lexer {
    private string input;
    private int pos = 0;

    public Lexer(string input) {
        this.input = input;
    }

    private char peek() {
        if (pos >= input.length) {
            return '\0';
        }
        return (char) input[pos];
    }

    private char advance() {
        char current = peek();
        pos++;
        return current;
    }

    public Gee.List<Token> tokenize() {
        var tokens = new Gee.ArrayList<Token>();

        while (pos < input.length) {
            char current = peek();

            if (current.isspace()) {
                advance();
            } else if (current.isdigit()) {
                var sb = new StringBuilder();
                
                while (peek() != '\0' && peek().isdigit()) {
                    sb.append_c(advance());
                }
                
                tokens.add(new Token(TokenType.NUMBER, sb.str));
            }  else if (current.isalpha()) {
                var sb = new StringBuilder();
                while (peek() != '\0' && (peek().isalnum() || peek() == '_')) {
                    sb.append_c(advance());
                }
                tokens.add(new Token(TokenType.WORD, sb.str));
            }else if (current == '"') {
                advance();
                var sb = new StringBuilder();

                
                while (peek() != '\0' && peek() != '"') {
                    sb.append_c(advance());
                }
                
                if (peek() == '"') {
                    advance();
                } else {
                    stderr.printf("Error: String is not closed!\n");
                }
                tokens.add(new Token(TokenType.STRING, sb.str));
            }else {
                char adv = advance();
                switch (adv) {
                    case '#': tokens.add(new Token(TokenType.HASH, "#")); break;
                    default:
                        stderr.printf("Unexpected character: %c\n", adv);
                        break;
                }
            }
        }
        
        tokens.add(new Token(TokenType.EOF, ""));
        return tokens;
    }
}
void main(){
  string mdCode = "\n#This is string ## 23456" ;

    var lxc = new Lexer(mdCode); 
    
    var token_list = lxc.tokenize();
    
    for (int ab = 0; ab < token_list.size; ab++){
        print("%s\n", token_list.get(ab).type.to_string()); 
    }
}
