import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

// ─── Singleton GoogleSignIn instance ──────────────────────────────────────────
// A single instance is shared so signOut() always reaches the same object.
//
// serverClientId MUST be the Web OAuth 2.0 client ID (client_type: 3) from
// android/app/google-services.json for the NEW Firebase project travelhub-5633c.
// This is required by google_sign_in_android v6+ (Credential Manager API) to
// obtain an ID token for Firebase.
//
// Source: android/app/google-services.json → oauth_client where client_type = 3
//   client_id = 787225020994-2q21m4ckruh6iulht6592ra175dmapl3.apps.googleusercontent.com
//
// ⚠️  IMPORTANT: the SHA-1 fingerprint of your signing key MUST be registered
//     in Firebase Console → Project Settings → Android app → SHA certificate
//     fingerprints. If it is missing or wrong, Credential Manager will silently
//     fail and you will see PlatformException(sign_in_failed) with null details.
//
//     Your debug keystore SHA-1 is printed by:
//       keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore"
//               -alias androiddebugkey -storepass android -keypass android
final GoogleSignIn _googleSignIn = GoogleSignIn(
  // Web OAuth 2.0 client ID (client_type: 3) from travelhub-5633c google-services.json
  serverClientId:
      '787225020994-2q21m4ckruh6iulht6592ra175dmapl3.apps.googleusercontent.com',
);

// Keep a public accessor for sign-out.
GoogleSignIn get googleSignIn => _googleSignIn;

// ─── Sign In ──────────────────────────────────────────────────────────────────

/// Signs the user in with Google and authenticates with Firebase.
///
/// Returns the signed-in [User] on success.
/// Returns `null` if the user **cancelled** the sign-in dialog.
/// Throws [GoogleSignInException] with a user-friendly [message] for every
/// other failure, so the caller can display it directly.
///
/// Every step is logged with a [TAG] prefix so you can filter logcat with:
///   adb logcat -s flutter | grep "\[GoogleSignIn\]"
Future<User?> signInWithGoogle() async {
  const tag = '[GoogleSignIn]';

  // ── Step 0: Environment sanity check ────────────────────────────────────
  debugPrint('$tag ══════════════════════════════════════════════════════');
  debugPrint('$tag Step 0 – Starting Google Sign-In flow');
  debugPrint('$tag Firebase project  = travelhub-5633c (project number: 787225020994)');
  debugPrint('$tag serverClientId    = '
      '787225020994-2q21m4ckruh6iulht6592ra175dmapl3.apps.googleusercontent.com');
  debugPrint('$tag platform = ${defaultTargetPlatform.name}');

  try {
    // ── Step 1: Show the Google account picker (Credential Manager) ──────
    debugPrint('$tag Step 1 – Calling googleSignIn.signIn() …');
    GoogleSignInAccount? googleUser;
    try {
      googleUser = await _googleSignIn.signIn();
    } on PlatformException catch (e, st) {
      // Capture full details BEFORE re-throwing so they appear in logcat.
      debugPrint('$tag ❌ Step 1 FAILED – PlatformException from signIn()');
      debugPrint('$tag   code    = ${e.code}');
      debugPrint('$tag   message = ${e.message}');
      debugPrint('$tag   details = ${e.details}');
      debugPrint('$tag   stacktrace:\n$st');
      debugPrint('$tag ──────────────────────────────────────────────────');
      debugPrint('$tag DIAGNOSIS HINTS:');
      debugPrint('$tag   • "sign_in_failed" with null/empty details usually means');
      debugPrint('$tag     a SHA-1 MISMATCH between your signing key and the');
      debugPrint('$tag     fingerprint registered in Firebase Console.');
      debugPrint('$tag   • Run: keytool -list -v -keystore');
      debugPrint('$tag     "%USERPROFILE%\\.android\\debug.keystore"');
      debugPrint('$tag     -alias androiddebugkey -storepass android');
      debugPrint('$tag     and compare with Firebase Console → Project Settings');
      debugPrint('$tag     → Android app → SHA certificate fingerprints.');
      debugPrint('$tag   • "NoCredentialException" means no Google account is');
      debugPrint('$tag     signed into the device/emulator. Sign in first via');
      debugPrint('$tag     Settings → Google on the device.');
      debugPrint('$tag ══════════════════════════════════════════════════════');
      final userMessage = _platformExceptionMessage(e);
      throw GoogleSignInException(userMessage, cause: e);
    }

    if (googleUser == null) {
      debugPrint('$tag Step 1 – User CANCELLED the account picker (returned null).');
      debugPrint('$tag ══════════════════════════════════════════════════════');
      return null; // Not an error – user dismissed the dialog.
    }

    debugPrint('$tag Step 1 ✅ – Account selected:');
    debugPrint('$tag   displayName = ${googleUser.displayName}');
    debugPrint('$tag   email       = ${googleUser.email}');
    debugPrint('$tag   id          = ${googleUser.id}');
    debugPrint('$tag   serverAuthCode present = '
        '${googleUser.serverAuthCode != null}');

    // ── Step 2: Exchange for Google auth tokens ───────────────────────────
    debugPrint('$tag Step 2 – Requesting auth tokens (idToken + accessToken) …');
    GoogleSignInAuthentication googleAuth;
    try {
      googleAuth = await googleUser.authentication;
    } on PlatformException catch (e, st) {
      debugPrint('$tag ❌ Step 2 FAILED – PlatformException from .authentication');
      debugPrint('$tag   code=${e.code}  message=${e.message}  details=${e.details}');
      debugPrint('$tag   stacktrace:\n$st');
      throw GoogleSignInException(
        'Failed to retrieve Google auth tokens: ${e.message ?? e.code}',
        cause: e,
      );
    }

    debugPrint('$tag Step 2 ✅ – Tokens received:');
    debugPrint('$tag   idToken present     = ${googleAuth.idToken != null}');
    debugPrint('$tag   accessToken present = ${googleAuth.accessToken != null}');

    if (googleAuth.idToken == null) {
      debugPrint('$tag ❌ Step 2 – idToken is NULL.');
      debugPrint('$tag   This almost always means the SHA-1 / SHA-256 fingerprint');
      debugPrint('$tag   of your debug keystore is NOT registered in Firebase.');
      debugPrint('$tag   Register it at: Firebase Console → Project Settings →');
      debugPrint('$tag   Your Android app → SHA certificate fingerprints.');
      throw const GoogleSignInException(
        'Google authentication failed: no ID token received.\n'
        'ACTION REQUIRED: Open Firebase Console → Project Settings → '
        'Android app and add your debug SHA-1 fingerprint.\n'
        'Run keytool to get it: keytool -list -v -keystore '
        '"%USERPROFILE%\\.android\\debug.keystore" '
        '-alias androiddebugkey -storepass android -keypass android',
      );
    }

    // ── Step 3: Create Firebase credential ───────────────────────────────
    debugPrint('$tag Step 3 – Creating OAuthCredential from Google tokens …');
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    debugPrint('$tag Step 3 ✅ – OAuthCredential created.');

    // ── Step 4: Sign in to Firebase ───────────────────────────────────────
    debugPrint('$tag Step 4 – Calling FirebaseAuth.signInWithCredential() …');
    UserCredential userCredential;
    try {
      userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
    } on FirebaseAuthException catch (e, st) {
      debugPrint('$tag ❌ Step 4 FAILED – FirebaseAuthException');
      debugPrint('$tag   code    = ${e.code}');
      debugPrint('$tag   message = ${e.message}');
      debugPrint('$tag   stacktrace:\n$st');
      throw GoogleSignInException(_firebaseMessage(e.code), cause: e);
    }

    final User? user = userCredential.user;
    if (user == null) {
      debugPrint('$tag ❌ Step 4 – Firebase signInWithCredential returned null user.');
      throw const GoogleSignInException(
          'Firebase sign-in returned no user. Please try again.');
    }

    debugPrint('$tag Step 4 ✅ – Firebase sign-in successful:');
    debugPrint('$tag   uid          = ${user.uid}');
    debugPrint('$tag   email        = ${user.email}');
    debugPrint('$tag   displayName  = ${user.displayName}');
    debugPrint('$tag   photoURL     = ${user.photoURL}');
    debugPrint('$tag   isNewUser    = ${userCredential.additionalUserInfo?.isNewUser}');
    debugPrint('$tag   providerId   = ${userCredential.additionalUserInfo?.providerId}');

    // ── Step 5: Create / verify Firestore document ────────────────────────
    debugPrint('$tag Step 5 – Upserting Firestore user document …');
    await _upsertUserDocument(user);

    debugPrint('$tag ══════════════════════════════════════════════════════');
    debugPrint('$tag ✅ Google Sign-In COMPLETE – ${user.email} (${user.uid})');
    debugPrint('$tag ══════════════════════════════════════════════════════');
    return user;

  } on GoogleSignInException {
    rethrow;

  } on PlatformException catch (e, st) {
    // Catch-all for any PlatformException not caught above.
    debugPrint('[GoogleSignIn] ❌ Unhandled PlatformException:');
    debugPrint('[GoogleSignIn]   code    = ${e.code}');
    debugPrint('[GoogleSignIn]   message = ${e.message}');
    debugPrint('[GoogleSignIn]   details = ${e.details}');
    debugPrint('[GoogleSignIn]   stack:\n$st');
    throw GoogleSignInException(_platformExceptionMessage(e), cause: e);

  } on FirebaseAuthException catch (e, st) {
    debugPrint('[GoogleSignIn] ❌ FirebaseAuthException: '
        'code=${e.code}  message=${e.message}\n$st');
    throw GoogleSignInException(_firebaseMessage(e.code), cause: e);

  } catch (e, st) {
    debugPrint('[GoogleSignIn] ❌ Unexpected error: $e\n$st');
    throw GoogleSignInException(
        'Sign-in failed unexpectedly. Please try again.\n'
        'Error type: ${e.runtimeType}\n'
        'Details: $e',
        cause: e);
  }
}

// ─── Sign Out ─────────────────────────────────────────────────────────────────

/// Signs out from both Firebase **and** the Google Sign-In SDK.
///
/// This is mandatory so the next [signInWithGoogle] call shows the
/// account chooser instead of silently re-authenticating the same account.
Future<void> signOutFromGoogle() async {
  try {
    debugPrint('[GoogleSignIn] Signing out …');
    await Future.wait([
      FirebaseAuth.instance.signOut(),
      _googleSignIn.signOut(),
    ]);
    debugPrint('[GoogleSignIn] ✅ Signed out successfully.');
  } catch (e, st) {
    debugPrint('[GoogleSignIn] Sign-out error (non-critical): $e\n$st');
  }
}

// ─── Firestore helper ─────────────────────────────────────────────────────────

/// Creates the user document on first login; skips silently if it already exists.
Future<void> _upsertUserDocument(User user) async {
  try {
    final DocumentReference ref =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    debugPrint('[GoogleSignIn] Step 5 – Fetching Firestore doc for uid=${user.uid}');
    final DocumentSnapshot doc = await ref.get();
    if (!doc.exists) {
      debugPrint('[GoogleSignIn] Step 5 – No existing doc → creating new user document.');
      await ref.set({
        'uid': user.uid,
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'photo': user.photoURL ?? '',
        'provider': 'google',
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint('[GoogleSignIn] Step 5 ✅ – New user document created in Firestore.');
    } else {
      debugPrint('[GoogleSignIn] Step 5 ✅ – Existing user document found. Skipping write.');
    }
  } catch (e, st) {
    // Firestore write failure must NEVER block authentication.
    debugPrint('[GoogleSignIn] Step 5 ⚠️  Firestore upsert error (non-critical): $e\n$st');
  }
}

// ─── Error message helpers ────────────────────────────────────────────────────

/// Maps a [PlatformException] thrown by the google_sign_in plugin to a
/// user-friendly message. The raw code and details are always logged above;
/// here we surface the most actionable message to the user.
String _platformExceptionMessage(PlatformException e) {
  switch (e.code) {
    case 'sign_in_cancelled':
    case 'canceled':
      return 'Sign-in was cancelled.';
    case 'sign_in_failed':
      final detail = e.details?.toString();
      // Always show the raw detail if present (helps during development).
      if (detail != null && detail.isNotEmpty) {
        return 'Google Sign-In failed: $detail';
      }
      // No details → almost certainly a SHA-1 mismatch.
      return 'Google Sign-In failed (SHA-1 fingerprint mismatch).\n'
          'ACTION: Open Firebase Console → Project Settings → '
          'Android app → Add your debug SHA-1 fingerprint, then '
          're-download google-services.json.';
    case 'network_error':
      return 'Network error. Please check your internet connection.';
    case 'sign_in_required':
      return 'You must sign in to continue.';
    default:
      final msg = e.message ?? 'unknown';
      final detail = e.details?.toString() ?? '';
      return 'Google Sign-In error (${e.code}): $msg'
          '${detail.isNotEmpty ? "\nDetails: $detail" : ""}';
  }
}

/// Maps a Firebase error code to a user-friendly message.
String _firebaseMessage(String code) {
  switch (code) {
    case 'account-exists-with-different-credential':
      return 'An account already exists with a different sign-in method. '
          'Please sign in with the original method.';
    case 'invalid-credential':
      return 'The Google credential is invalid or expired. Please try again.';
    case 'user-disabled':
      return 'This account has been disabled. Please contact support.';
    case 'network-request-failed':
      return 'Network error. Please check your connection and try again.';
    default:
      return 'Firebase authentication failed ($code). Please try again.';
  }
}

// ─── Exception type ───────────────────────────────────────────────────────────

class GoogleSignInException implements Exception {
  final String message;
  final Object? cause;

  const GoogleSignInException(this.message, {this.cause});

  @override
  String toString() => cause != null
      ? 'GoogleSignInException: $message (caused by $cause)'
      : 'GoogleSignInException: $message';
}
