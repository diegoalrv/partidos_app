class Partido {
  final String id;
  final String deporte;
  final String descripcion;
  final String horario;
  final String lugar;
  final int capacidad;
  List<String> participantes; // Lista de IDs de usuarios que se han unido
  final String? imagenUrl; // Add this line

  Partido({
    required this.id,
    required this.deporte,
    required this.descripcion,
    required this.horario,
    required this.lugar,
    this.capacidad = 10,
    this.participantes = const [],
    this.imagenUrl, // Add this line
  });

  factory Partido.fromMap(Map<String, dynamic> data, String documentId) {
    return Partido(
      id: documentId,
      deporte: data['deporte'] ?? '',
      descripcion: data['descripcion'] ?? '',
      horario: data['horario'] ?? '',
      lugar: data['lugar'] ?? '',
      capacidad: data['capacidad'] ?? 10,
      participantes: List<String>.from(data['participantes'] ?? const []),
      imagenUrl: data['imagenUrl'], // Add this line
    );
  }
}
