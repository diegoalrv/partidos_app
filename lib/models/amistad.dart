import 'package:cloud_firestore/cloud_firestore.dart';

class Amistad {
  final String id;
  final String usuarioId;
  final String amigoId;
  final bool aceptado;
  final DateTime fechaSolicitud;

  Amistad({
    required this.id,
    required this.usuarioId,
    required this.amigoId,
    this.aceptado = false,
    required this.fechaSolicitud,
  });

  factory Amistad.fromMap(Map<String, dynamic> data, String documentId) {
    return Amistad(
      id: documentId,
      usuarioId: data['usuarioId'],
      amigoId: data['amigoId'],
      aceptado: data['aceptado'] ?? false,
      fechaSolicitud: (data['fechaSolicitud'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'usuarioId': usuarioId,
      'amigoId': amigoId,
      'aceptado': aceptado,
      'fechaSolicitud': fechaSolicitud,
    };
  }
}
