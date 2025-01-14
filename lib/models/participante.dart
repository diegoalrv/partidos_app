import 'package:cloud_firestore/cloud_firestore.dart';

class Participante {
  final String id;
  final String partidoId;
  final String usuarioId;
  final DateTime fechaUnido;

  Participante({
    required this.id,
    required this.partidoId,
    required this.usuarioId,
    required this.fechaUnido,
  });

  factory Participante.fromMap(Map<String, dynamic> data, String documentId) {
    return Participante(
      id: documentId,
      partidoId: data['partidoId'] ?? '',
      usuarioId: data['usuarioId'] ?? '',
      fechaUnido: (data['fechaUnido'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'partidoId': partidoId,
      'usuarioId': usuarioId,
      'fechaUnido': fechaUnido,
    };
  }
}
