class Cronograma {
  final int id;
  final int idUsuario;
  final int idMateria;
  final String diaSemana;
  final String horaInicio;
  final String horaFinal;
  final String nomeMateria;

  Cronograma({
    required this.id,
    required this.idUsuario,
    required this.idMateria,
    required this.diaSemana,
    required this.horaInicio,
    required this.horaFinal,
    required this.nomeMateria,
  });

  factory Cronograma.fromMap(Map<String, dynamic> map) {
    return Cronograma(
      id: map['id_cronograma'] ?? 0,
      idUsuario: map['id_usuario'] ?? 0,
      idMateria: map['id_materia'] ?? 0,
      diaSemana: map['dia_semana'] ?? '',
      horaInicio: map['hora_inicio'] ?? '',
      horaFinal: map['hora_final'] ?? '',
      nomeMateria: map['nome_materia'] ?? 'Matéria',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_cronograma': id,
      'id_usuario': idUsuario,
      'id_materia': idMateria,
      'dia_semana': diaSemana,
      'hora_inicio': horaInicio,
      'hora_final': horaFinal,
    };
  }
}
