void main (string[] args) {
  if (args.length < 2) {
    return;
  }

  string mdCode;

  try {
    FileUtils.get_contents (args[1], out mdCode);
  } catch (FileError e) {
    stderr.printf ("Error reading file: %s\n", e.message);
    return;
  }

  var lxc = new Lexer (mdCode);

  var token_list = lxc.tokenize ();
  var parser = new AstParser (token_list);
  var document = parser.parse ();

  print ("%s", document.to_string ());
}
