void main () {
  string mdCode = "\n#This is string ## 23456";

  var lxc = new Lexer (mdCode);

  var token_list = lxc.tokenize ();

  for (int ab = 0; ab < token_list.size; ab++) {
    print ("%s\n", token_list.get (ab).type.to_string ());
  }
}
