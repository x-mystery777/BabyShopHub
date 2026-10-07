import 'package:http/browser_client.dart';
import 'package:http/http.dart' as http;

/// In a browser, cookies are kept by the browser itself; this tells it to
/// send the login cookie with every request to the backend.
http.Client createClient() => BrowserClient()..withCredentials = true;