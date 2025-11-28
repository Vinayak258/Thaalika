import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/mess_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final UserService _userService;
  final MessService _messService;

  UserModel? _user;
  UserModel? get user => _user;

  bool get isAuthenticated => _user != null;

  AuthProvider(this._authService, this._userService, this._messService);

  // Email/Password Sign In (Backup method)
  Future<bool> signIn(String email, String password) async {
    try {
      final credential =
          await _authService.signInWithEmailAndPassword(email, password);

      if (!credential.user!.emailVerified) {
        await _authService.signOut();
        throw FirebaseAuthException(
          code: 'email-not-verified',
          message: 'Please verify your email before logging in.',
        );
      }

      final uid = credential.user!.uid;
      _user = await _userService.fetchUser(uid);

      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      print("LOGIN ERROR: ${e.code} - ${e.message}");
      if (e.code == 'invalid-credential' || e.code == 'user-not-found' || e.code == 'wrong-password') {
        await _authService.signOut();
      }
      rethrow;
    } catch (e) {
      print("LOGIN ERROR: $e");
      rethrow;
    }
  }

  // Phone OTP Methods
  Future<void> sendOtp(
    String phoneNumber, {
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
    Function(PhoneAuthCredential credential)? onAutoVerify,
  }) async {
    await _authService.sendOtp(
      phoneNumber,
      onCodeSent: onCodeSent,
      onError: onError,
      onAutoVerify: onAutoVerify,
    );
  }

  Future<User?> signInWithOtp({
    String? verificationId,
    String? smsCode,
    PhoneAuthCredential? credential,
  }) async {
    try {
      User? firebaseUser;
      
      if (credential != null) {
        // Auto-verification
        firebaseUser = await _authService.signInWithCredential(credential);
      } else if (verificationId != null && smsCode != null) {
        // Manual verification
        firebaseUser = await _authService.verifyOtp(verificationId, smsCode);
      }

      if (firebaseUser != null) {
        // Fetch or create user document
        UserModel? userModel = await _userService.fetchUser(firebaseUser.uid);
        
        if (userModel == null) {
          // Create basic user document if it doesn't exist
          userModel = UserModel(
            uid: firebaseUser.uid,
            name: firebaseUser.displayName ?? 'User',
            phone: firebaseUser.phoneNumber ?? '',
            email: firebaseUser.email ?? '',
            role: 'student', // Default role
            wallet: 500.0,
            coupons: {},
          );
          await _userService.createUser(userModel);
        }

        _user = userModel;
        notifyListeners();
        return firebaseUser;
      }
      return null;
    } catch (e) {
      print("OTP SIGN IN ERROR: $e");
      rethrow;
    }
  }

  Future<bool> signUpWithOtp({
    required String name,
    required String phone,
    String? email,
    required String role,
    String? verificationId,
    String? smsCode,
    PhoneAuthCredential? credential,
  }) async {
    try {
      User? firebaseUser;
      
      if (credential != null) {
        firebaseUser = await _authService.signInWithCredential(credential);
      } else if (verificationId != null && smsCode != null) {
        firebaseUser = await _authService.verifyOtp(verificationId, smsCode);
      }

      if (firebaseUser == null) {
        return false;
      }

      final uid = firebaseUser.uid;

      // Check if user already exists
      final existingUser = await _userService.fetchUser(uid);
      if (existingUser != null) {
        _user = existingUser;
        notifyListeners();
        return true;
      }

      // Prepare user data based on role
      double wallet = 0.0;
      Map<String, int> coupons = {};
      String? messId;

      if (role == 'student') {
        wallet = 500.0;
        coupons = {};
      } else if (role == 'owner') {
        wallet = 0.0;
        coupons = {};
        messId = null;
      }

      // Create UserModel
      final userModel = UserModel(
        uid: uid,
        name: name,
        phone: phone,
        email: email ?? '',
        role: role,
        wallet: wallet,
        coupons: coupons,
        messId: messId,
      );

      // Save to Firestore
      await _userService.createUser(userModel);

      _user = userModel;
      notifyListeners();
      
      // Sign out after registration (user needs to login)
      await _authService.signOut();
      _user = null;
      notifyListeners();
      
      return true;
    } catch (e) {
      print("SIGNUP ERROR: $e");
      return false;
    }
  }

  /// Get redirect screen based on role and mess profile existence
  Future<String> getRedirectScreen() async {
    if (_user == null) return "/";
    
    switch (_user!.role) {
      case "student":
        return "/student-dashboard";
      case "owner":
        final mess = await _messService.fetchMessByOwnerUid(_user!.uid);
        if (mess == null) {
          return "/create-mess-profile";
        }
        return "/owner-dashboard";
      default:
        return "/";
    }
  }

  // Email/Password Sign Up (Backup method)
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
  }) async {
    try {
      final credential = await _authService.createUserWithEmailAndPassword(email, password);
      final uid = credential.user!.uid;

      double wallet = 0.0;
      Map<String, int> coupons = {};
      String? messId;

      if (role == 'student') {
        wallet = 500.0;
        coupons = {};
      } else if (role == 'owner') {
        wallet = 0.0;
        coupons = {};
        messId = null;
      }

      final userModel = UserModel(
        uid: uid,
        name: name,
        email: email,
        phone: phone,
        role: role,
        wallet: wallet,
        coupons: coupons,
        messId: messId,
      );

      await _userService.createUser(userModel);

      _user = userModel;
      notifyListeners();
      
      if (credential.user != null && !credential.user!.emailVerified) {
        await _authService.sendEmailVerification(credential.user!);
      }
      
      return true;
    } catch (e) {
      print("SIGNUP ERROR: $e");
      return false;
    }
  }

  void updateUser(UserModel updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }
}
