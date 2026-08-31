import 'package:flutter/material.dart';
import 'package:sectio_aurea/services/database_service.dart';

class VideoLibraryScreen extends StatefulWidget {
  final Map<String, dynamic> u;

  const VideoLibraryScreen({super.key, required this.u});

  @override
  State<VideoLibraryScreen> createState() => _VideoLibraryScreenState();
}

class _VideoLibraryScreenState extends State<VideoLibraryScreen> {
  List<Map<String, dynamic>> _videos = [];
  List<Map<String, dynamic>> _subjects = [];
  bool _isLoading = true;

  String _selectedSubjectFilter = "Todas as matérias";
  String _selectedStatusFilter = "Todos"; // Todos, Assistidos, Não assistidos
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    int userId = widget.u["id_usuario"] ?? 1;
    final db = DatabaseService();

    List<Map<String, dynamic>> mats = await db.getMaterias(userId);
    List<Map<String, dynamic>> notes = await db.getNotes(userId);

    // Filter notes with video_type
    List<Map<String, dynamic>> vids = [];
    for (var n in notes) {
      try {
        final content = n["conteudo"];
        if (content != null && content.toString().contains('"video_type":')) {
          vids.add(n);
        }
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _subjects = mats;
        _videos = vids;
        _isLoading = false;
      });
    }
  }

  void _showAddVideoDialog() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    const Color themeColor = Color(0xFFff5f00); // Cor Interpessoal / Laranja

    String? selectedMateria = _subjects.isNotEmpty ? _subjects.first["nome"] : "Geral";
    final titleController = TextEditingController();
    final linkController = TextEditingController();
    final themeController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.video_library_outlined, color: themeColor),
              SizedBox(width: 8),
              Text("Adicionar Vídeo", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Matéria
                const Text("Matéria:", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedMateria,
                      isExpanded: true,
                      items: _subjects.map((m) {
                        return DropdownMenuItem<String>(
                          value: m["nome"].toString(),
                          child: Text(m["nome"].toString(), style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedMateria = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Título do vídeo
                const Text("Título do vídeo:", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 4),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: "Ex: O que é Citologia?",
                    hintStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                ),
                const SizedBox(height: 10),

                // Link do vídeo
                const Text("Link do vídeo:", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 4),
                TextField(
                  controller: linkController,
                  decoration: InputDecoration(
                    hintText: "https://www.youtube.com/watch?v=...",
                    hintStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                ),
                const SizedBox(height: 10),

                // Tema/Pasta
                const Text("Tema/Pasta:", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 4),
                TextField(
                  controller: themeController,
                  decoration: InputDecoration(
                    hintText: "Ex: Citologia, Genética...",
                    hintStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                ),
                const SizedBox(height: 10),

                // Anotações
                const Text("Anotações:", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 4),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Anotações sobre o vídeo...",
                    hintStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar", style: TextStyle(color: isDark ? Colors.white60 : Colors.black54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                String title = titleController.text.trim();
                if (title.isEmpty) title = "Vídeo Educativo";

                String link = linkController.text.trim();
                String theme = themeController.text.trim();
                String notesText = notesController.text.trim();

                String content = "📺 VÍDEO: $title\n"
                    "📚 Matéria: $selectedMateria\n"
                    "🔗 Link: $link\n"
                    "📌 Tema: $theme\n"
                    "📝 Anotações: $notesText\n"
                    "{\"video_type\":\"youtube\",\"title\":\"$title\",\"materia\":\"$selectedMateria\",\"link\":\"$link\",\"theme\":\"$theme\",\"watched\":false}";

                int userId = widget.u["id_usuario"] ?? 1;
                await DatabaseService().createNote(content, '0xffff5f00', userId);

                if (context.mounted) {
                  Navigator.pop(context);
                  _loadData();
                }
              },
              child: const Text("Salvar Vídeo", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteVideo(int id) async {
    int userId = widget.u["id_usuario"] ?? 1;
    await DatabaseService().deleteNote(id, userId);
    _loadData();
  }

  Color _getPrimaryColor() {
    String? hex = widget.u["clas_inteli"];
    if (hex != null && hex.isNotEmpty) {
      try {
        return Color(int.parse(hex));
      } catch (_) {}
    }
    return const Color(0xFFff5f00);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color themeColor = _getPrimaryColor();
    final Color pageBg = isDark ? const Color(0xff121212) : const Color(0xfff4f1eb);
    final Color cardBg = isDark ? const Color(0xff1e1e1e) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: themeColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Biblioteca de Vídeos",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white, size: 28),
            onPressed: _showAddVideoDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Filtros Topo (Matéria + Status)
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedSubjectFilter,
                        isExpanded: true,
                        items: ["Todas as matérias", ..._subjects.map((m) => m["nome"].toString())].map((s) {
                          return DropdownMenuItem<String>(
                            value: s,
                            child: Text(s, style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: textColor)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedSubjectFilter = val);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedStatusFilter,
                        isExpanded: true,
                        items: ["Todos", "Assistidos", "Não assistidos"].map((s) {
                          return DropdownMenuItem<String>(
                            value: s,
                            child: Text(s, style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: textColor)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedStatusFilter = val);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Campo de Busca
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Buscar vídeo...",
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: cardBg,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: textColor),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 16),

            // Lista de Vídeos
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _videos.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.ondemand_video, size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 12),
                              const Text(
                                "Nenhum vídeo encontrado.\nClique em \"+ Adicionar Vídeo\" para começar!",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _videos.length,
                          itemBuilder: (context, index) {
                            final vid = _videos[index];
                            String content = vid["conteudo"].toString();
                            String title = content.split('\n').first.replaceAll('📺 VÍDEO: ', '');

                            return Card(
                              color: cardBg,
                              margin: const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: const Color(0xFFffeee6),
                                  child: Icon(Icons.play_arrow, color: themeColor),
                                ),
                                title: Text(title, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 13, color: textColor)),
                                subtitle: const Text("Vídeo Educativo", style: TextStyle(fontFamily: 'Poppins', fontSize: 11)),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                  onPressed: () => _deleteVideo(vid["id_anotacao"]),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
