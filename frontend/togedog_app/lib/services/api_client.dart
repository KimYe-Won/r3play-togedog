import 'dart:convert';

import 'package:http/http.dart' as http;

import '../backend_session_store.dart';
import 'api_config.dart';

// [백엔드 연동] 공통 HTTP 클라이언트 — X-Member-Id 헤더 포함
class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  Map<String, String> _headers({bool withMember = true}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (withMember) {
      final memberId = BackendSessionStore.instance.memberId;
      if (memberId != null && memberId.isNotEmpty) {
        headers['X-Member-Id'] = memberId;
      }
    }
    return headers;
  }

  Future<http.Response> get(String path, {bool withMember = true}) {
    return http.get(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: _headers(withMember: withMember),
    );
  }

  Future<http.Response> post(
    String path, {
    Map<String, dynamic>? body,
    bool withMember = true,
  }) {
    return http.post(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: _headers(withMember: withMember),
      body: body == null ? null : jsonEncode(body),
    );
  }

  Future<http.Response> put(
    String path, {
    Map<String, dynamic>? body,
    bool withMember = true,
  }) {
    return http.put(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: _headers(withMember: withMember),
      body: body == null ? null : jsonEncode(body),
    );
  }

  Future<http.Response> patch(
    String path, {
    Map<String, dynamic>? body,
    bool withMember = true,
  }) {
    return http.patch(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: _headers(withMember: withMember),
      body: body == null ? null : jsonEncode(body),
    );
  }
}