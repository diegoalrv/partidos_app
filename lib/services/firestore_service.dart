import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Obtener una colección
  CollectionReference getCollection(String collectionPath) {
    return _db.collection(collectionPath);
  }

  // Agregar un documento a una colección
  Future<void> addDocument(
      String collectionPath, Map<String, dynamic> data) async {
    try {
      await _db.collection(collectionPath).add(data);
    } catch (e) {
      print('Error al agregar documento a $collectionPath: $e');
    }
  }

  // Actualizar un documento
  Future<void> updateDocument(
      String collectionPath, String docId, Map<String, dynamic> data) async {
    try {
      await _db.collection(collectionPath).doc(docId).update(data);
    } catch (e) {
      print('Error al actualizar documento $docId en $collectionPath: $e');
    }
  }

  // Eliminar un documento
  Future<void> deleteDocument(String collectionPath, String docId) async {
    try {
      await _db.collection(collectionPath).doc(docId).delete();
    } catch (e) {
      print('Error al eliminar documento $docId en $collectionPath: $e');
    }
  }

  // Obtener un documento
  Future<DocumentSnapshot> getDocument(
      String collectionPath, String docId) async {
    try {
      return await _db.collection(collectionPath).doc(docId).get();
    } catch (e) {
      print('Error al obtener documento $docId en $collectionPath: $e');
      rethrow;
    }
  }

  // Obtener todos los documentos de una colección
  Future<QuerySnapshot> getCollectionSnapshot(String collectionPath) async {
    try {
      return await _db.collection(collectionPath).get();
    } catch (e) {
      print('Error al obtener colección $collectionPath: $e');
      rethrow;
    }
  }

  // Obtener documentos con una condición
  Future<QuerySnapshot> getCollectionWhere(
      String collectionPath, String field, dynamic isEqualTo) async {
    try {
      return await _db
          .collection(collectionPath)
          .where(field, isEqualTo: isEqualTo)
          .get();
    } catch (e) {
      print('Error al obtener documentos con condición en $collectionPath: $e');
      rethrow;
    }
  }
}
