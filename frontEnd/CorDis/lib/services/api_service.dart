import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  static final instance = ApiService();

  static const _defaultBaseUrl =
      'https://4w2dhf1omh.execute-api.us-east-2.amazonaws.com/Prod/';
  static const _configuredBaseUrl = String.fromEnvironment(
    'CORDIS_API_BASE_URL',
    defaultValue: _defaultBaseUrl,
  );

  final http.Client _client;

  Uri _uri(String path) {
    final baseUrl = _configuredBaseUrl.replaceFirst(RegExp(r'/+$'), '');
    final cleanPath = path.replaceFirst(RegExp(r'^/+'), '');

    return Uri.parse('$baseUrl/$cleanPath');
  }

  Future<CreateUserResult> createUser({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await _sendJson(
      path: '/api/users/create',
      body: {'username': username, 'email': email, 'password': password},
    );

    return CreateUserResult(
      message: response['message']?.toString() ?? 'User created successfully',
      userId: response['user_id']?.toString(),
    );
  }

  Future<LoginUserResult> loginUser({
    required String emailOrUsername,
    required String password,
  }) async {
    final response = await _sendJson(
      path: '/api/users',
      body: {'email': emailOrUsername, 'password': password},
    );

    return LoginUserResult.fromJson(response);
  }

  Future<Map<String, dynamic>> _sendJson({
    required String path,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await _client
          .post(
            _uri(path),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 12));
      final decodedBody = _decodeBody(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          decodedBody['error']?.toString() ??
              decodedBody['message']?.toString() ??
              'Backend request failed',
        );
      }

      return decodedBody;
    } on TimeoutException {
      throw const ApiException('Backend request timed out');
    } on http.ClientException catch (error) {
      throw ApiException('Could not reach backend: ${error.message}');
    } on FormatException {
      throw const ApiException('Backend returned an invalid response');
    }
  }

  Map<String, dynamic> _decodeBody(String responseBody) {
    if (responseBody.trim().isEmpty) {
      return {};
    }

    final decoded = jsonDecode(responseBody);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected a JSON object');
    }

    final nestedBody = decoded['body'];

    if (nestedBody is String) {
      final nestedDecoded = jsonDecode(nestedBody);

      if (nestedDecoded is Map<String, dynamic>) {
        return nestedDecoded;
      }
    }

    return decoded;
  }
}

class CreateUserResult {
  const CreateUserResult({required this.message, required this.userId});

  final String message;
  final String? userId;
}

class LoginUserResult {
  const LoginUserResult({required this.message, required this.user});

  factory LoginUserResult.fromJson(Map<String, dynamic> json) {
    final rawUser = json['user'];
    final userJson = rawUser is Map<String, dynamic> ? rawUser : json;

    return LoginUserResult(
      message: json['message']?.toString() ?? 'Login successful',
      user: BackendUser.fromJson(userJson),
    );
  }

  final String message;
  final BackendUser user;
}

class BackendUser {
  const BackendUser({
    required this.userId,
    required this.username,
    required this.email,
    required this.status,
    this.bio,
    this.createdAt,
  });

  factory BackendUser.fromJson(Map<String, dynamic> json) {
    return BackendUser(
      userId: json['user_id']?.toString(),
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      bio: json['bio']?.toString(),
      status: json['status']?.toString() ?? 'active',
      createdAt: json['created_at']?.toString(),
    );
  }

  final String? userId;
  final String username;
  final String email;
  final String? bio;
  final String status;
  final String? createdAt;
}

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
