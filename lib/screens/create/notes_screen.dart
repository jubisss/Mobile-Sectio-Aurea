import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sectio_aurea/models/nota.dart';
import 'package:sectio_aurea/services/database_service.dart';

class NotesScreen extends StatefulWidget {
  final Map<String, dynamic> u;

  const NotesScreen({super.key, required this.u});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Nota> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() {
      _isLoading = true;
    });

    int userId = widget.u["id_usuario"] ?? 1;
    final db = DatabaseService();
    List<Map<String, dynamic>> rawNotes = await db.getNotes(userId);

    // Map to models
    List<Nota> loaded = rawNotes.map((m) => Nota.fromMap(m)).toList();

    // Sort: favorites first, then newest (largest ID) first
    loaded.sort((a, b) {
      if (a.favorite && !b.favorite) return -1;
      if (!a.favorite && b.favorite) return 1;
      return b.id.compareTo(a.id);
    });

    if (mounted) {
      setState(() {
        _notes = loaded;
        _isLoading = false;
      });
    }
  }

  void _toggleFavorite(Nota note) async {
    // Re-serialize with toggled favorite state
    String updatedJson = Nota.buildConteudoJson(
      title: note.title,
      description: note.description,
      favorite: !note.favorite,
      checklist: note.checklist,
      bold: note.bold,
      italic: note.italic,
    );

    final db = DatabaseService();
    int userId = widget.u["id_usuario"] ?? 1;
    await db.updateNote(note.id, updatedJson, note.corNota, userId);
    _loadNotes();
  }

  void _deleteNote(int id) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Excluir Nota?", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
          content: const Text("Deseja apagar esta anotação permanentemente?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Cancelar", style: TextStyle(color: isDark ? Colors.white60 : Colors.black54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Excluir", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final db = DatabaseService();
      int userId = widget.u["id_usuario"] ?? 1;
      await db.deleteNote(id, userId);
      _loadNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    Color accentColor = Colors.blueGrey;
    String? colorHex = widget.u["clas_inteli"];
    if (colorHex != null && colorHex.isNotEmpty) {
      try {
        accentColor = Color(int.parse(colorHex));
      } catch (_) {}
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xff121212) : const Color(0xfff4f1eb),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xff121212) : const Color(0xfff4f1eb),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white70 : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Notas",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: isDark ? Colors.tealAccent : Colors.black))
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: _notes.isEmpty
                  ? Center(
                      child: Text(
                        "Sem anotações criadas.\nToque no + para escrever sua primeira nota!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: isDark ? Colors.white30 : Colors.black38,
                        ),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.only(top: 10, bottom: 80),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: _notes.length,
                      itemBuilder: (context, index) {
                        final n = _notes[index];
                        Color cardBg = Color(int.parse(n.corNota.isNotEmpty ? n.corNota : (isDark ? "0xff1e1e1e" : "0xffffffff")));
                        final bool isCardLight = cardBg.computeLuminance() > 0.5;
                        final Color cardTextColor = isCardLight ? Colors.black87 : Colors.white;
                        final Color cardSubtextColor = isCardLight ? Colors.black54 : Colors.white70;

                        // Checklist status
                        int doneCount = n.checklist.where((c) => c.done).length;
                        int totalCheck = n.checklist.length;

                        return Card(
                          color: cardBg,
                          elevation: 1.5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: n.favorite ? accentColor.withOpacity(0.5) : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: InkWell(
                            onTap: () {
                              final Map<String, dynamic> params = {
                                "user": widget.u,
                                "note": n,
                              };
                              context.push('/create/notes/add', extra: params).then((_) => _loadNotes());
                            },
                            onLongPress: () => _deleteNote(n.id),
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title and Favorite Icon
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          n.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: cardTextColor,
                                            decoration: n.bold ? TextDecoration.none : null,
                                            fontStyle: n.italic ? FontStyle.italic : null,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => _toggleFavorite(n),
                                        child: Icon(
                                          n.favorite ? Icons.star : Icons.star_border,
                                          color: n.favorite ? Colors.amber : (isCardLight ? Colors.black38 : Colors.white38),
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Description Snippet
                                  Expanded(
                                    child: Text(
                                      n.description,
                                      maxLines: totalCheck > 0 ? 2 : 5,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: cardSubtextColor,
                                        fontStyle: n.italic ? FontStyle.italic : null,
                                      ),
                                    ),
                                  ),
                                  // Checklist status footer
                                  if (totalCheck > 0) ...[
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isCardLight ? Colors.black.withOpacity(0.04) : Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.check_box_outlined, size: 12, color: isCardLight ? accentColor : Colors.tealAccent),
                                          const SizedBox(width: 4),
                                          Text(
                                            "$doneCount/$totalCheck",
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: cardTextColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: accentColor,
        elevation: 6,
        onPressed: () {
          final Map<String, dynamic> params = {
            "user": widget.u,
            "note": null,
          };
          context.push('/create/notes/add', extra: params).then((_) => _loadNotes());
        },
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
