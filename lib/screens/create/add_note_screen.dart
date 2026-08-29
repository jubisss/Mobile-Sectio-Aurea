import 'package:flutter/material.dart';
import 'package:sectio_aurea/models/nota.dart';
import 'package:sectio_aurea/services/database_service.dart';
import 'package:sectio_aurea/widgets/botao.dart';
import 'package:sectio_aurea/widgets/campo_texto.dart';

class AddNoteScreen extends StatefulWidget {
  final Map<String, dynamic> u;
  final Nota? editNote;

  const AddNoteScreen({super.key, required this.u, this.editNote});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _checkItemController = TextEditingController();

  bool _isBold = false;
  bool _isItalic = false;
  bool _isFavorite = false;
  String _selectedColor = "0xffffffff"; // default White
  List<ChecklistItem> _checklist = [];

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
      _titleController.text = n.title;
      _descController.text = n.description;
      _isBold = n.bold;
      _isItalic = n.italic;
      _isFavorite = n.favorite;
      _selectedColor = n.corNota;
      _checklist = List<ChecklistItem>.from(n.checklist);
    }
  }

  void _addChecklistItem() {
    String text = _checkItemController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _checklist.add(ChecklistItem(text: text, done: false));
        _checkItemController.clear();
      });
    }
  }

  void _removeChecklistItem(int idx) {
    setState(() {
      _checklist.removeAt(idx);
    });
  }

  void _saveNote() async {
    String title = _titleController.text.trim();
    String desc = _descController.text.trim();

    if (title.isEmpty) {
      title = "Sem Título";
    }

    String contentJson = Nota.buildConteudoJson(
      title: title,
      description: desc,
      favorite: _isFavorite,
      checklist: _checklist,
      bold: _isBold,
      italic: _isItalic,
    );

    final db = DatabaseService();
    int userId = widget.u["id_usuario"] ?? 1;

    bool success = false;
    if (widget.editNote != null) {
      // Edit mode
      success = await db.updateNote(widget.editNote!.id, contentJson, _selectedColor, userId);
    } else {
      // Create mode
      int noteId = await db.createNote(contentJson, _selectedColor, userId);
      success = noteId > 0;
    }

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Nota salva com sucesso!")),
        );
        Navigator.pop(context);
      }
    } else {
      _showAlert("Erro de Conexão", "Não foi possível salvar a nota no banco de dados.");
    }
  }

  void _showAlert(String title, String msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        content: Text(msg, style: const TextStyle(fontFamily: 'Poppins')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Default white color to dark background in dark mode for new notes
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
    final Color iconColor = isLight ? Colors.black54 : Colors.white70;
    final Color dividerColor = isLight ? Colors.black12 : Colors.white12;

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
          widget.editNote != null ? "Editar Nota" : "Nova Nota",
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
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: "Título da Nota",
                hintStyle: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: hintColor,
                ),
                border: InputBorder.none,
              ),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: contentTextColor,
                decoration: _isBold ? TextDecoration.underline : null,
                fontStyle: _isItalic ? FontStyle.italic : null,
              ),
            ),
            Divider(color: dividerColor),

            // Format Actions Bar
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.format_bold,
                    color: _isBold ? accentColor : iconColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _isBold = !_isBold;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.format_italic,
                    color: _isItalic ? accentColor : iconColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _isItalic = !_isItalic;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Description body
            TextField(
              controller: _descController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintText: "Escreva algo aqui...",
                hintStyle: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: hintColor,
                ),
                border: InputBorder.none,
              ),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: contentTextColor,
                fontStyle: _isItalic ? FontStyle.italic : null,
              ),
            ),
            const SizedBox(height: 24),

            // Checklist Area
            Text(
              "Lista de Verificação (Checklist)",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: contentTextColor,
              ),
            ),
            const SizedBox(height: 10),
            // Checklist Items
            if (_checklist.isNotEmpty)
              Column(
                children: List.generate(_checklist.length, (index) {
                  final item = _checklist[index];
                  return Row(
                    children: [
                      Checkbox(
                        activeColor: accentColor,
                        checkColor: isLight ? Colors.white : Colors.black,
                        value: item.done,
                        onChanged: (val) {
                          setState(() {
                            item.done = val ?? false;
                          });
                        },
                      ),
                      Expanded(
                        child: Text(
                          item.text,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: item.done ? hintColor : contentTextColor,
                            decoration: item.done ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, size: 16, color: hintColor),
                        onPressed: () => _removeChecklistItem(index),
                      ),
                    ],
                  );
                }),
              ),
            // Add checklist item field
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _checkItemController,
                    decoration: InputDecoration(
                      hintText: "Adicionar item...",
                      hintStyle: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: hintColor),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: contentTextColor),
                    onSubmitted: (_) => _addChecklistItem(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add, color: accentColor),
                  onPressed: _addChecklistItem,
                ),
              ],
            ),
            Divider(color: dividerColor),
            const SizedBox(height: 20),

            // Color selection list
            Text(
              "Cor do Cartão",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: contentTextColor,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: currentPalette.length,
                itemBuilder: (context, index) {
                  final palette = currentPalette[index];
                  final hex = palette["hex"]!;
                  bool isSel = _selectedColor == hex;
                  Color pillColor = Color(int.parse(hex));

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = hex;
                      });
                    },
                    child: Container(
                      width: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: pillColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSel ? (isLight ? Colors.black87 : Colors.white) : dividerColor,
                          width: isSel ? 2.5 : 1.2,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 48),
            Center(
              child: Botao(
                texto: "Salvar Nota",
                funcao: _saveNote,
                cor: accentColor,
                corTexto: isLight ? (isDark ? Colors.black : Colors.white) : Colors.black,
                width: 200,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
