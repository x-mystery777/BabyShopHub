import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_config.dart';
import 'http_factory.dart';
import 'mock_backend.dart';

class ApiException implements Exception {
  ApiException(this.message, [this.statusCode]);
  final String message;
  final int? statusCode;
  @override
  String toString() => message;
}

/// One place that talks HTTP: adds the login, turns errors into readable text.
class ApiClient {
  ApiClient._();
  static final instance = ApiClient._();

  static const _tokenKey = 'auth_token';
  static const _timeout = Duration(seconds: 15);

  final http.Client _client = createClient();

  /// Mock mode: a fake JWT. Real backend: the JSESSIONID session cookie.
  String? _token;
  String? get token => _token;

  /// Called when the server rejects our login (expired / invalid).
  void Function()? onUnauthorized;

  /// True while Session probes for the admin role (a 403 there is expected).
  bool suppressExpiry = false;

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
  }

  Future<void> setToken(String? token, {bool persist = true}) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    if (token != null && persist) {
      await prefs.setString(_tokenKey, token);
    } else {
      await prefs.remove(_tokenKey);
    }
  }

  Map<String, String> _headers({bool json = true}) {
    final h = <String, String>{
      'Accept': 'application/json',
      if (json) 'Content-Type': 'application/json',
    };
    if (_token != null) {
      if (useMock) {
        h['Authorization'] = 'Bearer $_token';
      } else if (!kIsWeb) {
        h['Cookie'] = _token!; // phones send the saved session cookie
      }
      // In a browser the cookie is sent automatically.
    }
    return h;
  }

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('$apiBaseUrl$path')
          .replace(queryParameters: query == null || query.isEmpty ? null : query);

  Future<dynamic> get(String path, {Map<String, String>? query}) {
    if (useMock) {
      return MockBackend.instance.handle('GET', path, query: query);
    }
    return _send(() => _client.get(_uri(path, query), headers: _headers()));
  }

  Future<dynamic> post(String path, [Object? body]) {
    if (useMock) return MockBackend.instance.handle('POST', path, body: body);
    return _send(() => _client.post(_uri(path),
        headers: _headers(), body: body == null ? null : jsonEncode(body)));
  }

  Future<dynamic> put(String path, Object body) {
    if (useMock) return MockBackend.instance.handle('PUT', path, body: body);
    return _send(() =>
        _client.put(_uri(path), headers: _headers(), body: jsonEncode(body)));
  }

  Future<dynamic> patch(String path, Object body) {
    if (useMock) return MockBackend.instance.handle('PATCH', path, body: body);
    return _send(() =>
        _client.patch(_uri(path), headers: _headers(), body: jsonEncode(body)));
  }

  Future<dynamic> delete(String path) {
    if (useMock) return MockBackend.instance.handle('DELETE', path);
    return _send(() => _client.delete(_uri(path), headers: _headers()));
  }

  /// Admin "create product" expects multipart: a JSON part named `product`
  /// plus plain form fields.
  Future<dynamic> postMultipart(
    String path, {
    required Map<String, String> fields,
    required String partName,
    required Map<String, dynamic> partJson,
  }) {
    if (useMock) {
      return MockBackend.instance.handle('POST', path, body: {
        ...partJson,
        for (final e in fields.entries) e.key: int.tryParse(e.value) ?? e.value,
      });
    }
    return _send(() async {
      final request = http.MultipartRequest('POST', _uri(path))
        ..headers.addAll(_headers(json: false))
        ..fields.addAll(fields)
        ..files.add(http.MultipartFile.fromString(
          partName,
          jsonEncode(partJson),
          filename: '$partName.json',
          contentType: MediaType('application', 'json'),
        ));
      return http.Response.fromStream(await _client.send(request));
    });
  }

  /// Real backend login: it answers 204 and sets a JSESSIONID cookie.
  Future<String> loginSession(String path, Object body) async {
    final http.Response res;
    try {
      res = await _client
          .post(_uri(path), headers: _headers(), body: jsonEncode(body))
          .timeout(_timeout);
    } on TimeoutException {
      throw ApiException('The server took too long to respond. Try again.');
    } catch (_) {
      throw ApiException(
          "Can't reach the server. Check your connection and that the backend is running.");
    }
    _handle(res); // throws a readable error when the login failed
    if (kIsWeb) return 'browser-session'; // the browser keeps the cookie
    final cookie = RegExp(r'JSESSIONID=[^;,\s]+')
        .firstMatch(res.headers['set-cookie'] ?? '')
        ?.group(0);
    if (cookie == null) {
      throw ApiException('Login worked but the server sent no session.');
    }
    return cookie;
  }

  Future<dynamic> _send(Future<http.Response> Function() call) async {
    try {
      final res = await call().timeout(_timeout);
      return _handle(res);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException('The server took too long to respond. Try again.');
    } catch (_) {
      throw ApiException(
          "Can't reach the server. Check your connection and that the backend is running.");
    }
  }

  dynamic _handle(http.Response res) {
    final body = utf8.decode(res.bodyBytes).trim();
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (body.isEmpty) return null;
      try {
        return jsonDecode(body);
      } catch (_) {
        return body; // plain-text answers such as "Email verified..."
      }
    }

    var message = '';
    if (body.isNotEmpty) {
      try {
        final decoded = jsonDecode(body);
        if (decoded is Map) {
          message = (decoded['error'] ?? decoded['message'] ?? '').toString();
        }
      } catch (_) {
        message = body;
      }
    }
    final expired = res.statusCode == 401 ||
        (res.statusCode == 403 && !useMock && !suppressExpiry);
    if (expired && _token != null) {
      onUnauthorized?.call();
      message = 'Your session expired. Please log in again.';
    } else if (message.isEmpty) {
      message = switch (res.statusCode) {
        401 => 'Please log in to continue.',
        403 => 'You are not allowed to do that.',
        404 => 'We could not find what you asked for.',
        >= 500 => 'Something went wrong on the server. Try again later.',
        _ => 'Request failed (${res.statusCode}).',
      };
    }
    throw ApiException(message, res.statusCode);
  }
}