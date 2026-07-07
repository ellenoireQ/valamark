void main (string[] args) {
  var pd = new Valamark (args[1]);
  if (args.length < 2) {
    return;
  }

  var document = pd.value ();

  print ("%s", document.to_string ());
}
