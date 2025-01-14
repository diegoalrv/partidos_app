import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/equipo.dart';

class EquipoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Crear un nuevo equipo
  Future<bool> crearEquipo({
    required String nombre,
    required String descripcion,
    required String creadorId,
    List<String>? miembros,
  }) async {
    try {
      await _db.collection('equipos').add({
        'nombre': nombre,
        'descripcion': descripcion,
        'creadorId': creadorId,
        'miembros': miembros ?? [creadorId],
        'fechaCreacion': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error al crear equipo: $e');
      return false;
    }
  }

  // Obtener todos los equipos
  Future<List<Equipo>> getEquipos() async {
    try {
      QuerySnapshot snapshot = await _db.collection('equipos').get();
      List<Equipo> equipos = snapshot.docs
          .map((doc) =>
              Equipo.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      return equipos;
    } catch (e) {
      print('Error al obtener equipos: $e');
      return [];
    }
  }

  // Obtener equipos en tiempo real usando Streams
  Stream<List<Equipo>> getEquiposStream() {
    return _db.collection('equipos').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Equipo.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Añadir miembro a un equipo
  Future<bool> anadirMiembro(String equipoId, String usuarioId) async {
    try {
      await _db.collection('equipos').doc(equipoId).update({
        'miembros': FieldValue.arrayUnion([usuarioId]),
      });
      return true;
    } catch (e) {
      print('Error al añadir miembro al equipo: $e');
      return false;
    }
  }

  // Eliminar miembro de un equipo
  Future<bool> eliminarMiembro(String equipoId, String usuarioId) async {
    try {
      await _db.collection('equipos').doc(equipoId).update({
        'miembros': FieldValue.arrayRemove([usuarioId]),
      });
      return true;
    } catch (e) {
      print('Error al eliminar miembro del equipo: $e');
      return false;
    }
  }

  // Obtener detalles de un equipo específico
  Future<Equipo?> getEquipoById(String equipoId) async {
    try {
      DocumentSnapshot doc =
          await _db.collection('equipos').doc(equipoId).get();
      if (doc.exists) {
        return Equipo.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error al obtener equipo: $e');
      return null;
    }
  }
}
