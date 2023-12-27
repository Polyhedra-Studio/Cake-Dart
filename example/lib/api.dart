import 'dart:convert';

import 'package:http/http.dart' as http;

class APIService {
  static const String host = 'https://example.com';

  static http.Client? _client;
  static http.Client get client => _client ?? http.Client();
  // Allow client to be injectable for mock-ability
  static set client(http.Client client) => _client = client;

  APIService._();
  static APIService apiService = APIService._();
  factory APIService() => apiService;

  static Future<String> getHelloWorld() async {
    final http.Response response =
        await client.get(Uri.parse('$host/hello-world'));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return 'Error';
    }
  }

  static Future<UserInfo?> getUserInfo(String userId) async {
    final http.Response response =
        await client.get(Uri.parse('$host/user/$userId'));
    if (response.statusCode != 200) {
      return null;
    }

    try {
      final Map<String, dynamic> json = jsonDecode(response.body);
      return UserInfo.fromJson(json);
    } catch (e) {
      return null;
    }
  }
}

class UserInfo {
  final String id;
  final String name;
  UserInfo(this.id, this.name);

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(json['id'] as String, json['name'] as String);
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
