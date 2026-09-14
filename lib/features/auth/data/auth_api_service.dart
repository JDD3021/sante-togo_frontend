import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_exception.dart';
import '../domain/app_user.dart';

/// Result of a successful authentication call: token + the user it belongs to.
class AuthResult {
  final String accessToken;
  final AppUser user;

  const AuthResult({required this.accessToken, required this.user});

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      accessToken: json['access_token'] as String,
      user: AppUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

/// Calls the backend's /auth endpoints (register, login, OTP by email, Google Sign-In).
class AuthApiService {
  final String baseUrl;
  final http.Client client;

  AuthApiService({
    this.baseUrl = AppConstants.apiBaseUrl,
    http.Client? client,
  }) : client = client ?? http.Client();

  Future<AuthResult> register({
    required String email,
    required String password,
    String? fullName,
  }) async {
    return _postForToken('/register', {
      'email': email,
      'password': password,
      'full_name': fullName,
    }, action: 'Inscription');
  }

  Future<AuthResult> login({required String email, required String password}) async {
    return _postForToken('/login', {
      'email': email,
      'password': password,
    }, action: 'Connexion');
  }

  Future<void> requestOtp(String email) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl${AppConstants.authEndpoint}/otp/request'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );
      if (response.statusCode != 200) {
        throw apiExceptionFromResponse(response, action: "Envoi du code par email");
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw apiExceptionFromError(e, action: "Envoi du code par email");
    }
  }

  Future<AuthResult> verifyOtp({required String email, required String code}) async {
    return _postForToken('/otp/verify', {
      'email': email,
      'code': code,
    }, action: 'Vérification du code');
  }

  Future<AuthResult> loginWithGoogle(String idToken) async {
    return _postForToken('/google', {
      'id_token': idToken,
    }, action: 'Connexion avec Google');
  }

  /// Fetches the profile for the currently authenticated user (used to
  /// restore session details on app restart from a persisted token).
  Future<AppUser> me(String token) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl${AppConstants.authEndpoint}/me'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return AppUser.fromJson(json.decode(response.body));
      }
      throw apiExceptionFromResponse(response, action: 'Session');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw apiExceptionFromError(e, action: 'Session');
    }
  }

  Future<AuthResult> _postForToken(
    String path,
    Map<String, dynamic> body, {
    required String action,
  }) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl${AppConstants.authEndpoint}$path'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResult.fromJson(json.decode(response.body));
      }
      throw apiExceptionFromResponse(response, action: action);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw apiExceptionFromError(e, action: action);
    }
  }
}
