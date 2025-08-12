import 'dart:async';
import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart' as fb;

/// FirebaseAuthService mirrors the surface area of the existing AuthService
/// with `Map<String, dynamic>` results so the Provider/UI can migrate gradually.
class FirebaseAuthService {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;

  Future<bool> isLoggedIn() async {
    return _auth.currentUser != null;
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return {
      'success': true,
      'data': {
        'user': {
          'id': user.uid,
          'full_name': user.displayName,
          'username': user.displayName,
          'email': user.email,
          'phone_number': user.phoneNumber,
          'profile_picture': user.photoURL,
          // Role/flags are backend-specific; fill after backend profile fetch.
          'role': 'member',
          'is_active': true,
          'created_at': user.metadata.creationTime?.toIso8601String(),
          'updated_at': user.metadata.lastSignInTime?.toIso8601String(),
        },
      },
    };
  }

  // Email/password login
  Future<Map<String, dynamic>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return {
        'success': true,
        'data': {'user': _serializeUser(cred.user)},
        'message': 'Login successful',
      };
    } on fb.FirebaseAuthException catch (e) {
      return _handleFbAuthError(e);
    } catch (e) {
      return {'success': false, 'message': 'An error occurred'};
    }
  }

  // Email/password sign up
  Future<Map<String, dynamic>> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (fullName != null && fullName.isNotEmpty) {
        await cred.user?.updateDisplayName(fullName);
      }
      // Send email verification (optional policy)
      await cred.user?.sendEmailVerification();
      return {
        'success': true,
        'data': {'user': _serializeUser(cred.user)},
        'message': 'Registration successful. Please verify your email.',
      };
    } on fb.FirebaseAuthException catch (e) {
      return _handleFbAuthError(e);
    } catch (e) {
      return {'success': false, 'message': 'An error occurred'};
    }
  }

  // Start phone verification; UI should capture code then call confirmSmsCode
  Future<Map<String, dynamic>> startPhoneVerification({
    required String phoneNumber,
  }) async {
    try {
      String? verificationId;
      int? latestResendToken;
      final completer = Completer<Map<String, dynamic>>();
      // Safety fallback: don't let the UI hang forever if no callbacks arrive
      Timer(const Duration(seconds: 45), () {
        if (!completer.isCompleted) {
          completer.complete({
            'success': false,
            'message':
                'Network timeout. Please check your connection and try again.',
          });
        }
      });

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (fb.PhoneAuthCredential credential) async {
          try {
            final cred = await _auth.signInWithCredential(credential);
            completer.complete({
              'success': true,
              'requiresOtp': false,
              'data': {'user': _serializeUser(cred.user)},
              'message': 'Phone verified',
            });
          } catch (e) {
            completer.complete({'success': false, 'message': 'Sign-in failed'});
          }
        },
        verificationFailed: (fb.FirebaseAuthException e) {
          final message = e.message ?? 'Verification failed';
          completer.complete({'success': false, 'message': message});
        },
        codeSent: (String verId, int? resendToken) {
          verificationId = verId;
          latestResendToken = resendToken;
          completer.complete({
            'success': true,
            'requiresOtp': true,
            'verificationId': verificationId,
            'resendToken': latestResendToken,
            'message': 'OTP sent to your phone number',
          });
        },
        codeAutoRetrievalTimeout: (String verId) {
          verificationId = verId;
          // If we got a verificationId but never delivered codeSent, still allow OTP entry
          if (!completer.isCompleted) {
            completer.complete({
              'success': true,
              'requiresOtp': true,
              'verificationId': verificationId,
              'resendToken': latestResendToken,
              'message': 'Enter the code sent to your phone number',
            });
          }
        },
      );

      return await completer.future;
    } on fb.FirebaseAuthException catch (e) {
      return _handleFbAuthError(e);
    } catch (e) {
      return {'success': false, 'message': 'An error occurred'};
    }
  }

  // Resend OTP using forceResendingToken if available
  Future<Map<String, dynamic>> resendPhoneVerification({
    required String phoneNumber,
    int? forceResendingToken,
  }) async {
    try {
      String? verificationId;
      int? latestResendToken;
      final completer = Completer<Map<String, dynamic>>();
      // Safety fallback timer
      Timer(const Duration(seconds: 45), () {
        if (!completer.isCompleted) {
          completer.complete({
            'success': false,
            'message': 'Network timeout. Please try again.',
          });
        }
      });

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        forceResendingToken: forceResendingToken,
        verificationCompleted: (fb.PhoneAuthCredential credential) async {
          // We don't auto-complete on resend; just acknowledge code sent
        },
        verificationFailed: (fb.FirebaseAuthException e) {
          final message = e.message ?? 'Resend failed';
          completer.complete({'success': false, 'message': message});
        },
        codeSent: (String verId, int? resendToken) {
          verificationId = verId;
          latestResendToken = resendToken;
          completer.complete({
            'success': true,
            'verificationId': verificationId,
            'resendToken': latestResendToken,
            'message': 'OTP resent to your phone number',
          });
        },
        codeAutoRetrievalTimeout: (String verId) {
          verificationId = verId;
          if (!completer.isCompleted) {
            completer.complete({
              'success': true,
              'verificationId': verificationId,
              'resendToken': latestResendToken,
              'message': 'You can enter the code now',
            });
          }
        },
      );

      return await completer.future;
    } on fb.FirebaseAuthException catch (e) {
      return _handleFbAuthError(e);
    } catch (e) {
      return {'success': false, 'message': 'An error occurred'};
    }
  }

  // Confirm OTP for phone auth
  Future<Map<String, dynamic>> confirmSmsCode({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = fb.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final cred = await _auth.signInWithCredential(credential);
      return {
        'success': true,
        'data': {'user': _serializeUser(cred.user)},
        'message': 'OTP verified successfully',
      };
    } on fb.FirebaseAuthException catch (e) {
      return _handleFbAuthError(e);
    } catch (e) {
      return {'success': false, 'message': 'An error occurred'};
    }
  }

  Future<Map<String, dynamic>> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return {'success': true, 'message': 'Password reset email sent'};
    } on fb.FirebaseAuthException catch (e) {
      return _handleFbAuthError(e);
    } catch (e) {
      return {'success': false, 'message': 'An error occurred'};
    }
  }

  Future<String?> getIdToken({bool forceRefresh = false}) async {
    try {
      final user = _auth.currentUser;
      return await user?.getIdToken(forceRefresh);
    } catch (e) {
      developer.log('getIdToken error: $e', name: 'FirebaseAuthService');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Map<String, dynamic> _handleFbAuthError(fb.FirebaseAuthException e) {
    final code = e.code;
    String message = 'Authentication error';
    switch (code) {
      case 'invalid-email':
        message = 'The email address is invalid';
        break;
      case 'user-disabled':
        message = 'This user account has been disabled';
        break;
      case 'user-not-found':
        message = 'No user found for the given credentials';
        break;
      case 'wrong-password':
        message = 'Incorrect password';
        break;
      case 'email-already-in-use':
        message = 'This email is already in use';
        break;
      case 'weak-password':
        message = 'Password is too weak';
        break;
      case 'too-many-requests':
        message = 'Too many attempts. Try again later';
        break;
      case 'invalid-verification-code':
        message = 'Invalid OTP code';
        break;
      case 'invalid-verification-id':
        message = 'Invalid verification ID';
        break;
      default:
        message = e.message ?? message;
    }
    return {'success': false, 'message': message};
  }

  Map<String, dynamic>? _serializeUser(fb.User? user) {
    if (user == null) return null;
    return {
      'id': user.uid,
      'full_name': user.displayName,
      'username': user.displayName,
      'email': user.email,
      'phone_number': user.phoneNumber,
      'profile_picture': user.photoURL,
      'email_verified': user.emailVerified,
      'role': 'member',
      'is_active': true,
      'created_at': user.metadata.creationTime?.toIso8601String(),
      'updated_at': user.metadata.lastSignInTime?.toIso8601String(),
    };
  }
}
