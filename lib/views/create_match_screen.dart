import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/partido_service.dart';
import '../services/auth_service.dart';

class CrearPartidoScreen extends StatefulWidget {
  const CrearPartidoScreen({super.key});

  @override
  _CrearPartidoScreenState createState() => _CrearPartidoScreenState();
}

class _CrearPartidoScreenState extends State<CrearPartidoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _deporteController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _horarioController = TextEditingController();
  final TextEditingController _lugarController = TextEditingController();
  final TextEditingController _capacidadController =
      TextEditingController(text: '10');

  bool isLoading = false;

  @override
  void dispose() {
    _deporteController.dispose();
    _descripcionController.dispose();
    _horarioController.dispose();
    _lugarController.dispose();
    _capacidadController.dispose();
    super.dispose();
  }

  Future<void> _crearPartido() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      final partidoService =
          Provider.of<PartidoService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;

      if (user != null) {
        bool success = await partidoService.crearPartido(
          deporte: _deporteController.text,
          descripcion: _descripcionController.text,
          horario: _horarioController.text,
          lugar: _lugarController.text,
          capacidad: int.parse(_capacidadController.text),
          creadorId: user.uid,
        );

        setState(() {
          isLoading = false;
        });

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Partido creado exitosamente.')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Error al crear el partido. Inténtalo de nuevo.')),
          );
        }
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuario no autenticado.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Crear Nuevo Partido'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: _deporteController,
                        decoration: InputDecoration(labelText: 'Deporte'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, ingresa el deporte.';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _descripcionController,
                        decoration: InputDecoration(labelText: 'Descripción'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, ingresa una descripción.';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _horarioController,
                        decoration: InputDecoration(labelText: 'Horario'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, ingresa el horario.';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _lugarController,
                        decoration: InputDecoration(labelText: 'Lugar'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, ingresa el lugar.';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _capacidadController,
                        decoration: InputDecoration(labelText: 'Capacidad'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, ingresa la capacidad.';
                          }
                          if (int.tryParse(value) == null ||
                              int.parse(value) <= 0) {
                            return 'Por favor, ingresa un número válido.';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _crearPartido,
                        child: Text('Crear Partido'),
                      ),
                    ],
                  ),
                ),
        ));
  }
}
