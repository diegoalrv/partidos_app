import 'package:cloud_firestore/cloud_firestore.dart';

class Equipo {
  final String id;
  final String nombre;
  final String descripcion;
  final List<String> miembros; // IDs de los usuarios
  final DateTime fechaCreacion;

  Equipo({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.miembros,
    required this.fechaCreacion,
  });

  factory Equipo.fromMap(Map<String, dynamic> data, String documentId) {
    return Equipo(
      id: documentId,
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'] ?? '',
      miembros: List<String>.from(data['miembros'] ?? []),
      fechaCreacion: (data['fechaCreacion'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'miembros': miembros,
      'fechaCreacion': fechaCreacion,
    };
  }
}
