import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/amistad_service.dart';
import '../services/auth_service.dart';
import '../models/amistad.dart';

class SolicitudesScreen extends StatefulWidget {
  const SolicitudesScreen({super.key});

  @override
  _SolicitudesScreenState createState() => _SolicitudesScreenState();
}

class _SolicitudesScreenState extends State<SolicitudesScreen> {
  List<Amistad> solicitudes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSolicitudes();
  }

  Future<void> _loadSolicitudes() async {
    final amistadService = Provider.of<AmistadService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    if (user != null) {
      solicitudes = await amistadService.getSolicitudesRecibidas(user.uid);
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _aceptarSolicitud(String amistadId) async {
    final amistadService = Provider.of<AmistadService>(context, listen: false);
    bool success = await amistadService.aceptarSolicitud(amistadId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Solicitud aceptada.')),
      );
      _loadSolicitudes();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al aceptar solicitud.')),
      );
    }
  }

  Future<void> _rechazarSolicitud(String amistadId) async {
    final amistadService = Provider.of<AmistadService>(context, listen: false);
    bool success = await amistadService.rechazarSolicitud(amistadId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Solicitud rechazada.')),
      );
      _loadSolicitudes();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al rechazar solicitud.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Solicitudes de Amistad'),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : solicitudes.isEmpty
                ? Center(child: Text('No tienes solicitudes de amistad.'))
                : ListView.builder(
                    itemCount: solicitudes.length,
                    itemBuilder: (context, index) {
                      final solicitud = solicitudes[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text(solicitud
                            .usuarioId), // Aquí podrías mostrar el nombre del usuario
                        subtitle: Text(
                            'Fecha: ${solicitud.fechaSolicitud.toLocal()}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.check, color: Colors.green),
                              onPressed: () {
                                _aceptarSolicitud(solicitud.id);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                _rechazarSolicitud(solicitud.id);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ));
  }
}
