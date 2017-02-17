import 'dart:html';

/// Gets the protocol, domain, subdomain (if any), and port (if any) from the web site's request URL. Primarily for use in constructing an address to request the API from.
String getServerRoot() {
  final StringBuffer output = new StringBuffer();
  output.write(window.location.protocol);
  output.write("//");
  output.write(window.location.host);
  output.write("/");

  // When running in dev, since I use PHPStorm, the client runs via a different
  // server than the dartfeed server component. This is usually on a 5-digit port,
  // which theoretically wouldn't be used in a real deployment.
  // TODO: Figure out a cleaner way of handling this
  if (window.location.port.length >= 5) return "http://localhost:3333/";

  return output.toString();
}