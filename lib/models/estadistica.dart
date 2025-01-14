class Estadistica {
  final String usuarioId;
  final int partidosJugados;
  final int victorias;
  final int derrotas;
  final int puntos;

  Estadistica({
    required this.usuarioId,
    this.partidosJugados = 0,
    this.victorias = 0,
    this.derrotas = 0,
    this.puntos = 0,
  });

  factory Estadistica.fromMap(Map<String, dynamic> data) {
    return Estadistica(
      usuarioId: data['usuarioId'],
      partidosJugados: data['partidosJugados'] ?? 0,
      victorias: data['victorias'] ?? 0,
      derrotas: data['derrotas'] ?? 0,
      puntos: data['puntos'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'usuarioId': usuarioId,
      'partidosJugados': partidosJugados,
      'victorias': victorias,
      'derrotas': derrotas,
      'puntos': puntos,
    };
  }
}
