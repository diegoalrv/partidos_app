import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/estadistica.dart';

class EstadisticaService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Crear o actualizar estadísticas
  Future<bool> actualizarEstadistica(Estadistica estadistica) async {
    try {
      await _db
          .collection('estadisticas')
          .doc(estadistica.usuarioId)
          .set(estadistica.toMap(), SetOptions(merge: true));
      return true;
    } catch (e) {
      print('Error al actualizar estadísticas: $e');
      return false;
    }
  }

  // Obtener estadísticas de un usuario
  Future<Estadistica?> getEstadistica(String usuarioId) async {
    try {
      DocumentSnapshot doc =
          await _db.collection('estadisticas').doc(usuarioId).get();
      if (doc.exists) {
        return Estadistica.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error al obtener estadísticas: $e');
      return null;
    }
  }
}
