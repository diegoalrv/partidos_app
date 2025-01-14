import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/partido.dart';
import '../services/partido_service.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class PartidoScreen extends StatefulWidget {
  final String partidoId;

  const PartidoScreen({super.key, required this.partidoId});

  @override
  _PartidoScreenState createState() => _PartidoScreenState();
}

class _PartidoScreenState extends State<PartidoScreen> {
  Partido? partido;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPartido();
  }

  Future<void> _loadPartido() async {
    final partidoService = Provider.of<PartidoService>(context, listen: false);
    partido = await partidoService.getPartidoById(widget.partidoId);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _unirse() async {
    final partidoService = Provider.of<PartidoService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    if (user != null && partido != null) {
      bool success = await partidoService.unirseAPartido(partido!.id, user.uid);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Te has unido al partido exitosamente.')),
        );
        _loadPartido(); // Actualizar la información del partido
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'No se pudo unir al partido. Puede estar completo o ya estás unido.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Partido'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : partido == null
              ? Center(child: Text('Partido no encontrado.'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Imagen del partido (si existe)
                      partido!.imagenUrl != null
                          ? Image.network(
                              partido!.imagenUrl!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              height: 200,
                              color: Colors.grey[300],
                              child: Icon(Icons.sports,
                                  size: 100, color: Colors.grey[600]),
                            ),
                      SizedBox(height: 20),
                      Text(
                        partido!.deporte,
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        partido!.descripcion,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Horario: ${partido!.horario}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Lugar: ${partido!.lugar}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Participantes: ${partido!.participantes.length}/${partido!.capacidad}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed:
                            partido!.participantes.length >= partido!.capacidad
                                ? null
                                : _unirse,
                        icon: Icon(Icons.check),
                        label: Text('Unirse al Partido'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: Size(double.infinity, 50),
                        ),
                      ),
                      SizedBox(height: 10),
                      // Mostrar lista de participantes
                      Expanded(
                        child: partido!.participantes.isEmpty
                            ? Center(child: Text('No hay participantes aún.'))
                            : ListView.builder(
                                itemCount: partido!.participantes.length,
                                itemBuilder: (context, index) {
                                  final usuarioId =
                                      partido!.participantes[index];
                                  // Aquí podrías obtener los datos del usuario desde Firestore
                                  // Para simplificar, mostraremos el ID
                                  return ListTile(
                                    leading: CircleAvatar(
                                      child: Icon(Icons.person),
                                    ),
                                    title: Text('Usuario ID: $usuarioId'),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
