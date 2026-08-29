class Evento {
  final int id;
  final int idUsuario;
  final String tipo;
  final String data;
  final String cor;

  Evento({
    required this.id,
    required this.idUsuario,
    required this.tipo,
    required this.data,
    required this.cor,
  });

  factory Evento.fromMap(Map<String, dynamic> map) {
    return Evento(
      id: map['id_evento'] ?? 0,
      idUsuario: map['id_usuario'] ?? 0,
      tipo: map['tipo'] ?? '',
      data: map['data'] ?? '',
      cor: map['cor'] ?? '0xff5170ff',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_evento': id,
      'id_usuario': idUsuario,
      'tipo': tipo,
      'data': data,
      'cor': cor,
    };
  }
}
