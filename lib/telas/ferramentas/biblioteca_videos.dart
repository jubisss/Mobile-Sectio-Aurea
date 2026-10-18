import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sectio_aurea/services/banco_dados.dart';

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
    List<Map<String, dynamic>> vids = await db.getVideos(userId);

    // Support legacy note-stored videos as well
    List<Map<String, dynamic>> notes = await db.getNotes(userId);
    for (var n in notes) {
      try {
        final content = (n["conteudo"] ?? "").toString();
        if (content.contains('video_type') || content.contains('📺 VÍDEO:')) {
          var parsed = _parseVideo(n);
          if (!vids.any((v) => v["url"] == parsed["link"] && parsed["link"].toString().isNotEmpty)) {
            vids.add(parsed);
          }
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

                int userId = widget.u["id_usuario"] ?? 1;
                await DatabaseService().createVideo(
                  userId: userId,
                  materia: selectedMateria ?? "Geral",
                  titulo: title,
                  url: link,
                  tema: theme,
                  anotacoes: notesText,
                  assistido: false,
                );

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

  void _deleteVideo(dynamic id) async {
    int userId = widget.u["id_usuario"] ?? 1;
    int intId = int.tryParse(id.toString()) ?? 0;
    if (intId > 0) {
      await DatabaseService().deleteVideo(intId, userId);
      await DatabaseService().deleteNote(intId, userId);
    }
    _loadData();
  }

  Map<String, dynamic> _parseVideo(Map<String, dynamic> raw) {
    if (raw.containsKey("id_video") || raw.containsKey("url")) {
      return {
        "id_video": raw["id_video"],
        "id_anotacao": raw["id_video"],
        "title": raw["titulo"] ?? raw["title"] ?? "Vídeo",
        "materia": raw["materia"] ?? "Geral",
        "link": raw["url"] ?? raw["link"] ?? "",
        "theme": raw["tema"] ?? raw["theme"] ?? "",
        "watched": raw["assistido"] == true || raw["watched"] == true || raw["assistido"] == 1,
        "anotacoes": raw["anotacoes"] ?? "",
        "full_content": "",
      };
    }

    String content = (raw["conteudo"] ?? "").toString();
    content = content.replaceAll('&quot;', '"').replaceAll('&amp;', '&');
    Map<String, dynamic> meta = {};
    int jsonStart = content.indexOf('{"video_type"');
    if (jsonStart != -1) {
      try {
        meta = jsonDecode(content.substring(jsonStart));
      } catch (_) {}
    }

    String title = meta["title"] ?? "";
    String materia = meta["materia"] ?? "Geral";
    String link = meta["link"] ?? "";
    String theme = meta["theme"] ?? "";
    bool watched = meta["watched"] == true;

    if (title.isEmpty) {
      for (var line in content.split('\n')) {
        if (line.startsWith("📺 VÍDEO:")) title = line.replaceFirst("📺 VÍDEO:", "").trim();
        if (line.startsWith("📚 Matéria:")) materia = line.replaceFirst("📚 Matéria:", "").trim();
        if (line.startsWith("🔗 Link:")) link = line.replaceFirst("🔗 Link:", "").trim();
        if (line.startsWith("🎯 Tema:")) theme = line.replaceFirst("🎯 Tema:", "").trim();
        if (line.startsWith("📌 Tema:")) theme = line.replaceFirst("📌 Tema:", "").trim();
      }
    }

    return {
      "id_video": raw["id_anotacao"],
      "id_anotacao": raw["id_anotacao"],
      "title": title.isNotEmpty ? title : "Vídeo Sem Título",
      "materia": materia,
      "link": link,
      "theme": theme,
      "watched": watched,
      "full_content": content,
    };
  }

  List<Map<String, dynamic>> _getFilteredVideos() {
    final query = _searchController.text.trim().toLowerCase();

    return _videos.map(_parseVideo).where((v) {
      if (_selectedSubjectFilter != "Todas as matérias") {
        if (v["materia"].toString().toLowerCase() != _selectedSubjectFilter.toLowerCase()) {
          return false;
        }
      }

      if (_selectedStatusFilter == "Assistidos" && v["watched"] != true) {
        return false;
      }
      if (_selectedStatusFilter == "Não assistidos" && v["watched"] == true) {
        return false;
      }

      if (query.isNotEmpty) {
        final title = v["title"].toString().toLowerCase();
        final theme = v["theme"].toString().toLowerCase();
        final mat = v["materia"].toString().toLowerCase();
        if (!title.contains(query) && !theme.contains(query) && !mat.contains(query)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void _toggleWatched(Map<String, dynamic> vid) async {
    int userId = widget.u["id_usuario"] ?? 1;
    bool newWatched = !(vid["watched"] as bool);
    int vidId = int.tryParse((vid["id_video"] ?? vid["id_anotacao"]).toString()) ?? 0;

    if (vidId > 0) {
      await DatabaseService().updateVideo(vidId, {"assistido": newWatched ? 1 : 0}, userId);
    }

    if ((vid["full_content"] ?? "").toString().isNotEmpty) {
      String oldContent = vid["full_content"] as String;
      int jsonStart = oldContent.indexOf('{"video_type"');
      String prefix = jsonStart != -1 ? oldContent.substring(0, jsonStart) : oldContent;

      Map<String, dynamic> newMeta = {
        "video_type": "youtube",
        "title": vid["title"],
        "materia": vid["materia"],
        "link": vid["link"],
        "theme": vid["theme"],
        "watched": newWatched,
      };

      String updatedContent = "$prefix${jsonEncode(newMeta)}";
      await DatabaseService().updateNote(vidId, updatedContent, '0xffff5f00', userId);
    }
    _loadData();
  }

  Future<void> _openVideo(String url) async {
    if (url.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Este vídeo não possui link válido cadastrado.")),
      );
      return;
    }

    String formattedUrl = url.trim();
    if (!formattedUrl.startsWith("http://") && !formattedUrl.startsWith("https://")) {
      formattedUrl = "https://$formattedUrl";
    }

    final uri = Uri.tryParse(formattedUrl);
    if (uri != null) {
      try {
        bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!launched) {
          await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Não foi possível abrir o link: $e")),
          );
        }
      }
    }
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
                  : Builder(
                      builder: (context) {
                        final filteredVideos = _getFilteredVideos();
                        if (filteredVideos.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.ondemand_video, size: 48, color: Colors.grey.shade400),
                                const SizedBox(height: 12),
                                Text(
                                  _videos.isEmpty
                                      ? "Nenhum vídeo cadastrado.\nClique no botão + acima para adicionar!"
                                      : "Nenhum vídeo encontrado com os filtros selecionados.",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: filteredVideos.length,
                          itemBuilder: (context, index) {
                            final vid = filteredVideos[index];
                            bool watched = vid["watched"] == true;

                            return Card(
                              color: cardBg,
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 1,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => _openVideo(vid["link"]),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // Ícone / Thumbnail Play
                                      CircleAvatar(
                                        radius: 22,
                                        backgroundColor: themeColor.withValues(alpha: 0.15),
                                        child: Icon(Icons.play_arrow_rounded, color: themeColor, size: 28),
                                      ),
                                      const SizedBox(width: 12),

                                      // Informações do Vídeo
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              vid["title"],
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                color: textColor,
                                                decoration: watched ? TextDecoration.lineThrough : null,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Wrap(
                                              spacing: 6,
                                              runSpacing: 4,
                                              children: [
                                                // Matéria
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: themeColor.withValues(alpha: 0.12),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    vid["materia"],
                                                    style: TextStyle(
                                                      fontFamily: 'Poppins',
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w600,
                                                      color: themeColor,
                                                    ),
                                                  ),
                                                ),
                                                // Status Assistido / Pendente
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: watched
                                                        ? Colors.green.withValues(alpha: 0.12)
                                                        : Colors.orange.withValues(alpha: 0.12),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    watched ? "Assistido" : "Pendente",
                                                    style: TextStyle(
                                                      fontFamily: 'Poppins',
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                      color: watched ? Colors.green : Colors.orange.shade800,
                                                    ),
                                                  ),
                                                ),
                                                if (vid["theme"].toString().isNotEmpty)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey.withValues(alpha: 0.15),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      vid["theme"],
                                                      style: TextStyle(
                                                        fontFamily: 'Poppins',
                                                        fontSize: 10,
                                                        color: textColor.withValues(alpha: 0.7),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Ações
                                      IconButton(
                                        icon: Icon(
                                          watched ? Icons.check_circle : Icons.check_circle_outline,
                                          color: watched ? Colors.green : Colors.grey,
                                          size: 22,
                                        ),
                                        tooltip: watched ? "Marcar como não assistido" : "Marcar como assistido",
                                        onPressed: () => _toggleWatched(vid),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                                        tooltip: "Excluir vídeo",
                                        onPressed: () => _deleteVideo(vid["id_video"] ?? vid["id_anotacao"]),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
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
