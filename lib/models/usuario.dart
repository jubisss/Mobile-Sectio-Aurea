class Usuario {
  final int id;
  final String nome;
  final String email;
  final String senha;
  final String plano;
  final String tipoDom;
  final String clasInteli;
  final String foto;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.senha,
    required this.plano,
    required this.tipoDom,
    required this.clasInteli,
    required this.foto,
  });

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id_usuario'] ?? 0,
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      senha: map['senha'] ?? '',
      plano: map['plano'] ?? 'Gratuito',
      tipoDom: map['tipo_dom'] ?? '',
      clasInteli: map['clas_inteli'] ?? '',
      foto: map['foto'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_usuario': id,
      'nome': nome,
      'email': email,
      'senha': senha,
      'plano': plano,
      'tipo_dom': tipoDom,
      'clas_inteli': clasInteli,
      'foto': foto,
    };
  }

  Usuario copyWith({
    int? id,
    String? nome,
    String? email,
    String? senha,
    String? plano,
    String? tipoDom,
    String? clasInteli,
    String? foto,
  }) {
    return Usuario(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      senha: senha ?? this.senha,
      plano: plano ?? this.plano,
      tipoDom: tipoDom ?? this.tipoDom,
      clasInteli: clasInteli ?? this.clasInteli,
      foto: foto ?? this.foto,
    );
  }
}
