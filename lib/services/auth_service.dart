import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // Email/Password Authentication (Backup method)
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> createUserWithEmailAndPassword(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  // Phone OTP Authentication (Primary method)
  Future<void> sendOtp(
    String phoneNumber, {
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
    Function(PhoneAuthCredential credential)? onAutoVerify,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification (Android only)
          if (onAutoVerify != null) {
            onAutoVerify(credential);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          String errorMessage = 'Verification failed';
          if (e.code == 'invalid-phone-number') {
            errorMessage = 'Invalid phone number format';
          } else if (e.code == 'too-many-requests') {
            errorMessage = 'Too many requests. Please try again later';
          } else {
            errorMessage = e.message ?? 'Verification failed';
          }
          onError(errorMessage);
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Timeout - do nothing
        },
      );
    } catch (e) {
      onError('Error sending OTP: ${e.toString()}');
    }
  }

  Future<User?> verifyOtp(String verificationId, String smsCode) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      
      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print('OTP Verification Error: $e');
      rethrow;
    }
  }

  Future<User?> signInWithCredential(PhoneAuthCredential credential) async {
    try {
      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print('Sign in with credential error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> sendEmailVerification(User user) async {
    await user.sendEmailVerification();
  }

  Future<void> reloadUser(User user) async {
    await user.reload();
  }
}
