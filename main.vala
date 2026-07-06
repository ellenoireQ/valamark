void main () {
  string mdCode = "\n#This is string ## 23456\n # abcde";

  var lxc = new Lexer (mdCode);

  var token_list = lxc.tokenize ();
  var parser = new AstParser (token_list);
  var document = parser.parse ();

  print ("%s", document.to_string ());
}