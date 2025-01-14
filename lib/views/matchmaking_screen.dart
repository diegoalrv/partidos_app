import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:provider/provider.dart';
import '../models/partido.dart';
import '../services/partido_service.dart';
import '../services/participante_service.dart'; // Servicio para manejar participaciones
import '../services/auth_service.dart';

class MatchmakingScreen extends StatefulWidget {
  const MatchmakingScreen({super.key});

  @override
  _MatchmakingScreenState createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends State<MatchmakingScreen> {
  List<Partido> partidos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPartidos();
  }

  Future<void> _loadPartidos() async {
    final partidoService = Provider.of<PartidoService>(context, listen: false);
    partidos = await partidoService.getPartidos();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _unirseAPartido(Partido partido) async {
    final participanteService =
        Provider.of<ParticipanteService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    if (user != null) {
      // Verificar si el partido ya está completo
      if (partido.participantes.length >= partido.capacidad) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Este partido ya está completo.')),
        );
        return;
      }

      // Unirse al partido
      bool success =
          await participanteService.unirseAPartido(partido.id, user.uid);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Te has unido al partido exitosamente.')),
        );
        // Opcional: Eliminar el partido de la lista local si está completo
        if (partido.participantes.length + 1 >= partido.capacidad) {
          setState(() {
            partidos.remove(partido);
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al unirse al partido. Inténtalo de nuevo.')),
        );
      }
    }
  }

  Future<void> _rechazarPartido(Partido partido) async {
    // Lógica para rechazar el partido, si es necesario
    // Por ejemplo, podrías marcarlo como rechazado en la base de datos
    // o simplemente dejar que desaparezca de la lista
    setState(() {
      partidos.remove(partido);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buscar Partidos'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : partidos.isEmpty
              ? Center(
                  child: Text('No hay partidos disponibles en este momento.'))
              : Swiper(
                  itemBuilder: (BuildContext context, int index) {
                    final partido = partidos[index];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              partido.deporte,
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            Text(partido.descripcion),
                            SizedBox(height: 10),
                            Text('Horario: ${partido.horario}'),
                            SizedBox(height: 10),
                            Text('Lugar: ${partido.lugar}'),
                            SizedBox(height: 10),
                            Text(
                                'Participantes: ${partido.participantes.length}/${partido.capacidad}'),
                            SizedBox(height: 10),
                            if (partido.participantes.length >=
                                partido.capacidad)
                              Text(
                                'Completo',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold),
                              ),
                            Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: partido.participantes.length >=
                                          partido.capacidad
                                      ? null
                                      : () {
                                          _rechazarPartido(partido);
                                        },
                                  icon: Icon(Icons.close, color: Colors.white),
                                  label: Text('Rechazar'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                ),
                                SizedBox(width: 10),
                                ElevatedButton.icon(
                                  onPressed: partido.participantes.length >=
                                          partido.capacidad
                                      ? null
                                      : () {
                                          _unirseAPartido(partido);
                                        },
                                  icon: Icon(Icons.check, color: Colors.white),
                                  label: Text('Unirse'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  itemCount: partidos.length,
                  itemWidth: MediaQuery.of(context).size.width * 0.8,
                  itemHeight: MediaQuery.of(context).size.height * 0.6,
                  layout: SwiperLayout.STACK,
                  pagination: SwiperPagination(),
                  control: SwiperControl(),
                ),
    );
  }
}
