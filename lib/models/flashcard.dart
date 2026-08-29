class Flashcard {
  final int id;
  final int idMateria;
  final int idUsuario;
  final String pergunta;
  final String tema;
  final String resposta;
  final String nomeMateria;

  Flashcard({
    required this.id,
    required this.idMateria,
    required this.idUsuario,
    required this.pergunta,
    required this.tema,
    required this.resposta,
    required this.nomeMateria,
  });

  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      id: map['id_flash'] ?? 0,
      idMateria: map['id_materia'] ?? 0,
      idUsuario: map['id_usuario'] ?? 0,
      pergunta: map['pergunta'] ?? '',
      tema: map['tema'] ?? '',
      resposta: map['resposta'] ?? '',
      nomeMateria: map['nome_materia'] ?? 'Matéria',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_flash': id,
      'id_materia': idMateria,
      'id_usuario': idUsuario,
      'pergunta': pergunta,
      'tema': tema,
      'resposta': resposta,
    };
  }
}
