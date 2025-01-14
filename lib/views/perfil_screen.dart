import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../services/firestore_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  AppUser? user;
  bool isLoading = true;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  File? _imageFile;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadPerfil();
  }

  Future<void> _loadPerfil() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (authService.currentUser != null) {
      user = await authService.getUserData(authService.currentUser!.uid);
      _nombreController.text = user?.nombre ?? '';
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _seleccionarImagen() async {
    final ImagePicker picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _subirImagen(String usuarioId) async {
    if (_imageFile == null) return null;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('usuarios')
          .child('$usuarioId.jpg');
      await storageRef.putFile(_imageFile!);
      String downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error al subir imagen: $e');
      return null;
    }
  }

  Future<void> _actualizarPerfil() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isUpdating = true;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);

    String usuarioId = authService.currentUser!.uid;
    String nombre = _nombreController.text.trim();

    String? fotoUrl = user?.fotoUrl;

    // Si se seleccionó una nueva imagen, subirla
    if (_imageFile != null) {
      String? nuevaFotoUrl = await _subirImagen(usuarioId);
      if (nuevaFotoUrl != null) {
        fotoUrl = nuevaFotoUrl;
      }
    }

    // Actualizar el documento en Firestore
    await firestoreService.updateDocument('users', usuarioId, {
      'nombre': nombre,
      'fotoUrl': fotoUrl,
    });

    // Actualizar el objeto local
    user = AppUser(
      id: usuarioId,
      nombre: nombre,
      email: user?.email ?? '',
      fotoUrl: fotoUrl,
      fechaRegistro: user?.fechaRegistro ?? DateTime.now(),
    );

    setState(() {
      isUpdating = false;
      _imageFile = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Perfil actualizado exitosamente.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Mi Perfil'),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: isUpdating
                    ? Center(child: CircularProgressIndicator())
                    : Form(
                        key: _formKey,
                        child: ListView(
                          children: [
                            Center(
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 60,
                                    backgroundImage: _imageFile != null
                                        ? FileImage(_imageFile!)
                                        : (user!.fotoUrl != null
                                            ? NetworkImage(user!.fotoUrl!)
                                                as ImageProvider
                                            : AssetImage(
                                                'assets/images/default_avatar.png')),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: IconButton(
                                      icon: Icon(Icons.camera_alt,
                                          color: Colors.blue),
                                      onPressed: _seleccionarImagen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                            TextFormField(
                              controller: _nombreController,
                              decoration: InputDecoration(
                                labelText: 'Nombre',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, ingresa tu nombre.';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),
                            TextFormField(
                              initialValue: user!.email,
                              decoration: InputDecoration(
                                labelText: 'Correo Electrónico',
                                border: OutlineInputBorder(),
                              ),
                              readOnly: true,
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _actualizarPerfil,
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(double.infinity, 50),
                              ),
                              child: Text('Actualizar Perfil'),
                            ),
                          ],
                        ),
                      ),
              ));
  }
}
