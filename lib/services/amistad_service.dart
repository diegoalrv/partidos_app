import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/amistad.dart';

class AmistadService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Enviar una solicitud de amistad
  Future<bool> enviarSolicitud(String usuarioId, String amigoId) async {
    try {
      // Verificar si ya existe una solicitud
      QuerySnapshot existing = await _db
          .collection('amistades')
          .where('usuarioId', isEqualTo: usuarioId)
          .where('amigoId', isEqualTo: amigoId)
          .get();

      if (existing.docs.isNotEmpty) {
        // Ya existe una solicitud
        return false;
      }

      await _db.collection('amistades').add({
        'usuarioId': usuarioId,
        'amigoId': amigoId,
        'aceptado': false,
        'fechaSolicitud': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error al enviar solicitud de amistad: $e');
      return false;
    }
  }

  // Aceptar una solicitud de amistad
  Future<bool> aceptarSolicitud(String amistadId) async {
    try {
      await _db.collection('amistades').doc(amistadId).update({
        'aceptado': true,
      });
      return true;
    } catch (e) {
      print('Error al aceptar solicitud de amistad: $e');
      return false;
    }
  }

  // Rechazar una solicitud de amistad
  Future<bool> rechazarSolicitud(String amistadId) async {
    try {
      await _db.collection('amistades').doc(amistadId).delete();
      return true;
    } catch (e) {
      print('Error al rechazar solicitud de amistad: $e');
      return false;
    }
  }

  // Obtener solicitudes de amistad recibidas
  Future<List<Amistad>> getSolicitudesRecibidas(String usuarioId) async {
    QuerySnapshot snapshot = await _db
        .collection('amistades')
        .where('amigoId', isEqualTo: usuarioId)
        .where('aceptado', isEqualTo: false)
        .get();

    return snapshot.docs
        .map((doc) =>
            Amistad.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  // Obtener lista de amigos
  Future<List<String>> getAmigos(String usuarioId) async {
    QuerySnapshot snapshot = await _db
        .collection('amistades')
        .where('usuarioId', isEqualTo: usuarioId)
        .where('aceptado', isEqualTo: true)
        .get();

    List<String> amigos =
        snapshot.docs.map((doc) => doc['amigoId'] as String).toList();

    // También buscar solicitudes aceptadas donde el usuario es el amigo
    QuerySnapshot snapshotRecibidas = await _db
        .collection('amistades')
        .where('amigoId', isEqualTo: usuarioId)
        .where('aceptado', isEqualTo: true)
        .get();

    amigos.addAll(snapshotRecibidas.docs
        .map((doc) => doc['usuarioId'] as String)
        .toList());

    return amigos;
  }
}
