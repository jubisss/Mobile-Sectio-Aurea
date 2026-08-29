class Tarefa {
  final int id;
  final String nomeTarefa;
  final String dificuldade;
  final String prazo;
  final int idUsuario;

  Tarefa({
    required this.id,
    required this.nomeTarefa,
    required this.dificuldade,
    required this.prazo,
    required this.idUsuario,
  });

  factory Tarefa.fromMap(Map<String, dynamic> map) {
    return Tarefa(
      id: map['id_tarefa'] ?? 0,
      nomeTarefa: map['nome_tarefa'] ?? '',
      dificuldade: map['dificuldade'] ?? 'Média',
      prazo: map['prazo'] ?? '',
      idUsuario: map['id_usuario'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_tarefa': id,
      'nome_tarefa': nomeTarefa,
      'dificuldade': dificuldade,
      'prazo': prazo,
      'id_usuario': idUsuario,
    };
  }

  // Sorting logic based on priority: shorter deadline first, then difficulty (Difícil -> Média -> Fácil)
  static int compareByPriority(Tarefa a, Tarefa b) {
    // 1. Deadline (prazo) comparison
    if (a.prazo.isNotEmpty && b.prazo.isEmpty) return -1;
    if (a.prazo.isEmpty && b.prazo.isNotEmpty) return 1;
    if (a.prazo.isNotEmpty && b.prazo.isNotEmpty) {
      int dateComp = a.prazo.compareTo(b.prazo);
      if (dateComp != 0) return dateComp;
    }

    // 2. Difficulty comparison
    final diffWeight = {'Difícil': 3, 'Média': 2, 'Fácil': 1};
    int weightA = diffWeight[a.dificuldade] ?? 2;
    int weightB = diffWeight[b.dificuldade] ?? 2;
    return weightB.compareTo(weightA); // Higher difficulty comes first
  }
}
