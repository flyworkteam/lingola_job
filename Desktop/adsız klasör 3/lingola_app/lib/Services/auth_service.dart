import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
// Facebook girişi şimdilik kapalı
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Backend isteklerinde kullanmak için Firebase ID token'ı sağlar.
/// Google / Facebook ile giriş ve token alma bu serviste.
class AuthService {
  AuthService._();
  static final AuthService _instance = AuthService._();
  static AuthService get instance => _instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final FacebookAuth _facebookAuth = FacebookAuth.instance;

  /// İptal (Vazgeç) için dönen sabit; çağıran ileri gitmemeli.
  static const String signInCancelled = 'SIGN_IN_CANCELLED';

  /// Google ile giriş. Başarılı olursa [null], iptal ederse [signInCancelled], hata olursa hata mesajı döner.
  Future<String?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return signInCancelled; // Kullanıcı Vazgeç dedi

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        return 'Bu e-posta adresi başka bir giriş yöntemiyle kayıtlı. Lütfen Apple veya Facebook ile giriş yapmayı deneyin.';
      }
      return e.message ?? 'Giriş hatası';
    } catch (e) {
      return e.toString();
    }
  }

  // Facebook girişi şimdilik kapalı
  // /// Facebook ile giriş. Başarılı: null, iptal: [signInCancelled], hata: mesaj.
  // /// iOS'ta "Bad signature" (190) önlemek için Limited Login + nonce kullanılıyor.
  // Future<String?> signInWithFacebook() async {
  //   try {
  //     final bool isIOS = !kIsWeb &&
  //         (defaultTargetPlatform == TargetPlatform.iOS ||
  //             defaultTargetPlatform == TargetPlatform.macOS);
  //
  //     final LoginResult result;
  //     String? rawNonce;
  //
  //     if (isIOS) {
  //       rawNonce = _generateNonce();
  //       final hashedNonce = _sha256OfString(rawNonce);
  //       result = await _facebookAuth.login(
  //         loginTracking: LoginTracking.limited,
  //         nonce: hashedNonce,
  //       );
  //     } else {
  //       result = await _facebookAuth.login(
  //         loginTracking: LoginTracking.enabled,
  //       );
  //     }
  //
  //     if (result.status != LoginStatus.success) {
  //       return result.status == LoginStatus.cancelled
  //           ? signInCancelled
  //           : 'Facebook girişi iptal edildi.';
  //     }
  //     final token = result.accessToken;
  //     if (token == null) return signInCancelled;
  //
  //     OAuthCredential credential;
  //     if (token.type == AccessTokenType.limited &&
  //         rawNonce != null &&
  //         rawNonce.isNotEmpty) {
  //       credential = OAuthProvider('facebook.com').credential(
  //         idToken: token.tokenString,
  //         rawNonce: rawNonce,
  //       );
  //     } else {
  //       credential = FacebookAuthProvider.credential(token.tokenString);
  //     }
  //
  //     await _auth.signInWithCredential(credential);
  //     return null;
  //   } on FirebaseAuthException catch (e) {
  //     if (e.code == 'account-exists-with-different-credential') {
  //       return 'Bu e-posta adresi zaten Google veya Apple ile kayıtlı. Lütfen giriş yapmak için o butonu kullanın.';
  //     }
  //     return e.message ?? 'Facebook giriş hatası';
  //   } catch (e, stack) {
  //     if (kDebugMode) debugPrint('Facebook login error: $e\n$stack');
  //     return e.toString();
  //   }
  // }

  /// Apple ile giriş. Başarılı: null, iptal: [signInCancelled], hata: mesaj.
  Future<String?> signInWithApple() async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.iOS &&
            defaultTargetPlatform != TargetPlatform.macOS)) {
      return 'Apple girişi şu anda yalnızca iPhone, iPad veya Mac üzerinde etkin.';
    }

    try {
      if (!await SignInWithApple.isAvailable()) {
        return 'Apple girişi bu cihazda kullanılamıyor.';
      }

      final rawNonce = _generateNonce();
      final hashedNonce = _sha256OfString(rawNonce);
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final identityToken = appleCredential.identityToken;
      if (identityToken == null || identityToken.isEmpty) {
        return 'Apple kimlik doğrulama bilgisi alınamadı.';
      }

      // Firebase Auth 5.2.0+ Apple için accessToken (authorizationCode) zorunludur;
      // olmazsa "Invalid OAuth response from apple.com" hatası oluşur.
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: identityToken,
        rawNonce: rawNonce,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _auth.signInWithCredential(oauthCredential);

      final fullName = [appleCredential.givenName, appleCredential.familyName]
          .whereType<String>()
          .map((part) => part.trim())
          .where((part) => part.isNotEmpty)
          .join(' ');

      if (fullName.isNotEmpty &&
          (userCredential.user?.displayName?.trim().isEmpty ?? true)) {
        await userCredential.user?.updateDisplayName(fullName);
        await userCredential.user?.reload();
      }

      return null;
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return signInCancelled;
      }
      if (_isAppleAuthError1000(e.message)) {
        return 'Apple ile giriş bu sürümde kullanılamıyor. Lütfen Google veya Misafir ile giriş yapın.';
      }
      return e.message.isNotEmpty ? e.message : 'Apple giriş hatası';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        return 'Bu e-posta adresi zaten Google veya Facebook ile kayıtlı. Lütfen giriş yapmak için o butonu kullanın.';
      }
      return e.message ?? 'Apple giriş hatası';
    } catch (e) {
      final msg = e.toString();
      if (_isAppleAuthError1000(msg)) {
        return 'Apple ile giriş bu sürümde kullanılamıyor. Lütfen Google veya Misafir ile giriş yapın.';
      }
      return msg;
    }
  }

  /// E-posta ile şifre sıfırlama linki gönderir (Firebase Auth).
  /// Başarılı: null, hata: mesaj string.
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'Bu e-posta adresiyle kayıtlı hesap bulunamadı.';
        case 'invalid-email':
          return 'Geçersiz e-posta adresi.';
        case 'too-many-requests':
          return 'Çok fazla deneme. Lütfen daha sonra tekrar deneyin.';
        default:
          return e.message ?? 'Şifre sıfırlama e-postası gönderilemedi.';
      }
    } catch (e) {
      return e.toString();
    }
  }

  /// Çıkış (Firebase + Google + Facebook).
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    // await _facebookAuth.logOut(); // Facebook girişi şimdilik kapalı
  }

  /// Giriş yapmış kullanıcının ID token'ını döner.
  /// Kullanıcı yoksa veya token alınamazsa `null`.
  Future<String?> getIdToken() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    try {
      return await user.getIdToken();
    } catch (_) {
      return null;
    }
  }

  /// Giriş yapmış kullanıcı var mı?
  bool get isSignedIn => _auth.currentUser != null;

  User? get currentUser => _auth.currentUser;

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();

    return List<String>.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256OfString(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }

  static bool _isAppleAuthError1000(String message) {
    return message.contains('1000') ||
        message.contains('AuthorizationError') ||
        message.contains('AuthenticationServices');
  }
}
