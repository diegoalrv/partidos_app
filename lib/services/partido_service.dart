// ignore_for_file: unnecessary_cast

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/partido.dart';

class PartidoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Crear un nuevo partido
  Future<bool> crearPartido({
    required String deporte,
    required String descripcion,
    required String horario,
    required String lugar,
    required int capacidad,
    required String creadorId,
    String? imagenUrl,
  }) async {
    try {
      await _db.collection('partidos').add({
        'deporte': deporte,
        'descripcion': descripcion,
        'horario': horario,
        'lugar': lugar,
        'capacidad': capacidad,
        'creadorId': creadorId,
        'fechaCreacion': FieldValue.serverTimestamp(),
        'imagenUrl': imagenUrl,
        'participantes': [], // Lista de IDs de participantes
      });
      return true;
    } catch (e) {
      print('Error al crear partido: $e');
      return false;
    }
  }

  // Obtener todos los partidos
  Future<List<Partido>> getPartidos() async {
    try {
      QuerySnapshot snapshot = await _db.collection('partidos').get();
      List<Partido> partidos = [];
      for (var doc in snapshot.docs) {
        Partido partido =
            Partido.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        // Obtener participantes
        QuerySnapshot participantesSnapshot = await _db
            .collection('participantes')
            .where('partidoId', isEqualTo: doc.id)
            .get();
        partido.participantes = participantesSnapshot.docs
            .map((pDoc) => pDoc['usuarioId'] as String)
            .toList();
        partidos.add(partido);
      }
      return partidos;
    } catch (e) {
      print('Error al obtener partidos: $e');
      return [];
    }
  }

  // Obtener partidos en tiempo real usando Streams
  Stream<List<Partido>> getPartidosStream() {
    return _db.collection('partidos').snapshots().asyncMap((snapshot) async {
      List<Partido> partidos = [];
      for (var doc in snapshot.docs) {
        Partido partido =
            Partido.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        // Obtener participantes
        QuerySnapshot participantesSnapshot = await _db
            .collection('participantes')
            .where('partidoId', isEqualTo: doc.id)
            .get();
        partido.participantes = participantesSnapshot.docs
            .map((pDoc) => pDoc['usuarioId'] as String)
            .toList();
        partidos.add(partido);
      }
      return partidos;
    });
  }

  // Unirse a un partido
  Future<bool> unirseAPartido(String partidoId, String usuarioId) async {
    try {
      // Verificar si el usuario ya está unido
      QuerySnapshot existing = await _db
          .collection('participantes')
          .where('partidoId', isEqualTo: partidoId)
          .where('usuarioId', isEqualTo: usuarioId)
          .get();

      if (existing.docs.isNotEmpty) {
        // El usuario ya está unido
        return false;
      }

      // Verificar la capacidad
      DocumentSnapshot partidoDoc =
          await _db.collection('partidos').doc(partidoId).get();
      if (!partidoDoc.exists) return false;
      int capacidad = partidoDoc['capacidad'] ?? 10;

      QuerySnapshot currentParticipants = await _db
          .collection('participantes')
          .where('partidoId', isEqualTo: partidoId)
          .get();

      if (currentParticipants.docs.length >= capacidad) {
        // Partido completo
        return false;
      }

      // Agregar al participante
      await _db.collection('participantes').add({
        'partidoId': partidoId,
        'usuarioId': usuarioId,
        'fechaUnido': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error al unirse al partido: $e');
      return false;
    }
  }

  // Obtener detalles de un partido específico
  Future<Partido?> getPartidoById(String partidoId) async {
    try {
      DocumentSnapshot doc =
          await _db.collection('partidos').doc(partidoId).get();
      if (doc.exists) {
        Partido partido =
            Partido.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        // Obtener participantes
        QuerySnapshot participantesSnapshot = await _db
            .collection('participantes')
            .where('partidoId', isEqualTo: partidoId)
            .get();
        partido.participantes = participantesSnapshot.docs
            .map((pDoc) => pDoc['usuarioId'] as String)
            .toList();
        return partido;
      }
      return null;
    } catch (e) {
      print('Error al obtener partido: $e');
      return null;
    }
  }

  // Actualizar detalles de un partido (por ejemplo, añadir una imagen)
  Future<bool> actualizarPartido(
      String partidoId, Map<String, dynamic> data) async {
    try {
      await _db.collection('partidos').doc(partidoId).update(data);
      return true;
    } catch (e) {
      print('Error al actualizar partido: $e');
      return false;
    }
  }
}
