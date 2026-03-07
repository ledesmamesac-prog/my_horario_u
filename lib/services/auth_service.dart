import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  AuthService() {
    _initializeGoogleSignIn();
  }

  Future<void> _initializeGoogleSignIn() async {
    try {
      // Inicialización requerida en versiones nuevas
      await _googleSignIn.initialize();
    } catch (e) {
      debugPrint("Error inicializando GoogleSignIn: $e");
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // En la versión 7.x se usa authenticate() en lugar de signIn()
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      // Obtener el idToken
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      
      // Obtener el accessToken (ahora a través de authorizationClient)
      final GoogleSignInClientAuthorization? authz = await googleUser.authorizationClient.authorizationForScopes([
        'email',
        'https://www.googleapis.com/auth/userinfo.profile',
        'openid',
      ]);

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: authz?.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        await _updateUserProfile(userCredential.user!);
      }

      notifyListeners();
      return userCredential;
    } catch (e) {
      debugPrint("Error en signInWithGoogle: $e");
      rethrow;
    }
  }

  Future<void> _updateUserProfile(User user) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    
    await userDoc.set({
      'uid': user.uid,
      'nombre': user.displayName,
      'email': user.email,
      'fotoUrl': user.photoURL,
      'lastLogin': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      notifyListeners();
    } catch (e) {
      debugPrint("Error al cerrar sesión: $e");
    }
  }
}

