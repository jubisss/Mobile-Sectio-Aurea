import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sectio_aurea/models/nota.dart';
import 'package:sectio_aurea/services/database_service.dart';

class CornellNoteScreen extends StatefulWidget {
  final Map<String, dynamic> u;
  final Nota? editNote;

  const CornellNoteScreen({super.key, required this.u, this.editNote});

  @override
  State<CornellNoteScreen> createState() => _CornellNoteScreenState();
}

class _CornellNoteScreenState extends State<CornellNoteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _cuesController = TextEditingController(); // Coluna Esquerda: Tópicos / Perguntas
  final TextEditingController _notesController = TextEditingController(); // Coluna Direita: Notas / Detalhes
  final TextEditingController _summaryController = TextEditingController(); // Rodapé: Resumo

  bool _isFavorite = false;
  String _selectedColor = "0xffffffff";

  final List<Map<String, String>> _colorPalette = [
    {"name": "Branco", "hex": "0xffffffff"},
    {"name": "Creme", "hex": "0xfff4f1eb"},
    {"name": "Vermelho", "hex": "0xffffe6e6"},
    {"name": "Azul", "hex": "0xffe6f2ff"},
    {"name": "Verde", "hex": "0xffe6ffe6"},
    {"name": "Amarelo", "hex": "0xfffff9e6"},
    {"name": "Roxo", "hex": "0xfff9e6ff"},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.editNote != null) {
      final n = widget.editNote!;
      _selectedColor = n.corNota;
      _isFavorite = n.favorite;
      _titleController.text = n.title;

      if (n.isCornell) {
        _cuesController.text = n.cornellCues;
        _notesController.text = n.cornellNotes;
        _summaryController.text = n.cornellSummary;
      } else {
        try {
          final Map<String, dynamic> parsed = jsonDecode(n.description);
          _cuesController.text = parsed["cues"] ?? "";
          _notesController.text = parsed["notes"] ?? "";
          _summaryController.text = parsed["summary"] ?? "";
        } catch (_) {
          _notesController.text = n.description;
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _cuesController.dispose();
    _notesController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  void _saveCornellNote() async {
    String title = _titleController.text.trim();
    String cues = _cuesController.text.trim();
    String notes = _notesController.text.trim();
    String summary = _summaryController.text.trim();

    if (title.isEmpty) {
      title = "Método Cornell";
    }

    // Clean, flat JSON structure for Cornell note!
    String contentJson = jsonEncode({
      "title": title,
      "type": "cornell",
      "cues": cues,
      "notes": notes,
      "summary": summary,
      "description": notes,
      "favorite": _isFavorite,
      "checklist": [],
      "bold": false,
      "italic": false,
    });

    final db = DatabaseService();
    int userId = widget.u["id_usuario"] ?? 1;

    bool success = false;
    if (widget.editNote != null) {
      success = await db.updateNote(widget.editNote!.id, contentJson, _selectedColor, userId);
    } else {
      int noteId = await db.createNote(contentJson, _selectedColor, userId);
      success = noteId > 0;
    }

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Anotação Cornell salva com sucesso!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao salvar anotação Cornell."), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.editNote == null && _selectedColor == "0xffffffff" && isDark) {
      _selectedColor = "0xff1e1e1e";
    }

    final List<Map<String, String>> currentPalette = isDark
        ? [
            {"name": "Padrão", "hex": "0xff1e1e1e"},
            {"name": "Creme Escuro", "hex": "0xff2c2923"},
            {"name": "Vermelho Escuro", "hex": "0xff4a151b"},
            {"name": "Azul Escuro", "hex": "0xff152d4a"},
            {"name": "Verde Escuro", "hex": "0xff154a24"},
            {"name": "Amarelo Escuro", "hex": "0xff4a4115"},
            {"name": "Roxo Escuro", "hex": "0xff3c154a"},
          ]
        : _colorPalette;

    Color accentColor = Colors.blueGrey;
    String? colorHex = widget.u["clas_inteli"];
    if (colorHex != null && colorHex.isNotEmpty) {
      try {
        accentColor = Color(int.parse(colorHex));
      } catch (_) {}
    }

    Color pageBgColor = Color(int.parse(_selectedColor));
    final bool isLight = pageBgColor.computeLuminance() > 0.5;
    final Color contentTextColor = isLight ? Colors.black87 : Colors.white;
    final Color hintColor = isLight ? Colors.black38 : Colors.white38;
    final Color dividerColor = isLight ? Colors.black26 : Colors.white24;

    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: AppBar(
        backgroundColor: pageBgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: contentTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.editNote != null ? "Editar Cornell" : "Método Cornell",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: contentTextColor,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.star : Icons.star_border,
              color: _isFavorite ? Colors.amber : contentTextColor,
            ),
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.check, color: contentTextColor, size: 28),
            onPressed: _saveCornellNote,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Title Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                controller: _titleController,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: contentTextColor,
                ),
                decoration: InputDecoration(
                  hintText: "Título da Anotação...",
                  hintStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: hintColor,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            Divider(color: dividerColor, height: 1),

            // Color Palette Selector
            Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: currentPalette.length,
                itemBuilder: (context, idx) {
                  final c = currentPalette[idx];
                  final String hex = c["hex"]!;
                  final bool isSelected = _selectedColor == hex;
                  final Color circleColor = Color(int.parse(hex));

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = hex;
                      });
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: circleColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? accentColor : (isLight ? Colors.black26 : Colors.white24),
                          width: isSelected ? 2.5 : 1,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Divider(color: dividerColor, height: 1),

            // Middle Section: 2 Side-by-Side Columns (Perguntas vs Anotações)
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Coluna Esquerda: Tópicos / Perguntas (35%)
                  Expanded(
                    flex: 35,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border(right: BorderSide(color: dividerColor, width: 1.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.help_outline, size: 16, color: accentColor),
                              const SizedBox(width: 4),
                              Text(
                                "Perguntas",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: accentColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: TextField(
                              controller: _cuesController,
                              maxLines: null,
                              expands: true,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                color: contentTextColor,
                              ),
                              decoration: InputDecoration(
                                hintText: "Perguntas e palavras-chave...",
                                hintStyle: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: hintColor),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Coluna Direita: Anotações / Detalhes (65%)
                  Expanded(
                    flex: 65,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.notes, size: 16, color: accentColor),
                              const SizedBox(width: 4),
                              Text(
                                "Anotações",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: accentColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: TextField(
                              controller: _notesController,
                              maxLines: null,
                              expands: true,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                color: contentTextColor,
                              ),
                              decoration: InputDecoration(
                                hintText: "Escreva suas anotações detalhadas aqui...",
                                hintStyle: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: hintColor),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(color: dividerColor, height: 1),

            // Bottom Section: Resumo (Summary)
            Container(
              height: 130,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, size: 16, color: accentColor),
                      const SizedBox(width: 4),
                      Text(
                        "Resumo",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: TextField(
                      controller: _summaryController,
                      maxLines: null,
                      expands: true,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: contentTextColor,
                      ),
                      decoration: InputDecoration(
                        hintText: "Sintetize as ideias principais com suas palavras...",
                        hintStyle: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: hintColor),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
