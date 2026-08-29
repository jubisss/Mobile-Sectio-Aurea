import 'dart:convert';
import 'package:mysql1/mysql1.dart';

void main() async {
  final settings = ConnectionSettings(
    host: '143.106.241.4',
    port: 3306,
    user: 'cl204214',
    db: 'cl204214',
    password: 'cl*19072008',
    timeout: const Duration(seconds: 15),
  );

  try {
    print("Connecting to database...");
    final conn = await MySqlConnection.connect(settings);
    print("Connected!");

    // Disable foreign key checks to avoid locks and allow dropping tables
    await conn.query("SET FOREIGN_KEY_CHECKS = 0");
    print("Disabled foreign key checks.");

    // List of tables to drop (in case they exist)
    final tablesToDrop = [
      'PI_Cronometro',
      'PI_Inteligencias',
      'PI_Flash',
      'PI_Eventos',
      'PI_Cronograma',
      'PI_Bloco',
      'PI_Tarefas',
      'PI_Materia',
      'PI_Usuario',
      'PI_Timer' // dropping old temp tables
    ];

    print("\nDropping existing tables...");
    for (var table in tablesToDrop) {
      try {
        await conn.query("DROP TABLE IF EXISTS $table");
        print("  Dropped table $table (if existed)");
      } catch (e) {
        print("  Error dropping $table: $e");
      }
    }

    print("\nCreating tables with correct schemas...");

    // 1. PI_Usuario
    await conn.query("""
      CREATE TABLE PI_Usuario (
        id_usuario INT AUTO_INCREMENT PRIMARY KEY,
        nome VARCHAR(100) NOT NULL,
        email VARCHAR(100) NOT NULL UNIQUE,
        senha VARCHAR(100) NOT NULL,
        ativo INT DEFAULT 1,
        foto VARCHAR(500) DEFAULT '',
        plano VARCHAR(50) DEFAULT 'Gratuito',
        tipo_dom VARCHAR(100) DEFAULT '',
        clas_inteli VARCHAR(100) DEFAULT ''
      )
    """);
    print("  Created table PI_Usuario");

    // 2. PI_Materia
    await conn.query("""
      CREATE TABLE PI_Materia (
        id_materia INT AUTO_INCREMENT PRIMARY KEY,
        nome VARCHAR(100) NOT NULL,
        cor VARCHAR(100) NOT NULL,
        id_usuario INT NOT NULL,
        ativo INT DEFAULT 1
      )
    """);
    print("  Created table PI_Materia");

    // 3. PI_Tarefas
    await conn.query("""
      CREATE TABLE PI_Tarefas (
        id_tarefa INT AUTO_INCREMENT PRIMARY KEY,
        nome_tarefa VARCHAR(500) NOT NULL,
        dificuldade VARCHAR(50) NOT NULL,
        prazo VARCHAR(50) NOT NULL,
        id_usuario INT NOT NULL,
        ativo INT DEFAULT 1
      )
    """);
    print("  Created table PI_Tarefas");

    // 4. PI_Bloco (Notes)
    await conn.query("""
      CREATE TABLE PI_Bloco (
        id_anotacao INT AUTO_INCREMENT PRIMARY KEY,
        conteudo TEXT NOT NULL,
        cor_nota VARCHAR(50) DEFAULT '0xfff4f1eb',
        favorito VARCHAR(10) DEFAULT 'false',
        id_usuario INT NOT NULL
      )
    """);
    print("  Created table PI_Bloco");

    // 5. PI_Cronograma (Schedule)
    await conn.query("""
      CREATE TABLE PI_Cronograma (
        id_cronograma INT AUTO_INCREMENT PRIMARY KEY,
        id_materia INT NOT NULL,
        dia_semana VARCHAR(50) NOT NULL,
        hora_inicio VARCHAR(50) NOT NULL,
        hora_final VARCHAR(50) NOT NULL,
        id_usuario INT NOT NULL
      )
    """);
    print("  Created table PI_Cronograma");

    // 6. PI_Eventos (Calendar)
    await conn.query("""
      CREATE TABLE PI_Eventos (
        id_evento INT AUTO_INCREMENT PRIMARY KEY,
        tipo VARCHAR(500) NOT NULL,
        data VARCHAR(50) NOT NULL,
        cor VARCHAR(50) NOT NULL,
        id_usuario INT NOT NULL
      )
    """);
    print("  Created table PI_Eventos");

    // 7. PI_Flash (Flashcards)
    await conn.query("""
      CREATE TABLE PI_Flash (
        id_flash INT AUTO_INCREMENT PRIMARY KEY,
        id_materia INT NOT NULL,
        id_usuario INT NOT NULL,
        pergunta TEXT NOT NULL,
        tema VARCHAR(200) NOT NULL,
        resposta TEXT NOT NULL
      )
    """);
    print("  Created table PI_Flash");

    // 8. PI_Inteligencias (Study Methods)
    await conn.query("""
      CREATE TABLE PI_Inteligencias (
        id_tipo INT AUTO_INCREMENT PRIMARY KEY,
        nome VARCHAR(100) NOT NULL,
        metodo TEXT NOT NULL,
        cor VARCHAR(50) NOT NULL
      )
    """);
    print("  Created table PI_Inteligencias");

    // 9. PI_Cronometro (Timer Entries)
    await conn.query("""
      CREATE TABLE PI_Cronometro (
        id_cron INT AUTO_INCREMENT PRIMARY KEY,
        tempo_cronometro INT NOT NULL,
        descricao VARCHAR(500) DEFAULT '',
        id_usuario INT NOT NULL
      )
    """);
    print("  Created table PI_Cronometro");

    print("\nSeeding PI_Inteligencias (study methods)...");
    final data = [
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
    ];

    for (var item in data) {
      final name = item["nome"]!.replaceAll("'", "''");
      final methods = item["metodo"]!.replaceAll("'", "''");
      final color = item["cor"]!.replaceAll("'", "''");
      await conn.query("INSERT INTO PI_Inteligencias (nome, metodo, cor) VALUES ('$name', '$methods', '$color')");
    }
    print("Seeding completed successfully!");

    await conn.query("SET FOREIGN_KEY_CHECKS = 1");
    print("Re-enabled foreign key checks.");
    await conn.close();
    print("\nDatabase recreation and setup completed successfully!");
  } catch (e) {
    print("Fatal Error: $e");
  }
}
