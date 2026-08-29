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

    final content = await conn.query("SELECT id_tipo FROM PI_Inteligencias LIMIT 1");
    bool isEmpty = content.isEmpty;
    print("Is PI_Inteligencias empty? $isEmpty");

    if (isEmpty) {
      print("Seeding PI_Inteligencias...");
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
          "nome": "Espacial",
          "metodo": jsonEncode([
            "Construa mapas mentais coloridos, infográficos e esquemas.",
            "Use marcadores de texto in código de cores específicas.",
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

      final values = <String>[];
      for (var item in data) {
        final name = item["nome"]!.replaceAll("'", "''");
        final metodo = item["metodo"]!.replaceAll("'", "''");
        final cor = item["cor"]!.replaceAll("'", "''");
        values.add("('$name', '$metodo', '$cor')");
      }
      final queryStr = "INSERT INTO PI_Inteligencias (nome, metodo, cor) VALUES ${values.join(', ')}";
      await conn.query(queryStr);
      print("Seeding completed successfully!");
    } else {
      print("Table PI_Inteligencias already seeded.");
    }

    await conn.close();
  } catch (e) {
    print("Error seeding: $e");
  }
}
