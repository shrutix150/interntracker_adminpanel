import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../firebase_options.dart';

class AdminAuthController extends ChangeNotifier {
  AdminAuthController._();

  static final AdminAuthController instance = AdminAuthController._();

  bool _initialized = false;
  bool _isAuthenticated = false;
  String? _email;
  String? _token;

  bool get initialized => _initialized;
  bool get isAuthenticated => _isAuthenticated;
  String? get email => _email;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    notifyListeners();
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final Uri uri = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${DefaultFirebaseOptions.currentPlatform.apiKey}',
    );

    try {
      final http.Response response = await http.post(
        uri,
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(<String, dynamic>{
          'email': email.trim(),
          'password': password,
          'returnSecureToken': true,
        }),
      );

      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode >= 400) {
        throw AdminAuthException(_mapRestError(body['error']));
      }

      final bool isAdmin = await _hasAdminAccess(
        email: email.trim(),
        uid: body['localId'] as String? ?? '',
      );
      if (!isAdmin) {
        throw const AdminAuthException(
          'Access denied. This account does not have role = admin in the user collection.',
        );
      }

      _email = email.trim();
      _token = body['idToken'] as String? ?? '';
      _isAuthenticated = true;
      _initialized = true;
      notifyListeners();
    } on AdminAuthException {
      rethrow;
    } on FirebaseException catch (error) {
      throw AdminAuthException(
        'Firestore error while verifying admin access: ${error.message ?? error.code}',
      );
    } on http.ClientException catch (error) {
      throw AdminAuthException('Network error: ${error.message}');
    } on FormatException {
      throw const AdminAuthException(
        'Unexpected sign-in response from Firebase. Please try again.',
      );
    } catch (error) {
      throw AdminAuthException('Unexpected sign-in error: $error');
    }
  }

  Future<void> signOut() async {
    _email = null;
    _token = null;
    _isAuthenticated = false;
    _initialized = true;
    notifyListeners();
  }

  Future<String> createManagedUser({
    required String name,
    required String email,
    required String password,
    required String role,
    required String phoneNumber,
    required String department,
    required String employeeId,
  }) async {
    final Uri uri = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${DefaultFirebaseOptions.currentPlatform.apiKey}',
    );

    try {
      final http.Response response = await http.post(
        uri,
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(<String, dynamic>{
          'email': email.trim(),
          'password': password,
          'returnSecureToken': true,
        }),
      );

      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode >= 400) {
        throw AdminAuthException(_mapRestError(body['error']));
      }

      final String uid = body['localId'] as String? ?? '';
      if (uid.isEmpty) {
        throw const AdminAuthException('Unable to create user account UID.');
      }

      await FirebaseFirestore.instance.collection('user').doc(uid).set(<String, dynamic>{
        'name': name.trim(),
        'fullName': name.trim(),
        'email': email.trim(),
        'phoneNumber': phoneNumber.trim(),
        'department': department.trim(),
        'employeeId': employeeId.trim(),
        'role': role.trim().toLowerCase(),
        'status': 'Approved',
        'isApproved': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return uid;
    } on AdminAuthException {
      rethrow;
    } on FirebaseException catch (error) {
      throw AdminAuthException(
        'Firestore error while saving the user profile: ${error.message ?? error.code}',
      );
    } on http.ClientException catch (error) {
      throw AdminAuthException('Network error: ${error.message}');
    } on FormatException {
      throw const AdminAuthException(
        'Unexpected user creation response from Firebase.',
      );
    } catch (error) {
      throw AdminAuthException('Unexpected account creation error: $error');
    }
  }

  Future<bool> _hasAdminAccess({
    required String email,
    required String uid,
  }) async {
    final CollectionReference<Map<String, dynamic>> users =
        FirebaseFirestore.instance.collection('user');

    if (uid.isNotEmpty) {
      final DocumentSnapshot<Map<String, dynamic>> userDoc =
          await users.doc(uid).get();
      if (userDoc.exists) {
        final String role =
            (userDoc.data()?['role'] ?? '').toString().trim().toLowerCase();
        if (role == 'admin') {
          return true;
        }
      }
    }

    final QuerySnapshot<Map<String, dynamic>> snapshot = await users
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return false;
    }

    final String role =
        (snapshot.docs.first.data()['role'] ?? '').toString().trim().toLowerCase();
    return role == 'admin';
  }

  String _mapRestError(dynamic error) {
    final String code = ((error as Map<String, dynamic>?)?['message'] ?? '')
        .toString()
        .trim()
        .toUpperCase();

    switch (code) {
      case 'EMAIL_NOT_FOUND':
      case 'INVALID_PASSWORD':
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'Incorrect email or password.';
      case 'USER_DISABLED':
        return 'This admin account has been disabled.';
      case 'TOO_MANY_ATTEMPTS_TRY_LATER':
        return 'Too many attempts. Please try again later.';
      case 'OPERATION_NOT_ALLOWED':
        return 'Email/password sign-in is not enabled in Firebase Authentication.';
      case 'CONFIGURATION_NOT_FOUND':
        return 'Firebase Authentication is not configured correctly for this app.';
      case 'USER_NOT_FOUND':
        return 'This admin account was not found in Firebase Authentication.';
      default:
        return 'Firebase sign-in failed: $code';
    }
  }
}

class AdminAuthException implements Exception {
  const AdminAuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
