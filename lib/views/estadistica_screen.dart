import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/estadistica_service.dart';
import '../services/auth_service.dart';
import '../models/estadistica.dart';

class EstadisticaScreen extends StatefulWidget {
  const EstadisticaScreen({super.key});

  @override
  _EstadisticaScreenState createState() => _EstadisticaScreenState();
}

class _EstadisticaScreenState extends State<EstadisticaScreen> {
  Estadistica? estadistica;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEstadistica();
  }

  Future<void> _loadEstadistica() async {
    final estadisticaService =
        Provider.of<EstadisticaService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    if (user != null) {
      estadistica = await estadisticaService.getEstadistica(user.uid);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Estadísticas'),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : estadistica == null
                ? Center(child: Text('No tienes estadísticas registradas.'))
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        EstadisticaCard(
                          title: 'Partidos Jugados',
                          value: estadistica!.partidosJugados.toString(),
                          icon: Icons.sports,
                          color: Colors.blue,
                        ),
                        EstadisticaCard(
                          title: 'Victorias',
                          value: estadistica!.victorias.toString(),
                          icon: Icons.check_circle,
                          color: Colors.green,
                        ),
                        EstadisticaCard(
                          title: 'Derrotas',
                          value: estadistica!.derrotas.toString(),
                          icon: Icons.cancel,
                          color: Colors.red,
                        ),
                        EstadisticaCard(
                          title: 'Puntos',
                          value: estadistica!.puntos.toString(),
                          icon: Icons.star,
                          color: Colors.amber,
                        ),
                      ],
                    ),
                  ));
  }
}

class EstadisticaCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const EstadisticaCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: color, size: 40),
        title: Text(title, style: TextStyle(fontSize: 18)),
        trailing: Text(
          value,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
