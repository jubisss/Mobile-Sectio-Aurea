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

  // Cornell specific parsed properties
  final bool isCornell;
  final String cornellCues;
  final String cornellNotes;
  final String cornellSummary;

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
    this.isCornell = false,
    this.cornellCues = '',
    this.cornellNotes = '',
    this.cornellSummary = '',
  });

  String get displayDescription {
    if (isCornell) {
      List<String> parts = [];
      if (cornellCues.isNotEmpty) parts.add("Perguntas: $cornellCues");
      if (cornellNotes.isNotEmpty) parts.add("Anotações: $cornellNotes");
      if (cornellSummary.isNotEmpty) parts.add("Resumo: $cornellSummary");
      return parts.join("\n");
    }
    return description;
  }

  factory Nota.fromMap(Map<String, dynamic> map) {
    String raw = map['conteudo'] ?? '';
    int id = map['id_anotacao'] ?? 0;
    int idUsuario = map['id_usuario'] ?? 0;
    String cor = map['cor_nota'] ?? '0xfff4f1eb';

    // Unescape HTML entities like &quot; from API/database
    raw = raw
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');

    String parsedTitle = 'Sem Título';
    String parsedDesc = raw;
    bool parsedFav = false;
    List<ChecklistItem> parsedChecklist = [];
    bool parsedBold = false;
    bool parsedItalic = false;

    bool parsedIsCornell = false;
    String parsedCues = '';
    String parsedNotes = '';
    String parsedSummary = '';

    try {
      if (raw.trim().startsWith('{') && raw.trim().endsWith('}')) {
        Map<String, dynamic> json = jsonDecode(raw);
        parsedTitle = json['title'] ?? 'Sem Título';
        parsedFav = json['favorite'] ?? false;
        parsedBold = json['bold'] ?? false;
        parsedItalic = json['italic'] ?? false;

        if (json['checklist'] != null) {
          parsedChecklist = (json['checklist'] as List)
              .map((item) => ChecklistItem.fromMap(item))
              .toList();
        }

        // Check if top-level json is Cornell
        if (json['type'] == 'cornell' || json['cues'] != null || json['summary'] != null) {
          parsedIsCornell = true;
          parsedCues = json['cues'] ?? '';
          parsedNotes = json['notes'] ?? '';
          parsedSummary = json['summary'] ?? '';
          parsedDesc = parsedNotes.isNotEmpty ? parsedNotes : (json['description'] ?? '');
        } else {
          dynamic descVal = json['description'] ?? '';
          if (descVal is String) {
            String cleanDesc = descVal
                .replaceAll('&quot;', '"')
                .replaceAll('&amp;', '&')
                .replaceAll('&lt;', '<')
                .replaceAll('&gt;', '>');

            if (cleanDesc.trim().startsWith('{') && cleanDesc.trim().endsWith('}')) {
              try {
                Map<String, dynamic> inner = jsonDecode(cleanDesc);
                if (inner['type'] == 'cornell' || inner['cues'] != null) {
                  parsedIsCornell = true;
                  parsedCues = inner['cues'] ?? '';
                  parsedNotes = inner['notes'] ?? '';
                  parsedSummary = inner['summary'] ?? '';
                  parsedDesc = parsedNotes;
                } else {
                  parsedDesc = cleanDesc;
                }
              } catch (_) {
                parsedDesc = cleanDesc;
              }
            } else {
              parsedDesc = cleanDesc;
            }
          } else {
            parsedDesc = descVal.toString();
          }
        }
      }

      // Fallback if JSON decode didn't set isCornell
      if (!parsedIsCornell && (raw.contains('cornell') || raw.contains('"cues"') || raw.contains('"summary"') || raw.contains('"notes"'))) {
        parsedIsCornell = true;
        RegExp cuesRegex = RegExp(r'"cues"\s*:\s*"([^"]*)"');
        RegExp notesRegex = RegExp(r'"notes"\s*:\s*"([^"]*)"');
        RegExp summaryRegex = RegExp(r'"summary"\s*:\s*"([^"]*)"');

        var matchC = cuesRegex.firstMatch(raw);
        var matchN = notesRegex.firstMatch(raw);
        var matchS = summaryRegex.firstMatch(raw);

        if (matchC != null) parsedCues = matchC.group(1) ?? '';
        if (matchN != null) parsedNotes = matchN.group(1) ?? '';
        if (matchS != null) parsedSummary = matchS.group(1) ?? '';
        if (parsedNotes.isNotEmpty) parsedDesc = parsedNotes;
      }
    } catch (e) {
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
      isCornell: parsedIsCornell,
      cornellCues: parsedCues,
      cornellNotes: parsedNotes,
      cornellSummary: parsedSummary,
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
