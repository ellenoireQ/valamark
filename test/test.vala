void main (string[] args) {
  if (args.length < 2) {
    return;
  }

  var pd = new Valamark (args[1]);

  var elements = pd.value ();

  foreach (var element in elements) {
    print ("%s\n", element.to_string ());
  }
}
