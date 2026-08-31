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
  String _filterType = "Todas"; // "Todas", "Normais", "Cornell"

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

    // Map to models & STRICTLY FILTER OUT Mind Maps, Flowcharts, Audio Recordings!
    List<Nota> loaded = [];
    for (var m in rawNotes) {
      String raw = (m['conteudo'] ?? '').toString();
      if (raw.contains('"type":"mapa_mental"') ||
          raw.contains('"type":"diagrama_fluxo"') ||
          raw.contains('"type":"rec"') ||
          raw.contains('GRAVAÇÃO:') ||
          raw.contains('MAPA MENTAL:') ||
          raw.contains('DIAGRAMA DE FLUXO:')) {
        continue;
      }
      loaded.add(Nota.fromMap(m));
    }

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

  void _showCornellViewerModal(Nota n, Color accentColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        final Color cardBg = isDark ? const Color(0xff1e1e1e) : Colors.white;
        final Color textColor = isDark ? Colors.white : Colors.black87;
        final Color subtextColor = isDark ? Colors.white70 : Colors.black54;

        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: cardBg, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
              child: ListView(
                controller: scrollController,
                children: [
                  // Top Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                        child: Text("🌽 Método Cornell", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 12, color: accentColor)),
                      ),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(n.title, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 20, color: textColor)),
                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 14),

                  // Side-by-side columns (Perguntas vs Anotações)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column: Perguntas (38%)
                      Expanded(
                        flex: 38,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.help_outline, size: 16, color: accentColor),
                                const SizedBox(width: 4),
                                Text("📌 Perguntas", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 13, color: accentColor)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              n.cornellCues.isEmpty ? "Nenhuma pergunta anotada." : n.cornellCues,
                              style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: textColor, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 180, color: isDark ? Colors.white24 : Colors.black12, margin: const EdgeInsets.symmetric(horizontal: 12)),
                      // Right Column: Anotações (62%)
                      Expanded(
                        flex: 62,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.notes, size: 16, color: accentColor),
                                const SizedBox(width: 4),
                                Text("📝 Anotações", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 13, color: accentColor)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              n.cornellNotes.isEmpty ? "Nenhuma anotação detalhada." : n.cornellNotes,
                              style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: textColor, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),
                  const Divider(height: 1),
                  const SizedBox(height: 14),

                  // Bottom Section: Resumo
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline, size: 16, color: accentColor),
                          const SizedBox(width: 4),
                          Text("💡 Resumo Sintetizado", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 13, color: accentColor)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xff2a2a2a) : const Color(0xfff5f5f5),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          n.cornellSummary.isEmpty ? "Nenhum resumo adicionado." : n.cornellSummary,
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: textColor, height: 1.4),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Edit button
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      final Map<String, dynamic> params = {
                        "user": widget.u,
                        "editNote": n,
                      };
                      context.push('/create/cornell', extra: params).then((_) => _loadNotes());
                    },
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text("Editar Esta Nota Cornell", style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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

    List<Nota> filteredNotes = _notes.where((n) {
      if (_filterType == "Cornell") return n.isCornell;
      if (_filterType == "Normais") return !n.isCornell;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: accentColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Minhas Anotações",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: accentColor))
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
              child: Column(
                children: [
                  // Filter bar
                  Row(
                    children: ["Todas", "Normais", "Cornell"].map((f) {
                      bool isSel = _filterType == f;
                      return GestureDetector(
                        onTap: () => setState(() => _filterType = f),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSel ? accentColor : (isDark ? Colors.white10 : Colors.black12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            f,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: isSel ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: filteredNotes.isEmpty
                        ? Center(
                            child: Text(
                              "Nenhuma anotação encontrada.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: isDark ? Colors.white30 : Colors.black38,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(top: 6, bottom: 80),
                            itemCount: filteredNotes.length,
                            itemBuilder: (context, index) {
                              final n = filteredNotes[index];
                              Color cardBg = Color(int.parse(n.corNota.isNotEmpty ? n.corNota : (isDark ? "0xff1e1e1e" : "0xffffffff")));
                              final bool isCardLight = cardBg.computeLuminance() > 0.5;
                              final Color cardTextColor = isCardLight ? Colors.black87 : Colors.white;
                              final Color cardSubtextColor = isCardLight ? Colors.black54 : Colors.white70;

                              int doneCount = n.checklist.where((c) => c.done).length;
                              int totalCheck = n.checklist.length;

                              // Dedicated Cornell Card Layout (Side-by-side columns)
                              if (n.isCornell) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: cardBg,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: n.favorite ? accentColor : (isDark ? Colors.white24 : Colors.black12),
                                      width: n.favorite ? 2 : 1,
                                    ),
                                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 3))],
                                  ),
                                  child: InkWell(
                                    onTap: () => _showCornellViewerModal(n, accentColor),
                                    borderRadius: BorderRadius.circular(18),
                                    child: Padding(
                                      padding: const EdgeInsets.all(14.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Title row + Badge
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                                                child: Text("🌽 Cornell", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 10, color: accentColor)),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  n.title,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 14, color: cardTextColor),
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
                                              const SizedBox(width: 6),
                                              GestureDetector(
                                                onTap: () => _deleteNote(n.id),
                                                child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          const Divider(height: 1),
                                          const SizedBox(height: 10),

                                          // Side-by-side columns (Perguntas vs Anotações)
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Left column: Perguntas (35%)
                                              Expanded(
                                                flex: 35,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text("📌 Perguntas", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 11, color: accentColor)),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      n.cornellCues.isEmpty ? "-" : n.cornellCues,
                                                      maxLines: 4,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: cardSubtextColor),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(width: 1, height: 70, color: isCardLight ? Colors.black12 : Colors.white12, margin: const EdgeInsets.symmetric(horizontal: 10)),
                                              // Right column: Anotações (65%)
                                              Expanded(
                                                flex: 65,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text("📝 Anotações", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 11, color: accentColor)),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      n.cornellNotes.isEmpty ? "-" : n.cornellNotes,
                                                      maxLines: 4,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: cardSubtextColor),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),

                                          if (n.cornellSummary.isNotEmpty) ...[
                                            const SizedBox(height: 10),
                                            Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: isCardLight ? Colors.black.withValues(alpha: 0.04) : Colors.white.withValues(alpha: 0.08),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text("💡 Resumo:", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 10, color: accentColor)),
                                                  const SizedBox(height: 2),
                                                  Text(n.cornellSummary, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: cardTextColor)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }

                              // Standard Note Card Layout
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: n.favorite ? accentColor.withValues(alpha: 0.5) : Colors.transparent,
                                    width: 1.5,
                                  ),
                                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2))],
                                ),
                                child: InkWell(
                                  onTap: () {
                                    final Map<String, dynamic> params = {
                                      "user": widget.u,
                                      "note": n,
                                    };
                                    context.push('/create/notes/add', extra: params).then((_) => _loadNotes());
                                  },
                                  borderRadius: BorderRadius.circular(18),
                                  child: Padding(
                                    padding: const EdgeInsets.all(14.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
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
                                            const SizedBox(width: 6),
                                            GestureDetector(
                                              onTap: () => _deleteNote(n.id),
                                              child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          n.displayDescription,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 12,
                                            color: cardSubtextColor,
                                            fontStyle: n.italic ? FontStyle.italic : null,
                                          ),
                                        ),
                                        if (totalCheck > 0) ...[
                                          const SizedBox(height: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: isCardLight ? Colors.black.withValues(alpha: 0.04) : Colors.white.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  doneCount == totalCheck ? Icons.check_circle : Icons.check_circle_outline,
                                                  size: 12,
                                                  color: doneCount == totalCheck ? Colors.green : cardSubtextColor,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  "$doneCount/$totalCheck",
                                                  style: TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: cardSubtextColor,
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
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: accentColor,
        elevation: 4,
        onPressed: () {
          context.push('/create/notes/add', extra: {"user": widget.u}).then((_) => _loadNotes());
        },
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
