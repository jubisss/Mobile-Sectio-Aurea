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
    print("Connecting...");
    final conn = await MySqlConnection.connect(settings);
    print("Connected!");

    await conn.query("SET lock_wait_timeout = 2");
    await conn.query("SET FOREIGN_KEY_CHECKS = 0");
    print("Configured locks and foreign key settings.");

    final tables = [
      'PI_Usuario',
      'PI_Materia',
      'PI_Tarefas',
      'PI_Bloco',
      'PI_Cronograma',
      'PI_Cronometro',
      'PI_Eventos',
      'PI_Flash',
      'PI_Inteligencias'
    ];

    print("\nDropping tables...");
    for (var table in tables) {
      try {
        final dropConn = await MySqlConnection.connect(settings);
        await dropConn.query("SET lock_wait_timeout = 2");
        await dropConn.query("DROP TABLE IF EXISTS $table");
        print("  Table $table dropped.");
        await dropConn.close();
      } catch (e) {
        print("  Error dropping $table: $e");
      }
    }

    print("\nCreating tables...");
    
    // 1. PI_Usuario
    try {
      final cConn = await MySqlConnection.connect(settings);
      await cConn.query("""
        CREATE TABLE IF NOT EXISTS PI_Usuario (
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
      await cConn.close();
    } catch (e) {
      print("  Error creating PI_Usuario: $e");
    }

    // 2. PI_Materia
    try {
      final cConn = await MySqlConnection.connect(settings);
      await cConn.query("""
        CREATE TABLE IF NOT EXISTS PI_Materia (
          id_materia INT AUTO_INCREMENT PRIMARY KEY,
          nome VARCHAR(100) NOT NULL,
          cor VARCHAR(100) NOT NULL,
          id_usuario INT NOT NULL,
          ativo INT DEFAULT 1
        )
      """);
      print("  Created table PI_Materia");
      await cConn.close();
    } catch (e) {
      print("  Error creating PI_Materia: $e");
    }

    // 3. PI_Tarefas
    try {
      final cConn = await MySqlConnection.connect(settings);
      await cConn.query("""
        CREATE TABLE IF NOT EXISTS PI_Tarefas (
          id_tarefa INT AUTO_INCREMENT PRIMARY KEY,
          nome_tarefa VARCHAR(500) NOT NULL,
          dificuldade VARCHAR(50) NOT NULL,
          prazo VARCHAR(50) NOT NULL,
          id_usuario INT NOT NULL,
          ativo INT DEFAULT 1
        )
      """);
      print("  Created table PI_Tarefas");
      await cConn.close();
    } catch (e) {
      print("  Error creating PI_Tarefas: $e");
    }

    // 4. PI_Bloco (Notes)
    try {
      final cConn = await MySqlConnection.connect(settings);
      await cConn.query("""
        CREATE TABLE IF NOT EXISTS PI_Bloco (
          id_anotacao INT AUTO_INCREMENT PRIMARY KEY,
          conteudo TEXT NOT NULL,
          cor_nota VARCHAR(50) DEFAULT '0xfff4f1eb',
          favorito VARCHAR(10) DEFAULT 'false',
          id_usuario INT NOT NULL
        )
      """);
      print("  Created table PI_Bloco");
      await cConn.close();
    } catch (e) {
      print("  Error creating PI_Bloco: $e");
    }

    // 5. PI_Cronograma (Schedule)
    try {
      final cConn = await MySqlConnection.connect(settings);
      await cConn.query("""
        CREATE TABLE IF NOT EXISTS PI_Cronograma (
          id_cronograma INT AUTO_INCREMENT PRIMARY KEY,
          id_materia INT NOT NULL,
          dia_semana VARCHAR(50) NOT NULL,
          hora_inicio VARCHAR(50) NOT NULL,
          hora_final VARCHAR(50) NOT NULL,
          id_usuario INT NOT NULL
        )
      """);
      print("  Created table PI_Cronograma");
      await cConn.close();
    } catch (e) {
      print("  Error creating PI_Cronograma: $e");
    }

    // 6. PI_Eventos (Calendar)
    try {
      final cConn = await MySqlConnection.connect(settings);
      await cConn.query("""
        CREATE TABLE IF NOT EXISTS PI_Eventos (
          id_evento INT AUTO_INCREMENT PRIMARY KEY,
          tipo VARCHAR(500) NOT NULL,
          data VARCHAR(50) NOT NULL,
          cor VARCHAR(50) NOT NULL,
          id_usuario INT NOT NULL
        )
      """);
      print("  Created table PI_Eventos");
      await cConn.close();
    } catch (e) {
      print("  Error creating PI_Eventos: $e");
    }

    // 7. PI_Flash (Flashcards)
    try {
      final cConn = await MySqlConnection.connect(settings);
      await cConn.query("""
        CREATE TABLE IF NOT EXISTS PI_Flash (
          id_flash INT AUTO_INCREMENT PRIMARY KEY,
          id_materia INT NOT NULL,
          id_usuario INT NOT NULL,
          pergunta TEXT NOT NULL,
          tema VARCHAR(200) NOT NULL,
          resposta TEXT NOT NULL
        )
      """);
      print("  Created table PI_Flash");
      await cConn.close();
    } catch (e) {
      print("  Error creating PI_Flash: $e");
    }

    // 8. PI_Inteligencias (Study Methods)
    try {
      final cConn = await MySqlConnection.connect(settings);
      await cConn.query("""
        CREATE TABLE IF NOT EXISTS PI_Inteligencias (
          id_tipo INT AUTO_INCREMENT PRIMARY KEY,
          nome VARCHAR(100) NOT NULL,
          metodo TEXT NOT NULL,
          cor VARCHAR(50) NOT NULL
        )
      """);
      print("  Created table PI_Inteligencias");
      await cConn.close();
    } catch (e) {
      print("  Error creating PI_Inteligencias: $e");
    }

    // 9. PI_Cronometro (Timer Entries)
    try {
      final cConn = await MySqlConnection.connect(settings);
      await cConn.query("""
        CREATE TABLE IF NOT EXISTS PI_Cronometro (
          id_cron INT AUTO_INCREMENT PRIMARY KEY,
          tempo_cronometro INT NOT NULL,
          descricao VARCHAR(500) DEFAULT '',
          id_usuario INT NOT NULL
        )
      """);
      print("  Created table PI_Cronometro");
      await cConn.close();
    } catch (e) {
      print("  Error creating PI_Cronometro: $e");
    }

    print("\nSeeding PI_Inteligencias (study methods)...");
    final data = [
      {
        "nome": "Lógico-matemática",
        "metodo": jsonEncode([
          "Organize os estudos em passos cronometrados e lógicos.",
          "Use raciocínio de causa e efeito para fixar ideias.",
          "Resolva problemas e crie pequenos testes práticos com frequência."
        ]),
        "cor": "#ffbd59"
      },
      {
        "nome": "Linguística",
        "metodo": jsonEncode([
          "Escreva resumos explicativos em suas próprias palavras.",
          "Leia em voz alta ou grave áudios ensinando a matéria.",
          "Utilize flashcards textuais e debates sobre temas estudados."
        ]),
        "cor": "#9f042c"
      },
      {
        "nome": "Corporal",
        "metodo": jsonEncode([
          "Faça pausas ativas (ex: alongamentos, polichinelos).",
          "Use gestos ou caminhe enquanto repassa informações na mente.",
          "Utilize cartões de memorização físicos ou desenhe mapas no chão."
        ]),
        "cor": "#00bf63"
      },
      {
        "nome": "Cinestésica",
        "metodo": jsonEncode([
          "Faça pausas ativas (ex: alongamentos, polichinelos).",
          "Use gestos ou caminhe enquanto repassa informações na mente.",
          "Utilize cartões de memorização físicos ou desenhe mapas no chão."
        ]),
        "cor": "#00bf63"
      },
      {
        "nome": "Espacial",
        "metodo": jsonEncode([
          "Construa mapas mentais coloridos, infográficos e esquemas.",
          "Use marcadores de texto em código de cores específicas.",
          "Associe conceitos complexos com símbolos visuais ou desenhos."
        ]),
        "cor": "#d203a4"
      },
      {
        "nome": "Interpessoal",
        "metodo": jsonEncode([
          "Estude em dupla ou monte grupos de discussão online.",
          "Explique a matéria para um colega ou familiar (estudo ativo).",
          "Participe de fóruns e responda dúvidas de outras pessoas."
        ]),
        "cor": "#ff5f00"
      },
      {
        "nome": "Musical",
        "metodo": jsonEncode([
          "Estude ouvindo sons instrumentais neutros ou ruído marrom.",
          "Crie rimas, paródias ou associações sonoras para memorização.",
          "Estude com batidas rítmicas de fundo para aumentar o foco."
        ]),
        "cor": "#8a03d2"
      },
      {
        "nome": "Intrapessoal",
        "metodo": jsonEncode([
          "Faça autoavaliações ao final de cada dia.",
          "Defina metas de estudos estritas e diários reflexivos.",
          "Estude em ambientes silenciosos onde consiga escutar seus próprios pensamentos."
        ]),
        "cor": "#5170ff"
      }
    ];

    // Delete any existing seeded entries before inserting
    await conn.query("DELETE FROM PI_Inteligencias");
    for (var item in data) {
      final name = item["nome"]!.replaceAll("'", "''");
      final methods = item["metodo"]!.replaceAll("'", "''");
      final color = item["cor"]!.replaceAll("'", "''");
      await conn.query("INSERT INTO PI_Inteligencias (nome, metodo, cor) VALUES ('$name', '$methods', '$color')");
    }
    print("Seeding completed successfully!");

    await conn.query("SET FOREIGN_KEY_CHECKS = 1");
    await conn.close();
    print("\nDatabase setup completed successfully!");
  } catch (e) {
    print("Fatal Error: $e");
  }
}
