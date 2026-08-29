import 'dart:convert';
import 'package:http/http.dart' as http;

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  bool isLocalFallback = false;
  bool _hasCheckedConnection = false;
  
  // Local XAMPP PHP API base URL
  static const String baseUrl = 'http://localhost/pi_api';
  
  // Bearer Token for authenticated requests
  String? _token;

  // Local fallback mock storage lists for offline mode
  final List<Map<String, dynamic>> _mockUsers = [];
  final List<Map<String, dynamic>> _mockMaterias = [];
  final List<Map<String, dynamic>> _mockTarefas = [];
  final List<Map<String, dynamic>> _mockNotes = [];
  final List<Map<String, dynamic>> _mockCronogramas = [];
  final List<Map<String, dynamic>> _mockTimers = [];
  final List<Map<String, dynamic>> _mockEvents = [];
  final List<Map<String, dynamic>> _mockFlashcards = [];
  final List<Map<String, dynamic>> _mockInteligencias = [];

  // Seed mock data for demonstration/offline mode
  void seedMockData() {
    _mockUsers.clear();
    _mockMaterias.clear();
    _mockTarefas.clear();
    _mockNotes.clear();
    _mockCronogramas.clear();
    _mockTimers.clear();
    _mockEvents.clear();
    _mockFlashcards.clear();
    _mockInteligencias.clear();

    _mockUsers.add({
      "id_usuario": 1,
      "nome": "Juliana",
      "email": "juju@gmail.com",
      "senha": "123",
      "ativo": 1,
      "foto": "",
      "plano": "Gratuito",
      "tipo_dom": "Lógico-matemática",
      "clas_inteli": "0xffffbd59"
    });

    _mockMaterias.addAll([
      {"id_materia": 1, "nome": "Matemática", "cor": "0xffffbd59", "id_usuario": 1, "ativo": 1},
      {"id_materia": 2, "nome": "Português", "cor": "0xff9f042c", "id_usuario": 1, "ativo": 1},
      {"id_materia": 3, "nome": "Educação Física", "cor": "0xff00bf63", "id_usuario": 1, "ativo": 1},
    ]);

    _mockTarefas.addAll([
      {"id_tarefa": 1, "nome_tarefa": "Estudar limites", "dificuldade": "Difícil", "prazo": "2026-06-20", "id_usuario": 1},
      {"id_tarefa": 2, "nome_tarefa": "Ler Dom Casmurro", "dificuldade": "Média", "prazo": "2026-06-25", "id_usuario": 1},
      {"id_tarefa": 3, "nome_tarefa": "Exercícios de Geometria", "dificuldade": "Fácil", "prazo": "2026-06-18", "id_usuario": 1},
    ]);

    _mockNotes.addAll([
      {
        "id_anotacao": 1,
        "conteudo": jsonEncode({
          "title": "Anotação de Álgebra",
          "description": "Fórmula de Bhaskara: x = (-b ± √Δ) / 2a",
          "favorite": true,
          "checklist": [
            {"text": "Revisar equações do 2o grau", "done": true},
            {"text": "Fazer exercícios da apostila", "done": false}
          ],
          "bold": true,
          "italic": false,
        }),
        "id_usuario": 1,
        "cor_nota": "0xfff4f1eb"
      }
    ]);

    _mockEvents.addAll([
      {"id_evento": 1, "id_usuario": 1, "tipo": "Prova de Cálculo", "data": "2026-06-15", "cor": "0xffffbd59"},
      {"id_evento": 2, "id_usuario": 1, "tipo": "Seminário de Português", "data": "2026-06-18", "cor": "0xff9f042c"},
    ]);

    _mockCronogramas.addAll([
      {"id_cronograma": 1, "id_usuario": 1, "id_materia": 1, "dia_semana": "Segunda", "hora_inicio": "08:00", "hora_final": "09:30"},
      {"id_cronograma": 2, "id_usuario": 1, "id_materia": 2, "dia_semana": "Terça", "hora_inicio": "10:00", "hora_final": "11:30"},
    ]);

    _mockFlashcards.addAll([
      {"id_flash": 1, "id_materia": 1, "id_usuario": 1, "pergunta": "Qual é a derivada de x^2?", "tema": "Derivadas", "resposta": "2x"},
      {"id_flash": 2, "id_materia": 2, "id_usuario": 1, "pergunta": "O que é oxítona?", "tema": "Acentuação", "resposta": "Palavra cuja última sílaba é tônica"},
    ]);

    _mockInteligencias.addAll([
      {
        "nome": "Lógico-matemática",
        "metodo": jsonEncode([
          "Pomodoro",
          "Método Cornell",
          "Mapa mental",
          "Teste prático",
          "Mnemônica com números ou listas ordenadas",
          "Diagrama de fluxos",
          "Repetição (revisão) espaçada"
        ]),
        "cor": "#ffbd59"
      },
      {
        "nome": "Linguística",
        "metodo": jsonEncode([
          "Pomodoro",
          "Técnica Feynman",
          "Leitura Savoring",
          "Grupos de estudo",
          "Flashcards",
          "Mnemônica com palavras, poemas ou músicas",
          "Repetição (revisão) espaçada"
        ]),
        "cor": "#9f042c"
      },
      {
        "nome": "Corporal",
        "metodo": jsonEncode([
          "Pomodoro",
          "Teste prático",
          "Grupos de estudo",
          "Mnemônica com movimentos",
          "Estudo com vídeos educativos",
          "Repetição (revisão) espaçada",
          "Flashcards"
        ]),
        "cor": "#00bf63"
      },
      {
        "nome": "Cinestésica",
        "metodo": jsonEncode([
          "Pomodoro",
          "Teste prático",
          "Grupos de estudo",
          "Mnemônica com movimentos",
          "Estudo com vídeos educativos",
          "Repetição (revisão) espaçada",
          "Flashcards"
        ]),
        "cor": "#00bf63"
      },
      {
        "nome": "Espacial",
        "metodo": jsonEncode([
          "Pomodoro",
          "Método Cornell",
          "Mapa mental",
          "Flashcards",
          "Mnemônica com imagens e objetos",
          "Diagrama de fluxos",
          "Repetição (revisão) espaçada"
        ]),
        "cor": "#d203a4"
      },
      {
        "nome": "Interpessoal",
        "metodo": jsonEncode([
          "Pomodoro",
          "Técnica Feynman",
          "Teste prático",
          "Mnemônica com poemas ou músicas",
          "Estudo com vídeos educativos",
          "Repetição (revisão) espaçada",
          "Grupos de estudo"
        ]),
        "cor": "#ff5f00"
      },
      {
        "nome": "Musical",
        "metodo": jsonEncode([
          "Pomodoro",
          "Mnemônica com poemas ou músicas",
          "Gravação de podcast",
          "Estudo com vídeos educativos",
          "Repetição (revisão) espaçada"
        ]),
        "cor": "#8a03d2"
      },
      {
        "nome": "Intrapessoal",
        "metodo": jsonEncode([
          "Pomodoro",
          "Técnica Feynman",
          "Método Cornell",
          "Leitura Savoring",
          "Repetição (revisão) espaçada",
          "Flashcards"
        ]),
        "cor": "#5170ff"
      }
    ]);
  }

  // Check API connectivity, toggle isLocalFallback
  Future<void> connect() async {
    if (_mockUsers.isEmpty) {
      seedMockData();
    }
    if (_hasCheckedConnection) {
      return;
    }
    
    try {
      final response = await http.get(Uri.parse('$baseUrl/inteligencias')).timeout(const Duration(seconds: 2));
      if (response.statusCode == 200) {
        isLocalFallback = false;
      } else {
        isLocalFallback = true;
        print("PHP API returned status code ${response.statusCode}. Falling back to mock.");
      }
    } catch (e) {
      isLocalFallback = true;
      print("Could not connect to PHP API. Offline mode fallback activated. Error: $e");
    }
    _hasCheckedConnection = true;
  }



  String _formatColorToFlutterHex(String? dbColor) {
    if (dbColor == null || dbColor.isEmpty) return '0xff5170ff'; // default blue
    String clean = dbColor.replaceAll('#', '').trim();
    if (clean.length == 6) {
      return '0xff$clean';
    }
    if (clean.length == 8) {
      return '0x$clean';
    }
    return '0xff5170ff';
  }

  String _getColorHexForIntelligence(String? tipoDom) {
    if (tipoDom == null || tipoDom.isEmpty) return '0xff5170ff'; // default blue
    switch (tipoDom.trim()) {
      case 'Lógico-matemática':
        return '0xffffbd59';
      case 'Linguística':
        return '0xff9f042c';
      case 'Corporal':
        return '0xff00bf63';
      case 'Intrapessoal':
        return '0xff5170ff';
      case 'Interpessoal':
        return '0xffff5f00';
      case 'Musical':
        return '0xff8a03d2';
      case 'Espacial':
        return '0xffd203a4';
      default:
        return '0xff5170ff';
    }
  }

  int _parseInt(dynamic value) {
    if (value == null) return 1;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 1;
    }
    return 1;
  }

  // Get HTTP headers with Authorization Bearer token
  Map<String, String> _headers() {
    final h = {'Content-Type': 'application/json'};
    if (_token != null) {
      h['Authorization'] = 'Bearer $_token';
    }
    return h;
  }

  // --- USER AUTHENTICATION ---

  Future<Map<String, dynamic>?> login(String email, String password) async {
    await connect();
    if (isLocalFallback) {
      try {
        final match = _mockUsers.firstWhere(
          (u) => u["email"] == email && u["senha"] == password,
        );
        final userCopy = Map<String, dynamic>.from(match);
        userCopy["clas_inteli"] = _getColorHexForIntelligence(userCopy["tipo_dom"]);
        return userCopy;
      } catch (_) {
        return null;
      }
    } else {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/login'),
          headers: _headers(),
          body: jsonEncode({"email": email, "senha": password}),
        ).timeout(const Duration(seconds: 4));

        if (response.statusCode == 200) {
          final body = jsonDecode(response.body);
          _token = body['token'];
          final u = body['user'];
          
          return {
            "id_usuario": _parseInt(u['id'] ?? u['id_usuario']),
            "nome": u['nome'],
            "email": u['email'],
            "senha": password, // guardamos a senha em texto puro
            "ativo": 1,
            "foto": u['foto'] ?? '',
            "plano": u['plano'] ?? 'Gratuito',
            "tipo_dom": u['tipo_dom'] ?? '',
            "clas_inteli": u['cor_dominante'] != null
                ? _formatColorToFlutterHex(u['cor_dominante'])
                : _getColorHexForIntelligence(u['tipo_dom']),
            "inteligencias_dominantes": u['clas_inteli']
          };
        }
        return null;
      } catch (e) {
        print("Login API error: $e. Falling back to mock.");
        isLocalFallback = true;
        return login(email, password);
      }
    }
  }

  Future<Map<String, dynamic>?> register(String name, String email, String password) async {
    await connect();
    if (isLocalFallback) {
      int nextId = _mockUsers.length + 1;
      final newUser = {
        "id_usuario": nextId,
        "nome": name,
        "email": email,
        "senha": password,
        "ativo": 1,
        "foto": "",
        "plano": "Gratuito",
        "tipo_dom": "",
        "clas_inteli": ""
      };
      _mockUsers.add(newUser);
      return newUser;
    } else {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/register'),
          headers: _headers(),
          body: jsonEncode({
            "nome": name,
            "email": email,
            "senha": password,
            "plano": "Gratuito",
            "tipo_dom": "",
            "clas_inteli": []
          }),
        ).timeout(const Duration(seconds: 4));

        if (response.statusCode == 201 || response.statusCode == 200) {
          // Após cadastrar com sucesso, faz o login para obter o token
          return await login(email, password);
        }
        return null; // Erro ou e-mail duplicado
      } catch (e) {
        print("Register API error: $e. Falling back to mock.");
        isLocalFallback = true;
        return register(name, email, password);
      }
    }
  }

  Future<bool> updateUser(Map<String, dynamic> user) async {
    await connect();
    int userId = user["id_usuario"];
    if (isLocalFallback) {
      for (int i = 0; i < _mockUsers.length; i++) {
        if (_mockUsers[i]["id_usuario"] == userId) {
          _mockUsers[i] = user;
          return true;
        }
      }
      return false;
    } else {
      try {
        dynamic parsedClas = user["inteligencias_dominantes"] ?? user["clas_inteli"];
        if (parsedClas is String && parsedClas.startsWith('[') && parsedClas.endsWith(']')) {
          try {
            parsedClas = jsonDecode(parsedClas);
          } catch (_) {}
        }
        
        final response = await http.put(
          Uri.parse('$baseUrl/perfil'),
          headers: _headers(),
          body: jsonEncode({
            "nome": user["nome"],
            "foto": user["foto"],
            "plano": user["plano"],
            "tipo_dom": user["tipo_dom"],
            "clas_inteli": parsedClas
          }),
        ).timeout(const Duration(seconds: 4));

        return response.statusCode == 200;
      } catch (e) {
        print("UpdateUser API error: $e");
        return false;
      }
    }
  }

  // --- PASSWORD UPDATE & RECOVERY ---

  Future<bool> trocarSenha(String senhaAntiga, String novaSenha) async {
    await connect();
    if (isLocalFallback) {
      // Mock local update
      if (_mockUsers.isNotEmpty) {
        if (_mockUsers[0]["senha"] == senhaAntiga) {
          _mockUsers[0]["senha"] = novaSenha;
          return true;
        }
      }
      return false;
    } else {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/trocar-senha'),
          headers: _headers(),
          body: jsonEncode({
            "senha_antiga": senhaAntiga,
            "nova_senha": novaSenha
          }),
        ).timeout(const Duration(seconds: 4));
        
        return response.statusCode == 200;
      } catch (e) {
        print("TrocarSenha API error: $e");
        return false;
      }
    }
  }

  Future<String?> recuperarSenha(String email) async {
    await connect();
    if (isLocalFallback) {
      // Retorna código mockado
      return "123456";
    } else {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/recuperar-senha'),
          headers: _headers(),
          body: jsonEncode({"email": email}),
        ).timeout(const Duration(seconds: 4));
        
        if (response.statusCode == 200) {
          final body = jsonDecode(response.body);
          return body['code'].toString(); // Retorna o código enviado para teste
        }
        return null;
      } catch (e) {
        print("RecuperarSenha API error: $e");
        return null;
      }
    }
  }

  Future<bool> resetarSenha(String email, String codigo, String novaSenha) async {
    await connect();
    if (isLocalFallback) {
      if (_mockUsers.isNotEmpty && codigo == "123456") {
        _mockUsers[0]["senha"] = novaSenha;
        return true;
      }
      return false;
    } else {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/resetar-senha'),
          headers: _headers(),
          body: jsonEncode({
            "email": email,
            "codigo": codigo,
            "nova_senha": novaSenha
          }),
        ).timeout(const Duration(seconds: 4));
        
        return response.statusCode == 200;
      } catch (e) {
        print("ResetarSenha API error: $e");
        return false;
      }
    }
  }

  // --- MATERIAS (SUBJECTS) ---

  Future<List<Map<String, dynamic>>> getMaterias(int userId) async {
    await connect();
    if (isLocalFallback) {
      return _mockMaterias.where((m) => m["id_usuario"] == userId && m["ativo"] == 1).toList();
    } else {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/materias'),
          headers: _headers(),
        ).timeout(const Duration(seconds: 4));

        if (response.statusCode == 200) {
          final List<dynamic> list = jsonDecode(response.body);
          return list.map((item) => {
            "id_materia": _parseInt(item['id_materia'] ?? item['id']),
            "nome": item['nome'],
            "cor": item['cor'],
            "id_usuario": userId,
            "ativo": 1
          }).toList();
        }
        return [];
      } catch (e) {
        print("getMaterias API error: $e");
        isLocalFallback = true;
        return getMaterias(userId);
      }
    }
  }

  Future<int> createMateria(String name, String color, int userId) async {
    await connect();
    if (isLocalFallback) {
      int nextId = _mockMaterias.length + 1;
      _mockMaterias.add({
        "id_materia": nextId,
        "nome": name,
        "cor": color,
        "id_usuario": userId,
        "ativo": 1
      });
      return nextId;
    } else {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/materias'),
          headers: _headers(),
          body: jsonEncode({"nome": name, "cor": color}),
        ).timeout(const Duration(seconds: 4));

        if (response.statusCode == 201 || response.statusCode == 200) {
          final body = jsonDecode(response.body);
          return _parseInt(body['id_materia'] ?? body['id']);
        }
        return 0;
      } catch (e) {
        print("createMateria API error: $e");
        return 0;
      }
    }
  }

  Future<bool> deleteMateria(int idMateria, int userId) async {
    await connect();
    if (isLocalFallback) {
      _mockMaterias.removeWhere((m) => m["id_materia"] == idMateria && m["id_usuario"] == userId);
      return true;
    } else {
      try {
        final response = await http.delete(
          Uri.parse('$baseUrl/materias/$idMateria'),
          headers: _headers(),
        ).timeout(const Duration(seconds: 4));

        return response.statusCode == 200;
      } catch (e) {
        print("deleteMateria API error: $e");
        return false;
      }
    }
  }

  // --- TAREFAS (TASKS) ---

  Future<List<Map<String, dynamic>>> getTarefas(int userId) async {
    await connect();
    if (isLocalFallback) {
      return _mockTarefas.where((t) => t["id_usuario"] == userId).toList();
    } else {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/tarefas'),
          headers: _headers(),
        ).timeout(const Duration(seconds: 4));

        if (response.statusCode == 200) {
          final List<dynamic> list = jsonDecode(response.body);
          return list.map((item) => {
            "id_tarefa": _parseInt(item['id_tarefa'] ?? item['id']),
            "nome_tarefa": item['nome_tarefa'],
            "dificuldade": item['dificuldade'],
            "prazo": item['prazo'] != null ? item['prazo'].toString().split(' ')[0] : '',
            "id_usuario": userId,
            "ativo": _parseInt(item['ativo'] ?? 1)
          }).toList();
        }
        return [];
      } catch (e) {
        print("getTarefas API error: $e");
        isLocalFallback = true;
        return getTarefas(userId);
      }
    }
  }

  Future<int> createTarefa(String name, String difficulty, String deadline, int userId) async {
    await connect();
    if (isLocalFallback) {
      int nextId = _mockTarefas.length + 1;
      _mockTarefas.add({
        "id_tarefa": nextId,
        "nome_tarefa": name,
        "dificuldade": difficulty,
        "prazo": deadline,
        "id_usuario": userId,
        "ativo": 1
      });
      return nextId;
    } else {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/tarefas'),
          headers: _headers(),
          body: jsonEncode({
            "nome_tarefa": name,
            "dificuldade": difficulty,
            "prazo": deadline,
            "ativo": 1
          }),
        ).timeout(const Duration(seconds: 4));

        if (response.statusCode == 201 || response.statusCode == 200) {
          final body = jsonDecode(response.body);
          return _parseInt(body['id_tarefa'] ?? body['id']);
        }
        return 0;
      } catch (e) {
        print("createTarefa API error: $e");
        return 0;
      }
    }
  }

  Future<bool> updateTarefa(Map<String, dynamic> tarefa) async {
    await connect();
    int idTarefa = tarefa["id_tarefa"];
    int userId = tarefa["id_usuario"];
    if (isLocalFallback) {
      for (int i = 0; i < _mockTarefas.length; i++) {
        if (_mockTarefas[i]["id_tarefa"] == idTarefa && _mockTarefas[i]["id_usuario"] == userId) {
          _mockTarefas[i] = tarefa;
          return true;
        }
      }
      return false;
    } else {
      try {
        final response = await http.put(
          Uri.parse('$baseUrl/tarefas/$idTarefa'),
          headers: _headers(),
          body: jsonEncode({
            "nome_tarefa": tarefa["nome_tarefa"],
            "dificuldade": tarefa["dificuldade"],
            "prazo": tarefa["prazo"],
            "ativo": tarefa["ativo"]
          }),
        ).timeout(const Duration(seconds: 4));

        return response.statusCode == 200;
      } catch (e) {
        print("updateTarefa API error: $e");
        return false;
      }
    }
  }

  Future<bool> deleteTarefa(int idTarefa, int userId) async {
    await connect();
    if (isLocalFallback) {
      _mockTarefas.removeWhere((t) => t["id_tarefa"] == idTarefa && t["id_usuario"] == userId);
      return true;
    } else {
      try {
        final response = await http.delete(
          Uri.parse('$baseUrl/tarefas/$idTarefa'),
          headers: _headers(),
        ).timeout(const Duration(seconds: 4));

        return response.statusCode == 200;
      } catch (e) {
        print("deleteTarefa API error: $e");
        return false;
      }
    }
  }

  // --- BLOCO (NOTES) ---

  Future<List<Map<String, dynamic>>> getNotes(int userId) async {
    await connect();
    if (isLocalFallback) {
      return _mockNotes.where((n) => n["id_usuario"] == userId).toList();
    } else {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/blocos'),
          headers: _headers(),
        ).timeout(const Duration(seconds: 4));

        if (response.statusCode == 200) {
          final List<dynamic> list = jsonDecode(response.body);
          return list.map((item) => {
            "id_anotacao": _parseInt(item['id_anotacao'] ?? item['id']),
            "conteudo": item['conteudo'],
            "id_usuario": userId,
            "cor_nota": item['cor_nota'] ?? '0xfff4f1eb'
          }).toList();
        }
        return [];
      } catch (e) {
        print("getNotes API error: $e");
        isLocalFallback = true;
        return getNotes(userId);
      }
    }
  }

  Future<int> createNote(String contentJson, String noteColor, int userId) async {
    await connect();
    if (isLocalFallback) {
      int nextId = _mockNotes.length + 1;
      _mockNotes.add({
        "id_anotacao": nextId,
        "conteudo": contentJson,
        "id_usuario": userId,
        "cor_nota": noteColor
      });
      return nextId;
    } else {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/blocos'),
          headers: _headers(),
          body: jsonEncode({
            "conteudo": contentJson,
            "cor_nota": noteColor
          }),
        ).timeout(const Duration(seconds: 4));

        if (response.statusCode == 201 || response.statusCode == 200) {
          final body = jsonDecode(response.body);
          return _parseInt(body['id_anotacao'] ?? body['id']);
        }
        return 0;
      } catch (e) {
        print("createNote API error: $e");
        return 0;
      }
    }
  }

  Future<bool> updateNote(int idAnotacao, String contentJson, String noteColor, int userId) async {
    await connect();
    if (isLocalFallback) {
      for (int i = 0; i < _mockNotes.length; i++) {
        if (_mockNotes[i]["id_anotacao"] == idAnotacao && _mockNotes[i]["id_usuario"] == userId) {
          _mockNotes[i]["conteudo"] = contentJson;
          _mockNotes[i]["cor_nota"] = noteColor;
          return true;
        }
      }
      return false;
    } else {
      try {
        final response = await http.put(
          Uri.parse('$baseUrl/blocos/$idAnotacao'),
          headers: _headers(),
          body: jsonEncode({
            "conteudo": contentJson,
            "cor_nota": noteColor
          }),
        ).timeout(const Duration(seconds: 4));

        return response.statusCode == 200;
      } catch (e) {
        print("updateNote API error: $e");
        return false;
      }
    }
  }

  Future<bool> deleteNote(int idAnotacao, int userId) async {
    await connect();
    if (isLocalFallback) {
      _mockNotes.removeWhere((n) => n["id_anotacao"] == idAnotacao && n["id_usuario"] == userId);
      return true;
    } else {
      try {
        final response = await http.delete(
          Uri.parse('$baseUrl/blocos/$idAnotacao'),
          headers: _headers(),
        ).timeout(const Duration(seconds: 4));

        return response.statusCode == 200;
      } catch (e) {
        print("deleteNote API error: $e");
        return false;
      }
    }
  }

  // --- CRONOGRAMA (WEEKLY SCHEDULE) ---

  Future<List<Map<String, dynamic>>> getCronograma(int userId) async {
    await connect();
    if (isLocalFallback) {
      List<Map<String, dynamic>> res = [];
      for (var c in _mockCronogramas.where((cron) => cron["id_usuario"] == userId)) {
        var mat = _mockMaterias.firstWhere((m) => m["id_materia"] == c["id_materia"], orElse: () => {"nome": "Matéria Desconhecida"});
        res.add({
          "id_cronograma": c["id_cronograma"],
          "id_usuario": c["id_usuario"],
          "id_materia": c["id_materia"],
          "dia_semana": c["dia_semana"],
          "hora_inicio": c["hora_inicio"],
          "hora_final": c["hora_final"],
          "nome_materia": mat["nome"]
        });
      }
      return res;
    } else {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/cronogramas'),
          headers: _headers(),
        ).timeout(const Duration(seconds: 4));

        if (response.statusCode == 200) {
          final List<dynamic> list = jsonDecode(response.body);
          return list.map((item) => {
            "id_cronograma": _parseInt(item['id_cronograma'] ?? item['id']),
            "id_usuario": userId,
            "id_materia": _parseInt(item['id_materia']),
            "dia_semana": item['dia_semana'],
            "hora_inicio": item['hora_inicio'] != null ? item['hora_inicio'].toString().substring(0, 5) : '',
            "hora_final": item['hora_final'] != null ? item['hora_final'].toString().substring(0, 5) : '',
            "nome_materia": item['nome_materia'] ?? 'Matéria'
          }).toList();
        }
        return [];
      } catch (e) {
        print("getCronograma API error: $e");
        isLocalFallback = true;
        return getCronograma(userId);
      }
    }
  }

  Future<int> createCronograma(int idMateria, String weekday, String startTime, String endTime, int userId) async {
    await connect();
    if (isLocalFallback) {
      int nextId = _mockCronogramas.length + 1;
      _mockCronogramas.add({
        "id_cronograma": nextId,
        "id_usuario": userId,
        "id_materia": idMateria,
        "dia_semana": weekday,
        "hora_inicio": startTime,
        "hora_final": endTime
      });
      return nextId;
    } else {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/cronogramas'),
          headers: _headers(),
          body: jsonEncode({
            "id_materia": idMateria,
            "dia_semana": weekday,
            "hora_inicio": startTime,
            "hora_final": endTime
          }),
        ).timeout(const Duration(seconds: 4));

        if (response.statusCode == 201 || response.statusCode == 200) {
          final body = jsonDecode(response.body);
          return _parseInt(body['id_cronograma'] ?? body['id']);
        }
        return 0;
      } catch (e) {
        print("createCronograma API error: $e");
        return 0;
      }
    }
  }

  Future<bool> deleteCronograma(int idCronograma, int userId) async {
    await connect();
    if (isLocalFallback) {
      _mockCronogramas.removeWhere((c) => c["id_cronograma"] == idCronograma && c["id_usuario"] == userId);
      return true;
    } else {
      try {
        final response = await http.delete(
          Uri.parse('$baseUrl/cronogramas/$idCronograma'),
          headers: _headers(),
        ).timeout(const Duration(seconds: 4));

        return response.statusCode == 200;
      } catch (e) {
        print("deleteCronograma API error: $e");
        return false;
      }
    }
  }

  // --- CRONOMETRO (TIMER ENTRIES) ---

  Future<List<Map<String, dynamic>>> getTimerEntries(int userId) async {
    await connect();
    if (isLocalFallback) {
      return _mockTimers.where((t) => t["id_usuario"] == userId).toList();
    } else {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/cronometros'),
          headers: _headers(),
        ).timeout(const Duration(seconds: 4));

        if (response.statusCode == 200) {
          final List<dynamic> list = jsonDecode(response.body);
          return list.map((item) => {
            "id_cron": _parseInt(item['id_cron'] ?? item['id']),
            "id_usuario": userId,
            "tempo_cronometro": _parseInt(item['tempo_cronometro']),
            "descricao": item['descricao'] ?? ''
          }).toList();
        }
        return [];
      } catch (e) {
        print("getTimerEntries API error: $e");
        isLocalFallback = true;
        return getTimerEntries(userId);
      }
    }
  }

  Future<int> createTimerEntry(int seconds, String description, int userId) async {
    await connect();
    if (isLocalFallback) {
      int nextId = _mockTimers.length + 1;
      _mockTimers.add({
        "id_cron": nextId,
        "id_usuario": userId,
        "tempo_cronometro": seconds,
        "descricao": description
      });
      return nextId;
    } else {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/cronometros'),
          headers: _headers(),
          body: jsonEncode({
            "tempo_cronometro": seconds,
            "descricao": description
          }),
        ).timeout(const Duration(seconds: 4));

        if (response.statusCode == 201 || response.statusCode == 200) {
          final body = jsonDecode(response.body);
          return _parseInt(body['id_cron'] ?? body['id']);
        }
        return 0;
      } catch (e) {
        print("createTimerEntry API error: $e");
        return 0;
      }
    }
  }

  // --- EVENTOS (CALENDAR EVENTS) ---

  Future<List<Map<String, dynamic>>> getEvents(int userId) async {
    await connect();
    if (isLocalFallback) {
      return _mockEvents.where((e) => e["id_usuario"] == userId).toList();
    } else {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/eventos'),
          headers: _headers(),
        ).timeout(const Duration(seconds: 4));

        if (response.statusCode == 200) {
          final List<dynamic> list = jsonDecode(response.body);
          return list.map((item) => {
            "id_evento": _parseInt(item['id_evento'] ?? item['id']),
            "id_usuario": userId,
            "tipo": item['tipo'],
            "data": item['data'] != null ? item['data'].toString().split(' ')[0] : '',
            "cor": item['cor'] ?? '0xff5170ff'
          }).toList();
        }
        return [];
      } catch (e) {
        print("getEvents API error: $e");
        isLocalFallback = true;
        return getEvents(userId);
      }
    }
  }

  Future<int> createEvent(String type, String dateStr, String color, int userId) async {
    await connect();
    if (isLocalFallback) {
      int nextId = _mockEvents.length + 1;
      _mockEvents.add({
        "id_evento": nextId,
        "id_usuario": userId,
        "tipo": type,
        "data": dateStr,
        "cor": color
      });
      return nextId;
    } else {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/eventos'),
          headers: _headers(),
          body: jsonEncode({
            "tipo": type,
            "data": dateStr,
            "cor": color
          }),
        ).timeout(const Duration(seconds: 4));

        if (response.statusCode == 201 || response.statusCode == 200) {
          final body = jsonDecode(response.body);
          return _parseInt(body['id_evento'] ?? body['id']);
        }
        return 0;
      } catch (e) {
        print("createEvent API error: $e");
        return 0;
      }
    }
  }

  Future<bool> deleteEvent(int idEvento, int userId) async {
    await connect();
    if (isLocalFallback) {
      _mockEvents.removeWhere((e) => e["id_evento"] == idEvento && e["id_usuario"] == userId);
      return true;
    } else {
      try {
        final response = await http.delete(
          Uri.parse('$baseUrl/eventos/$idEvento'),
          headers: _headers(),
        ).timeout(const Duration(seconds: 4));

        return response.statusCode == 200;
      } catch (e) {
        print("deleteEvent API error: $e");
        return false;
      }
    }
  }

  // --- FLASHCARDS ---

  Future<List<Map<String, dynamic>>> getFlashcards(int userId) async {
    await connect();
    if (isLocalFallback) {
      List<Map<String, dynamic>> res = [];
      for (var f in _mockFlashcards.where((flash) => flash["id_usuario"] == userId)) {
        var mat = _mockMaterias.firstWhere((m) => m["id_materia"] == f["id_materia"], orElse: () => {"nome": "Matéria Desconhecida"});
        res.add({
          "id_flash": f["id_flash"],
          "id_materia": f["id_materia"],
          "id_usuario": f["id_usuario"],
          "pergunta": f["pergunta"],
          "tema": f["tema"],
          "resposta": f["resposta"],
          "nome_materia": mat["nome"]
        });
      }
      return res;
    } else {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/flashcards'),
          headers: _headers(),
        ).timeout(const Duration(seconds: 4));

        if (response.statusCode == 200) {
          final List<dynamic> list = jsonDecode(response.body);
          return list.map((item) => {
            "id_flash": _parseInt(item['id_flash'] ?? item['id']),
            "id_materia": _parseInt(item['id_materia']),
            "id_usuario": userId,
            "pergunta": item['pergunta'],
            "tema": item['tema'],
            "resposta": item['resposta'],
            "nome_materia": item['nome_materia'] ?? 'Matéria'
          }).toList();
        }
        return [];
      } catch (e) {
        print("getFlashcards API error: $e");
        isLocalFallback = true;
        return getFlashcards(userId);
      }
    }
  }

  Future<int> createFlashcard(int idMateria, String question, String theme, String answer, int userId) async {
    await connect();
    if (isLocalFallback) {
      int nextId = _mockFlashcards.length + 1;
      _mockFlashcards.add({
        "id_flash": nextId,
        "id_materia": idMateria,
        "id_usuario": userId,
        "pergunta": question,
        "tema": theme,
        "resposta": answer
      });
      return nextId;
    } else {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/flashcards'),
          headers: _headers(),
          body: jsonEncode({
            "id_materia": idMateria,
            "pergunta": question,
            "tema": theme,
            "resposta": answer
          }),
        ).timeout(const Duration(seconds: 4));

        if (response.statusCode == 201 || response.statusCode == 200) {
          final body = jsonDecode(response.body);
          return _parseInt(body['id_flash'] ?? body['id']);
        }
        return 0;
      } catch (e) {
        print("createFlashcard API error: $e");
        return 0;
      }
    }
  }

  Future<bool> deleteFlashcard(int idFlash, int userId) async {
    await connect();
    if (isLocalFallback) {
      _mockFlashcards.removeWhere((f) => f["id_flash"] == idFlash && f["id_usuario"] == userId);
      return true;
    } else {
      try {
        final response = await http.delete(
          Uri.parse('$baseUrl/flashcards/$idFlash'),
          headers: _headers(),
        ).timeout(const Duration(seconds: 4));

        return response.statusCode == 200;
      } catch (e) {
        print("deleteFlashcard API error: $e");
        return false;
      }
    }
  }

  // --- METODOS DE ESTUDO (STUDY METHODS) ---

  Future<List<String>> getMetodoEstudo(String intelligenceName) async {
    await connect();
    if (isLocalFallback) {
      try {
        final match = _mockInteligencias.firstWhere(
          (i) => i["nome"].toString().toLowerCase() == intelligenceName.toLowerCase(),
        );
        final decoded = jsonDecode(match["metodo"]) as List<dynamic>;
        return decoded.map((e) => e.toString()).toList();
      } catch (_) {
        return [
          "Faça autoavaliações ao final de cada dia.",
          "Defina metas de estudos estritas e diários reflexivos.",
          "Estude em ambientes silenciosos onde consiga escutar seus próprios pensamentos."
        ];
      }
    } else {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/inteligencias'),
          headers: _headers(),
        ).timeout(const Duration(seconds: 4));

        if (response.statusCode == 200) {
          final List<dynamic> list = jsonDecode(response.body);
          
          var match = list.firstWhere(
            (item) => item["nome"].toString().toLowerCase() == intelligenceName.toLowerCase(),
            orElse: () => null,
          );
          
          if (match == null) {
            String altName = intelligenceName;
            if (intelligenceName.toLowerCase() == "corporal") {
              altName = "Cinestésica";
            } else if (intelligenceName.toLowerCase() == "cinestésica") {
              altName = "Corporal";
            }
            match = list.firstWhere(
              (item) => item["nome"].toString().toLowerCase() == altName.toLowerCase(),
              orElse: () => null,
            );
          }
          
          if (match != null) {
            final raw = match["metodo"];
            final List<dynamic> decoded = (raw is String) ? jsonDecode(raw) : raw;
            return decoded.map((e) => e.toString()).toList();
          }
        }
        
        return [
          "Faça autoavaliações ao final de cada dia.",
          "Defina metas de estudos estritas e diários reflexivos.",
          "Estude em ambientes silenciosos onde consiga escutar seus próprios pensamentos."
        ];
      } catch (e) {
        print("getMetodoEstudo API error: $e");
        isLocalFallback = true;
        return getMetodoEstudo(intelligenceName);
      }
    }
  }
}
