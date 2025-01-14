import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String nombre;
  final String email;
  final String? fotoUrl;
  final DateTime fechaRegistro;

  AppUser({
    required this.id,
    required this.nombre,
    required this.email,
    this.fotoUrl,
    required this.fechaRegistro,
  });

  factory AppUser.fromMap(Map<String, dynamic> data, String documentId) {
    return AppUser(
      id: documentId,
      nombre: data['nombre'] ?? '',
      email: data['email'] ?? '',
      fotoUrl: data['fotoUrl'],
      fechaRegistro: (data['fechaRegistro'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'email': email,
      'fotoUrl': fotoUrl,
      'fechaRegistro': fechaRegistro,
    };
  }
}
