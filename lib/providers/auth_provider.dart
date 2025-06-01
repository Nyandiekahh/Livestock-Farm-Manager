import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthProvider() {
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  // Sign up with email and password
  Future<bool> signUp(String email, String password, String name) async {
    try {
      _setLoading(true);

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update user profile with name
      await credential.user?.updateDisplayName(name);

      _user = credential.user;
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('An unexpected error occurred');
      return false;
    }
  }

  // Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    try {
      _setLoading(true);

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = credential.user;
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('An unexpected error occurred');
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);

      await _auth.signOut();

      // Clear local data
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      _user = null;
      _setLoading(false);
    } catch (e) {
      _setError('Failed to sign out');
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);

      await _auth.sendPasswordResetEmail(email: email);

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('Failed to send reset email');
      return false;
    }
  }

  // Update user profile
  Future<bool> updateProfile(String name) async {
    try {
      _setLoading(true);

      await _user?.updateDisplayName(name);
      await _user?.reload();
      _user = _auth.currentUser;

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update profile');
      return false;
    }
  }

  // Change password
  Future<bool> changePassword(
      String currentPassword, String newPassword) async {
    try {
      _setLoading(true);

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: _user!.email!,
        password: currentPassword,
      );

      await _user!.reauthenticateWithCredential(credential);

      // Update password
      await _user!.updatePassword(newPassword);

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('Failed to change password');
      return false;
    }
  }

  // Delete account
  Future<bool> deleteAccount(String password) async {
    try {
      _setLoading(true);

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: _user!.email!,
        password: password,
      );

      await _user!.reauthenticateWithCredential(credential);

      // Delete user account
      await _user!.delete();

      // Clear local data
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      _user = null;
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('Failed to delete account');
      return false;
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) _error = null;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get user-friendly error messages
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'The password is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'operation-not-allowed':
        return 'Operation not allowed. Please contact support.';
      case 'requires-recent-login':
        return 'This operation is sensitive and requires recent authentication.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
