import 'dart:convert';

class Nota {
  final int id;
  final String rawConteudo;
  final int idUsuario;
  final String corNota;

  // Parsed properties
  final String title;
  final String description;
  final bool favorite;
  final List<ChecklistItem> checklist;
  final bool bold;
  final bool italic;

  Nota({
    required this.id,
    required this.rawConteudo,
    required this.idUsuario,
    required this.corNota,
    required this.title,
    required this.description,
    required this.favorite,
    required this.checklist,
    required this.bold,
    required this.italic,
  });

  factory Nota.fromMap(Map<String, dynamic> map) {
    String raw = map['conteudo'] ?? '';
    int id = map['id_anotacao'] ?? 0;
    int idUsuario = map['id_usuario'] ?? 0;
    String cor = map['cor_nota'] ?? '0xfff4f1eb';

    // Parse JSON
    String parsedTitle = 'Sem Título';
    String parsedDesc = raw;
    bool parsedFav = false;
    List<ChecklistItem> parsedChecklist = [];
    bool parsedBold = false;
    bool parsedItalic = false;

    try {
      if (raw.trim().startsWith('{') && raw.trim().endsWith('}')) {
        Map<String, dynamic> json = jsonDecode(raw);
        parsedTitle = json['title'] ?? 'Sem Título';
        parsedDesc = json['description'] ?? '';
        parsedFav = json['favorite'] ?? false;
        parsedBold = json['bold'] ?? false;
        parsedItalic = json['italic'] ?? false;
        if (json['checklist'] != null) {
          parsedChecklist = (json['checklist'] as List)
              .map((item) => ChecklistItem.fromMap(item))
              .toList();
        }
      }
    } catch (e) {
      // Not a json structure, use raw
      parsedTitle = 'Anotação';
      parsedDesc = raw;
    }

    return Nota(
      id: id,
      rawConteudo: raw,
      idUsuario: idUsuario,
      corNota: cor,
      title: parsedTitle,
      description: parsedDesc,
      favorite: parsedFav,
      checklist: parsedChecklist,
      bold: parsedBold,
      italic: parsedItalic,
    );
  }

  static String buildConteudoJson({
    required String title,
    required String description,
    required bool favorite,
    required List<ChecklistItem> checklist,
    required bool bold,
    required bool italic,
  }) {
    return jsonEncode({
      'title': title,
      'description': description,
      'favorite': favorite,
      'checklist': checklist.map((item) => item.toMap()).toList(),
      'bold': bold,
      'italic': italic,
    });
  }
}

class ChecklistItem {
  String text;
  bool done;

  ChecklistItem({required this.text, required this.done});

  factory ChecklistItem.fromMap(Map<String, dynamic> map) {
    return ChecklistItem(
      text: map['text'] ?? '',
      done: map['done'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'done': done,
    };
  }
}
