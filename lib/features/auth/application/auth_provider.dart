import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_exception.dart';
import '../data/auth_api_service.dart';
import '../data/token_storage.dart';
import '../domain/app_user.dart';

enum AuthStatus { initial, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final AppUser? user;
  final String? token;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.user,
    this.token,
    this.isLoading = false,
    this.errorMessage,
  });

  factory AuthState.initial() => const AuthState(status: AuthStatus.initial);

  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    String? token,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Session state and login flows (password, email OTP, Google Sign-In).
///
/// POC note: the persisted token is trusted as valid on app restart without
/// a round-trip to /auth/me. If it has expired, the first protected request
/// will fail with 401 - a production build should verify eagerly instead.
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthApiService _api;
  final TokenStorage _storage;
  GoogleSignIn? _googleSignIn;

  AuthNotifier(this._api, this._storage) : super(AuthState.initial()) {
    _restoreSession();
  }

  /// Lazily builds the GoogleSignIn client, only once a Client ID is
  /// configured. On web, constructing GoogleSignIn with no `clientId` throws
  /// synchronously (plugin assertion), so this must not run eagerly/unconfigured.
  GoogleSignIn? _ensureGoogleSignIn() {
    if (AppConstants.googleClientId.isEmpty) return null;
    return _googleSignIn ??= GoogleSignIn(
      scopes: ['email'],
      // Web lit l'audience du token via `clientId`; Android/iOS via `serverClientId`
      // (pour obtenir un idToken dont l'audience correspond au GOOGLE_CLIENT_ID backend).
      clientId: kIsWeb ? AppConstants.googleClientId : null,
      serverClientId: !kIsWeb ? AppConstants.googleClientId : null,
    );
  }

  Future<void> _restoreSession() async {
    final token = await _storage.readToken();
    if (token == null) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }
    try {
      final user = await _api.me(token);
      state = state.copyWith(status: AuthStatus.authenticated, token: token, user: user);
    } on ApiException {
      // Token expired/invalid: drop it and send the user back to login.
      await _storage.clearToken();
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> login(String email, String password) =>
      _run(() => _api.login(email: email, password: password));

  Future<bool> register(String email, String password, String? fullName) =>
      _run(() => _api.register(email: email, password: password, fullName: fullName));

  Future<bool> verifyOtp(String email, String code) =>
      _run(() => _api.verifyOtp(email: email, code: code));

  Future<bool> requestOtp(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _api.requestOtp(email);
      state = state.copyWith(isLoading: false);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    final googleSignIn = _ensureGoogleSignIn();
    if (googleSignIn == null) {
      state = state.copyWith(
        errorMessage: 'Google Sign-In non configuré (GOOGLE_CLIENT_ID manquant).',
      );
      return false;
    }
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final account = await googleSignIn.signIn();
      if (account == null) {
        // User cancelled the picker.
        state = state.copyWith(isLoading: false);
        return false;
      }
      final googleAuth = await account.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Google Sign-In non configuré (GOOGLE_CLIENT_ID manquant).',
        );
        return false;
      }
      return await _run(() => _api.loginWithGoogle(idToken));
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Connexion Google impossible. Réessayez.',
      );
      return false;
    }
  }

  Future<bool> _run(Future<AuthResult> Function() action) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await action();
      await _storage.saveToken(result.accessToken);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: result.user,
        token: result.accessToken,
        isLoading: false,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.clearToken();
    await _googleSignIn?.signOut();
    state = state.copyWith(status: AuthStatus.unauthenticated, user: null, token: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(AuthApiService(), TokenStorage());
});
