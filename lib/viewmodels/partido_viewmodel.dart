import 'package:flutter/material.dart';
import '../models/partido.dart';
import '../services/partido_service.dart';

class PartidoViewModel with ChangeNotifier {
  final PartidoService _partidoService;
  List<Partido> _partidos = [];
  bool _isLoading = false;

  PartidoViewModel(this._partidoService) {
    _init();
  }

  List<Partido> get partidos => _partidos;
  bool get isLoading => _isLoading;

  void _init() {
    _partidoService.getPartidosStream().listen((event) {
      _partidos = event;
      notifyListeners();
    });
  }

  Future<bool> crearPartido({
    required String deporte,
    required String descripcion,
    required String horario,
    required String lugar,
    required int capacidad,
    required String creadorId,
    String? imagenUrl,
  }) async {
    _isLoading = true;
    notifyListeners();

    bool success = await _partidoService.crearPartido(
      deporte: deporte,
      descripcion: descripcion,
      horario: horario,
      lugar: lugar,
      capacidad: capacidad,
      creadorId: creadorId,
      imagenUrl: imagenUrl,
    );

    _isLoading = false;
    notifyListeners();

    return success;
  }

  Future<bool> unirseAPartido(String partidoId, String usuarioId) async {
    return await _partidoService.unirseAPartido(partidoId, usuarioId);
  }
}
