void main (string[] args) {
  var pd = new Valamark ();
  if (args.length < 2) {
    return;
  }

  var apd = pd.read_file (args[1]);

  var token_list = apd.tokenize ();
  var parser = new AstParser (token_list);
  var document = parser.parse ();

  print ("%s", document.to_string ());
}
