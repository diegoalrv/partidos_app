import 'package:cloud_firestore/cloud_firestore.dart';

class ParticipanteService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Método para que un usuario se una a un partido
  Future<bool> unirseAPartido(String partidoId, String usuarioId) async {
    try {
      // Verificar si el usuario ya está unido al partido
      QuerySnapshot existing = await _db
          .collection('participantes')
          .where('partidoId', isEqualTo: partidoId)
          .where('usuarioId', isEqualTo: usuarioId)
          .get();

      if (existing.docs.isNotEmpty) {
        // El usuario ya está unido al partido
        return false;
      }

      // Verificar la capacidad del partido
      DocumentSnapshot partidoDoc =
          await _db.collection('partidos').doc(partidoId).get();
      if (!partidoDoc.exists) return false;
      int capacidad = partidoDoc['capacidad'] ?? 10;

      QuerySnapshot currentParticipants = await _db
          .collection('participantes')
          .where('partidoId', isEqualTo: partidoId)
          .get();

      if (currentParticipants.docs.length >= capacidad) {
        // El partido ya está completo
        return false;
      }

      // Agregar al usuario como participante
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

  // Método para obtener participantes de un partido
  Future<List<String>> getParticipantes(String partidoId) async {
    QuerySnapshot snapshot = await _db
        .collection('participantes')
        .where('partidoId', isEqualTo: partidoId)
        .get();
    return snapshot.docs.map((doc) => doc['usuarioId'] as String).toList();
  }
}
