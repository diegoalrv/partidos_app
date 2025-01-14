import 'package:flutter/material.dart';
import '../models/equipo.dart';
import '../services/equipo_service.dart';

class EquipoViewModel with ChangeNotifier {
  final EquipoService _equipoService;
  List<Equipo> _equipos = [];
  bool _isLoading = false;

  EquipoViewModel(this._equipoService) {
    _init();
  }

  List<Equipo> get equipos => _equipos;
  bool get isLoading => _isLoading;

  void _init() {
    _equipoService.getEquiposStream().listen((event) {
      _equipos = event;
      notifyListeners();
    });
  }

  Future<bool> crearEquipo({
    required String nombre,
    required String descripcion,
    required String creadorId,
    List<String>? miembros,
  }) async {
    _isLoading = true;
    notifyListeners();

    bool success = await _equipoService.crearEquipo(
      nombre: nombre,
      descripcion: descripcion,
      creadorId: creadorId,
      miembros: miembros,
    );

    _isLoading = false;
    notifyListeners();

    return success;
  }

  Future<bool> anadirMiembro(String equipoId, String usuarioId) async {
    return await _equipoService.anadirMiembro(equipoId, usuarioId);
  }

  Future<bool> eliminarMiembro(String equipoId, String usuarioId) async {
    return await _equipoService.eliminarMiembro(equipoId, usuarioId);
  }
}
