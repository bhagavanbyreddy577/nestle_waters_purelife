abstract class HttpClientService {
  Future<dynamic> get(String url, {Map<String, String>? headers});
  Future<dynamic> post(String url,
      {Map<String, String>? headers, dynamic body});
  Future<dynamic> put(String url, {Map<String, String>? headers, dynamic body});
  Future<dynamic> delete(String url, {Map<String, String>? headers});
}
