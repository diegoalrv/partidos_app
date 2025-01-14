import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Obtener el usuario actual
  User? get currentUser => _auth.currentUser;

  // Stream de autenticación
  Stream<User?> get user => _auth.authStateChanges();

  // Registro con email y contraseña
  Future<AppUser?> registerWithEmail(
      String nombre, String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      if (user != null) {
        // Crear documento en 'users'
        AppUser appUser = AppUser(
          id: user.uid,
          nombre: nombre,
          email: email,
          fechaRegistro: DateTime.now(),
        );

        await _db.collection('users').doc(user.uid).set(appUser.toMap());
        print('Documento del usuario creado en Firestore: ${user.uid}');

        // Obtener y guardar el token de FCM
        String? token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          await _db.collection('tokens').doc(token).set({
            'usuarioId': user.uid,
            'fechaRegistro': FieldValue.serverTimestamp(),
          });
        }

        return appUser;
      }
      return null;
    } catch (e) {
      print('Error en registro: $e');
      return null;
    }
  }

  // Login con email y contraseña
  Future<AppUser?> loginWithEmail(String email, String password) async {
    try {
      // Intentar iniciar sesión con FirebaseAuth
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = credential.user;
      if (user != null) {
        print('Usuario autenticado con UID: ${user.uid}');

        // Obtener el documento del usuario en Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          print('Documento del usuario encontrado en Firestore.');
          return AppUser.fromMap(
              userDoc.data() as Map<String, dynamic>, user.uid);
        } else {
          print('Documento del usuario no encontrado en Firestore.');
          throw FirebaseAuthException(
            code: 'user-data-not-found',
            message: 'Usuario no encontrado en la base de datos.',
          );
        }
      } else {
        print('No se pudo autenticar al usuario.');
        throw FirebaseAuthException(
          code: 'auth-error',
          message: 'No se pudo autenticar al usuario.',
        );
      }
    } on FirebaseAuthException catch (e) {
      // Manejo de errores específicos de FirebaseAuth
      print('Error en login: ${e.message}');
      switch (e.code) {
        case 'user-not-found':
          throw 'No existe un usuario con ese email.';
        case 'wrong-password':
          throw 'Contraseña incorrecta.';
        case 'user-data-not-found':
          throw e.message ?? 'Usuario no encontrado en Firestore.';
        default:
          throw 'Error desconocido al autenticar: ${e.message}';
      }
    } catch (e) {
      print('Error desconocido: $e');
      throw 'Ocurrió un error inesperado al autenticar.';
    }
  }

  // Logout
  Future<void> signOut() async {
    try {
      // Obtener el token actual
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        // Eliminar el token de Firestore
        await _db.collection('tokens').doc(token).delete();
      }
      await _auth.signOut();
    } catch (e) {
      print('Error en logout: $e');
    }
  }

  // Obtener datos del usuario desde Firestore
  Future<AppUser?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return AppUser.fromMap(doc.data() as Map<String, dynamic>, uid);
      }
      return null;
    } catch (e) {
      print('Error al obtener datos del usuario: $e');
      return null;
    }
  }
}
