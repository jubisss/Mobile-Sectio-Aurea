class Materia {
  final int id;
  final String nome;
  final String cor;
  final int idUsuario;
  final int ativo;

  Materia({
    required this.id,
    required this.nome,
    required this.cor,
    required this.idUsuario,
    required this.ativo,
  });

  factory Materia.fromMap(Map<String, dynamic> map) {
    return Materia(
      id: map['id_materia'] ?? 0,
      nome: map['nome'] ?? '',
      cor: map['cor'] ?? '0xff5170ff',
      idUsuario: map['id_usuario'] ?? 0,
      ativo: map['ativo'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_materia': id,
      'nome': nome,
      'cor': cor,
      'id_usuario': idUsuario,
      'ativo': ativo,
    };
  }
}
