import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  // Initialize GoogleSignIn without client ID for development
  // Only configure client ID in production builds
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // 🔹 Sign in with Google
  Future<UserCredential?> loginWithGoogle() async {
    try {
      if (kIsWeb) {
        // 🔹 Web sign-in
        try {
          // For web, use Firebase's direct auth provider instead of GoogleSignIn
          GoogleAuthProvider authProvider = GoogleAuthProvider();
          UserCredential userCredential =
              await FirebaseAuth.instance.signInWithPopup(authProvider);
          return userCredential;
        } catch (e) {
          if (kDebugMode) print('Web Google Sign-In Error: $e');
          // For development, just handle the error gracefully
          return null;
        }
      } else {
        // 🔹 Mobile sign-in
        try {
          await _googleSignIn.signOut(); // Ensure user selection prompt
          final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
          if (googleUser == null) return null; // User canceled sign-in
  
          final GoogleSignInAuthentication googleAuth =
              await googleUser.authentication;
          final AuthCredential credential = GoogleAuthProvider.credential(
            idToken: googleAuth.idToken,
            accessToken: googleAuth.accessToken,
          );
  
          return await _firebaseAuth.signInWithCredential(credential);
        } catch (e) {
          if (kDebugMode) print('Mobile Google Sign-In Error: $e');
          return null;
        }
      }
    } catch (e) {
      if (kDebugMode) print('Google Sign-In Error: $e');
      return null;
    }
  }

  // 🔹 Web-specific sign in with Google (Used only when explicitly needed)
  Future<UserCredential?> signInWithGoogleWeb() async {
    try {
      GoogleAuthProvider authProvider = GoogleAuthProvider();
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithPopup(authProvider);
      return userCredential;
    } catch (e) {
      if (kDebugMode) print("Google Sign-In error: $e");
      return null;
    }
  }

  // 🔹 Sign out from Google
  Future<void> signOutGoogle() async {
    try {
      if (!kIsWeb) {
        // Only try to disconnect on mobile platforms
        try {
          await _googleSignIn.disconnect();
        } catch (e) {
          if (kDebugMode) print('Google disconnect error (non-critical): $e');
        }
      }
      await _firebaseAuth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('Google Sign-Out Error: $e');
      }
      throw Exception(e);
    }
  }

  // 🔹 Sign out (Generic)
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('Sign-Out Error: $e');
      }
      throw Exception(e);
    }
  }

  // 🔹 Get current user
  User? getCurrentUser() => _firebaseAuth.currentUser;

  // 🔹 Sign in with Email & Password
  Future<UserCredential> signInWithEmailPassword(
      String email, String password) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e.code));
    }
  }

  // 🔹 Sign up with Email & Password & Send Email Verification
  Future<UserCredential> signUpWithEmailPassword(
      String email, String password) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user?.sendEmailVerification();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e.code));
    }
  }

  // 🔹 Helper method for error messages
  String _getAuthErrorMessage(String errorCode) {
    const errorMessages = {
      'user-not-found': 'No user found with this email.',
      'wrong-password': 'Incorrect password. Try again.',
      'email-already-in-use': 'Email is already registered.',
      'invalid-email': 'Invalid email format.',
      'weak-password': 'Password should be at least 6 characters.',
    };
    return errorMessages[errorCode] ?? 'Authentication failed. Please try again.';
  }
}
