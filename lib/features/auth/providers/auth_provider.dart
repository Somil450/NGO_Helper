import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/token_service.dart';

/// AuthProvider using Firebase Auth + SharedPreferences only.
/// Does NOT require Firestore — works even without a Firestore database.
class AuthProvider extends ChangeNotifier {
  UserModel? _userModel;
  bool _isLoading = false;
  String? _error;
  
  String? _currentOtp;
  OAuthCredential? _pendingGoogleCredential;
  String? _pendingGoogleEmail;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _webClientId =
      '830664055084-1qqjc39n600pv12lt9uq3em7p6t7d3f0.apps.googleusercontent.com';

  // SharedPreferences keys
  static const String _keyUserType = 'user_type';
  static const String _keyIsOnboarded = 'is_onboarded';
  static const String _keyUserDetails = 'user_details';

  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _userModel != null;
  bool get isOnboarded => _userModel?.isOnboarded ?? false;
  String? get userType => _userModel?.userType;
  String? get uid => _userModel?.uid;
  
  String? get pendingGoogleEmail => _pendingGoogleEmail;

  AuthProvider() {
    _init();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> _init() async {
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        await _loadUserModel(user);
      } else {
        _userModel = null;
        await TokenService.deleteToken();
        notifyListeners();
      }
    });
  }

  /// Load user model from SharedPreferences (no Firestore needed)
  Future<void> _loadUserModel(User firebaseUser) async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userType = prefs.getString('role_${firebaseUser.uid}') ?? prefs.getString(_keyUserType) ?? 'ngo';
      final isOnboarded = prefs.getBool(_keyIsOnboarded) ?? false;

      _userModel = UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        userType: userType,
        isOnboarded: isOnboarded,
      );
    } catch (e) {
      debugPrint('Error loading user model: $e');
      // Fallback: create a basic model from Firebase Auth
      _userModel = UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        userType: 'ngo',
        isOnboarded: false,
      );
    }
    _setLoading(false);
  }

  /// Save user data locally
  Future<void> _saveUserLocally({
    required String uid,
    required String userType,
    required bool isOnboarded,
    Map<String, dynamic>? details,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserType, userType);
    await prefs.setString('role_$uid', userType);
    await prefs.setBool(_keyIsOnboarded, isOnboarded);
    if (details != null) {
      await prefs.setString(_keyUserDetails, jsonEncode(details));
    }
  }

  /// Check if email already exists in Firebase Auth
  Future<bool> checkEmail(String email) async {
    // Note: fetchSignInMethodsForEmail is blocked by default in new Firebase projects
    // (Email Enumeration Protection), causing fake "Network errors".
    // We bypass this check and let signUpWithEmail handle 'email-already-in-use' natively.
    return true;
  }

  /// Sign up with email + password. Sends email verification. Saves user info locally.
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String userType,
    Map<String, dynamic>? details,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Failed to create user.');
      }

      // Save user type and details locally
      await _saveUserLocally(
        uid: firebaseUser.uid,
        userType: userType,
        isOnboarded: details != null && details.isNotEmpty,
        details: details,
      );

      _userModel = UserModel(
        uid: firebaseUser.uid,
        email: email,
        userType: userType,
        isOnboarded: details != null && details.isNotEmpty,
      );

      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _friendlyFirebaseError(e);
      _setLoading(false);
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred.';
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  String? _verificationId;

  /// Send a 6 digit custom OTP via SMS using Firebase Phone Auth
  Future<bool> sendPhoneOtp(String phone) async {
    _setLoading(true);
    _error = null;
    Completer<bool> completer = Completer();
    
    // --- BYPASS FOR DEVELOPMENT / TESTING ---
    if (phone.endsWith('0000000000') || phone.endsWith('6266788264')) {
      await Future.delayed(const Duration(seconds: 1));
      _verificationId = 'mock_verification_id';
      _setLoading(false);
      return true;
    }
    // ----------------------------------------
    
    // Ensure phone number has country code. Assuming India (+91) for this app if missing.
    String formattedPhone = phone.trim();
    if (!formattedPhone.startsWith('+')) {
      formattedPhone = '+91$formattedPhone';
    }

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Android auto-retrieval
          // We let the user enter it manually to be safe across all devices
        },
        verificationFailed: (FirebaseAuthException e) {
          _error = e.message ?? 'Phone verification failed';
          if (!completer.isCompleted) completer.complete(false);
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          if (!completer.isCompleted) completer.complete(true);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
      
      final result = await completer.future;
      _setLoading(false);
      return result;
    } catch (e) {
      _error = 'Failed to send OTP to mobile. Please check the number.';
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// Verify Phone OTP and immediately link with Email/Password to complete Signup
  Future<bool> verifyPhoneOtpAndSignUp({
    required String otp,
    required String email,
    required String password,
    required String userType,
    Map<String, dynamic>? details,
  }) async {
    if (_verificationId == null) {
      _error = 'Session expired. Please try again.';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _error = null;
    
    // --- BYPASS FOR DEVELOPMENT / TESTING ---
    if (_verificationId == 'mock_verification_id') {
      try {
        final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
        final user = userCredential.user!;
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('role_${user.uid}', userType);
        
        await _saveUserLocally(
          uid: user.uid,
          userType: userType,
          isOnboarded: details != null && details.isNotEmpty,
          details: details,
        );
        
        await _loadUserModel(user);
        _setLoading(false);
        notifyListeners();
        return true;
      } on FirebaseAuthException catch (e) {
        _error = _friendlyFirebaseError(e, userType);
        _setLoading(false);
        notifyListeners();
        return false;
      } catch (e) {
        _error = 'Mock verification failed: $e';
        _setLoading(false);
        notifyListeners();
        return false;
      }
    }
    // ----------------------------------------
    
    try {
      // 1. Create the phone credential
      final phoneCredential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp.trim(),
      );
      
      // 2. Sign in with Phone Credential to verify OTP natively
      final userCredential = await _auth.signInWithCredential(phoneCredential);
      final user = userCredential.user;
      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      
      if (user == null) {
        throw Exception("Verification failed");
      }
      
      // If the phone number is already used by an existing account, block signup
      if (!isNewUser) {
        _error = 'This phone number is already registered to another account.';
        await _auth.signOut();
        _setLoading(false);
        notifyListeners();
        return false;
      }
      
      // 3. Link the Email and Password to this new phone-verified account
      try {
        await user.linkWithCredential(EmailAuthProvider.credential(email: email, password: password));
      } on FirebaseAuthException catch (linkError) {
        // If email linking fails (e.g. email already in use), cleanup the empty phone account
        await user.delete();
        _error = _friendlyFirebaseError(linkError, userType);
        _setLoading(false);
        notifyListeners();
        return false;
      }
      
      // 4. Registration successful, save local role state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('role_${user.uid}', userType);
      
      // Simulate saving details
      if (details != null) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
      
      await _saveUserLocally(
        uid: user.uid,
        userType: userType,
        isOnboarded: details != null && details.isNotEmpty,
        details: details,
      );
      
      await _loadUserModel(user);

      _setLoading(false);
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _friendlyFirebaseError(e, userType);
      _setLoading(false);
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Invalid or expired OTP code.';
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// Sign in with email + password
  Future<bool> signInWithEmail({
    required String email,
    required String password,
    required String expectedUserType,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Check role locally across current device
      if (credential.user != null) {
        final prefs = await SharedPreferences.getInstance();
        final registeredType = prefs.getString('role_${credential.user!.uid}');
        
        if (registeredType != null && registeredType != expectedUserType) {
          await _auth.signOut();
          _error = 'Mail not registered as ${expectedUserType == "ngo" ? "NGO Partner" : "Food Donor"}.';
          _setLoading(false);
          notifyListeners();
          return false;
        } else if (registeredType == null) {
          await prefs.setString('role_${credential.user!.uid}', expectedUserType);
        }

        await _loadUserModel(credential.user!);

        // Force isOnboarded=true for existing accounts that login via email/password,
        // ensuring they go straight to the dashboard even if SharedPreferences is cleared.
        if (_userModel != null && !_userModel!.isOnboarded) {
          _userModel = UserModel(
            uid: _userModel!.uid,
            email: _userModel!.email,
            userType: _userModel!.userType,
            isOnboarded: true,
          );
        }
      }
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _friendlyFirebaseError(e, expectedUserType);
      _setLoading(false);
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred.';
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// Sign in with Google — NO Firestore required
  Future<bool> signInWithGoogle({
    required String userType,
    required bool isLogin,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      final googleSignIn = GoogleSignIn();

      // Sign out first to force account picker every time
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled
        _setLoading(false);
        return false;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null) {
        _error =
            'Google Sign-In failed: could not get ID token. Please try again.';
        _setLoading(false);
        notifyListeners();
        return false;
      }

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        _error = 'Google Sign-In failed. Please try again.';
        _setLoading(false);
        notifyListeners();
        return false;
      }

      // Check if this is a new sign-up (first time) or existing login
      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      if (isNewUser) {
        // New user — save their role locally, mark as NOT onboarded yet
        await _saveUserLocally(
          uid: user.uid,
          userType: userType,
          isOnboarded: false,
        );
        _userModel = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          userType: userType,
          isOnboarded: false,
        );
      } else {
        // Check role
        final prefs = await SharedPreferences.getInstance();
        final registeredType = prefs.getString('role_${user.uid}');
        
        if (registeredType != null && registeredType != userType) {
          await _auth.signOut();
          _error = 'Mail not registered as ${userType == "ngo" ? "NGO Partner" : "Food Donor"}.';
          _setLoading(false);
          notifyListeners();
          return false;
        } else if (registeredType == null) {
          await prefs.setString('role_${user.uid}', userType);
        }

        // Existing user — load from local storage
        await _loadUserModel(user);

        // Force isOnboarded=true for existing Google users so they go directly to the dashboard,
        // even if they reinstalled the app and SharedPreferences is empty.
        if (_userModel != null && !_userModel!.isOnboarded) {
          _userModel = UserModel(
            uid: _userModel!.uid,
            email: _userModel!.email,
            userType: _userModel!.userType,
            isOnboarded: true,
          );
        }
      }

      _setLoading(false);
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        _pendingGoogleCredential = e.credential as OAuthCredential?;
        _pendingGoogleEmail = e.email;
        _error = 'REQUIRES_PASSWORD';
        _setLoading(false);
        notifyListeners();
        return false;
      }
      _error = _friendlyFirebaseError(e);
      _setLoading(false);
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Google Sign-In failed: $e';
      debugPrint('Google Sign-In error: $e');
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// Links a pending Google sign-in with an existing Email/Password account
  Future<bool> linkPendingGoogleAccount({
    required String password,
    required String expectedUserType,
  }) async {
    if (_pendingGoogleEmail == null || _pendingGoogleCredential == null) {
      _error = 'No pending Google sign-in found.';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _error = null;
    try {
      // 1. Sign in with the existing email and provided password
      final credential = await _auth.signInWithEmailAndPassword(
        email: _pendingGoogleEmail!,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        // 2. Link the pending Google credential
        try {
          await user.linkWithCredential(_pendingGoogleCredential!);
        } catch (e) {
          debugPrint('Error linking credential (may already be linked): $e');
        }

        // 3. Check role strictly
        final prefs = await SharedPreferences.getInstance();
        final registeredType = prefs.getString('role_${user.uid}');
        
        if (registeredType != null && registeredType != expectedUserType) {
          await _auth.signOut();
          _error = 'Mail not registered as ${expectedUserType == "ngo" ? "NGO Partner" : "Food Donor"}.';
          _setLoading(false);
          notifyListeners();
          return false;
        } else if (registeredType == null) {
          await prefs.setString('role_${user.uid}', expectedUserType);
        }

        await _loadUserModel(user);

        // Force isOnboarded=true since they are logging into an existing account
        if (_userModel != null && !_userModel!.isOnboarded) {
          _userModel = UserModel(
            uid: _userModel!.uid,
            email: _userModel!.email,
            userType: _userModel!.userType,
            isOnboarded: true,
          );
        }
        
        // Clear pending data
        _pendingGoogleCredential = null;
        _pendingGoogleEmail = null;
        
        _setLoading(false);
        notifyListeners();
        return true;
      }
      _error = 'Failed to sign in with email.';
      _setLoading(false);
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      _error = _friendlyFirebaseError(e, expectedUserType);
      _setLoading(false);
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to link account. Please try again.';
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// Verifies the app password for an already signed-in Google user
  Future<bool> verifyGooglePassword(String password) async {
    if (_userModel == null || _auth.currentUser == null) return false;
    _setLoading(true);
    _error = null;
    try {
      final credential = EmailAuthProvider.credential(
        email: _userModel!.email,
        password: password,
      );
      await _auth.currentUser!.reauthenticateWithCredential(credential);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _error = 'Incorrect password.';
      _setLoading(false);
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Verification failed.';
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// Logs out the user profile — saves locally only
  Future<bool> updateProfile(
    Map<String, dynamic> details, {
    String? password,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _error = 'Not authenticated';
        _setLoading(false);
        notifyListeners();
        return false;
      }

      // If Google user provided a password, link Email/Password provider
      if (password != null && password.isNotEmpty) {
        try {
          final emailCredential = EmailAuthProvider.credential(
            email: user.email!,
            password: password,
          );
          await user.linkWithCredential(emailCredential);
        } catch (e) {
          debugPrint('Failed to link credential (may already be linked): $e');
        }
      }

      final currentType = _userModel?.userType ?? 'ngo';
      await _saveUserLocally(
        uid: user.uid,
        userType: currentType,
        isOnboarded: true,
        details: details,
      );

      _userModel = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        userType: currentType,
        isOnboarded: true,
      );

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Profile update failed: $e';
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// Reset Password
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _error = null;
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _setLoading(false);
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _friendlyFirebaseError(e);
      _setLoading(false);
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to send password reset email.';
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await GoogleSignIn().signOut();
      await _auth.signOut();
      _userModel = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyUserType);
      await prefs.remove(_keyIsOnboarded);
      await prefs.remove(_keyUserDetails);
      await TokenService.deleteToken();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
    _setLoading(false);
  }

  String _friendlyFirebaseError(FirebaseAuthException e, [String? expectedUserType]) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email. Please sign up.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password. Please try again.';
      case 'email-already-in-use':
        return 'This email is already registered. Please sign in.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email using a different sign-in method.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}
