import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../core/services/auth_service.dart';

final authProvider = StateNotifierProvider<AuthNotifier, GoogleSignInAccount?>((ref) {
  return AuthNotifier(AuthService());
});

class AuthNotifier extends StateNotifier<GoogleSignInAccount?> {
  AuthNotifier(this._authService) : super(null);

  final AuthService _authService;

  Future<void> signIn() async {
    state = await _authService.signIn();
  }
}
