import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:nestle_waters_purelife/core/services/http/http_client_service.dart';
import 'package:retry/retry.dart';

class HttpClientServiceImpl implements HttpClientService {
  final http.Client _client;
  final Duration _timeout = const Duration(seconds: 10);
  HttpClientServiceImpl(this._client);
  @override
  Future<dynamic> get(String url, {Map<String, String>? headers}) async {
    return _executeRequest(() => _client.get(Uri.parse(url), headers: headers));
  }

  @override
  Future<dynamic> post(String url,
      {Map<String, String>? headers, dynamic body}) async {
    return _executeRequest(() =>
        _client.post(Uri.parse(url), headers: headers, body: jsonEncode(body)));
  }

  @override
  Future<dynamic> put(String url,
      {Map<String, String>? headers, dynamic body}) async {
    return _executeRequest(() =>
        _client.put(Uri.parse(url), headers: headers, body: jsonEncode(body)));
  }

  @override
  Future<dynamic> delete(String url, {Map<String, String>? headers}) async {
    return _executeRequest(
        () => _client.delete(Uri.parse(url), headers: headers));
  }

  Future<dynamic> _executeRequest(
      Future<http.Response> Function() requestFn) async {
    final r = RetryOptions(maxAttempts: 3);
    return await r.retry(
      () async {
        final response = await requestFn().timeout(_timeout);
        _log(response);
        return _handleResponse(response);
      },
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
  }

  void _log(http.Response response) {
    print('HTTP ${response.request?.method} ${response.request?.url}');
    print('Status: ${response.statusCode}');
    print('Response: ${response.body}');
  }

  dynamic _handleResponse(http.Response response) {
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      throw HttpException('Error ${response.statusCode}: $body');
    }
  }
}
