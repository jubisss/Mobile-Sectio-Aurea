import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sectio_aurea/models/nota.dart';
import 'package:sectio_aurea/services/banco_dados.dart';

class SearchScreen extends StatefulWidget {
  final Map<String, dynamic> u;

  const SearchScreen({super.key, required this.u});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = "Todos"; // Todos, Notas, Tarefas, Matérias
  
  bool _isLoading = false;
  List<Map<String, dynamic>> _allNotes = [];
  List<Map<String, dynamic>> _allTasks = [];
  List<Map<String, dynamic>> _allSubjects = [];
  
  List<Map<String, dynamic>> _filteredNotes = [];
  List<Map<String, dynamic>> _filteredTasks = [];
  List<Map<String, dynamic>> _filteredSubjects = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    int userId = widget.u["id_usuario"] ?? 1;
    final db = DatabaseService();

    try {
      final notes = await db.getNotes(userId);
      final tasks = await db.getTarefas(userId);
      final subjects = await db.getMaterias(userId);

      if (mounted) {
        setState(() {
          _allNotes = notes;
          _allTasks = tasks;
          _allSubjects = subjects;
          _isLoading = false;
          _applyFilter();
        });
      }
    } catch (e) {
      print("Search data loading error: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged() {
    _applyFilter();
  }

  void _applyFilter() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      final validNotes = _allNotes.where((note) {
        final raw = note["conteudo"]?.toString() ?? '';
        return !(raw.contains('"type":"mapa_mental"') ||
            raw.contains('"type":"diagrama_fluxo"') ||
            raw.contains('"type":"rec"') ||
            raw.contains('GRAVAÇÃO:') ||
            raw.contains('MAPA MENTAL:') ||
            raw.contains('DIAGRAMA DE FLUXO:'));
      }).toList();

      if (query.isEmpty) {
        _filteredNotes = validNotes;
        _filteredTasks = List.from(_allTasks);
        _filteredSubjects = List.from(_allSubjects);
      } else {
        _filteredNotes = validNotes.where((note) {
          final content = note["conteudo"]?.toString().toLowerCase() ?? '';
          return content.contains(query);
        }).toList();

        _filteredTasks = _allTasks.where((task) {
          final name = task["nome_tarefa"]?.toString().toLowerCase() ?? '';
          final diff = task["dificuldade"]?.toString().toLowerCase() ?? '';
          return name.contains(query) || diff.contains(query);
        }).toList();

        _filteredSubjects = _allSubjects.where((subject) {
          final name = subject["nome"]?.toString().toLowerCase() ?? '';
          return name.contains(query);
        }).toList();
      }
    });
  }

  Color _getThemeColor(String hexColor) {
    try {
      if (hexColor.startsWith('0x')) {
        return Color(int.parse(hexColor));
      }
      return Color(int.parse(hexColor.replaceAll('#', '0xff')));
    } catch (_) {
      return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    // User primary intelligence color accent
    Color userAccent = Colors.blueGrey;
    String? colorHex = widget.u["clas_inteli"];
    if (colorHex != null && colorHex.isNotEmpty) {
      try {
        userAccent = Color(int.parse(colorHex));
      } catch (_) {}
    }

    int totalResults = 0;
    if (_selectedCategory == "Todos" || _selectedCategory == "Notas") {
      totalResults += _filteredNotes.length;
    }
    if (_selectedCategory == "Todos" || _selectedCategory == "Tarefas") {
      totalResults += _filteredTasks.length;
    }
    if (_selectedCategory == "Todos" || _selectedCategory == "Matérias") {
      totalResults += _filteredSubjects.length;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Buscar Itens",
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: userAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Search Box & Filters
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search Input Field
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Buscar por nome, conteúdo ou dificuldade...",
                    hintStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: userAccent.withOpacity(0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: userAccent, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),

                // Category Selector chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ["Todos", "Notas", "Tarefas", "Matérias"].map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(
                            cat,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: userAccent,
                          backgroundColor: isDark ? Colors.white12 : Colors.grey[200],
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedCategory = cat;
                              });
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                )
              ],
            ),
          ),

          // Search Results
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : totalResults == 0
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_outlined, size: 48, color: isDark ? Colors.white30 : Colors.black26),
                            const SizedBox(height: 12),
                            const Text(
                              "Nenhum item encontrado",
                              style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.blueGrey),
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          // Notes Results
                          if (_selectedCategory == "Todos" || _selectedCategory == "Notas") ...[
                            if (_filteredNotes.isNotEmpty) ...[
                              _buildSectionHeader("Notas", Icons.note_alt_outlined, userAccent),
                              ..._filteredNotes.map((note) {
                                final notaObj = Nota.fromMap(note);
                                final Color noteColor = _getThemeColor(note["cor_nota"] ?? '0xfff4f1eb');

                                return Card(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  child: ListTile(
                                    onTap: () {
                                      if (notaObj.isCornell) {
                                        context.push('/create/cornell', extra: {
                                          "user": widget.u,
                                          "editNote": notaObj,
                                        }).then((_) => _loadData());
                                      } else {
                                        context.push('/create/notes/add', extra: {
                                          "user": widget.u,
                                          "note": notaObj,
                                        }).then((_) => _loadData());
                                      }
                                    },
                                    leading: CircleAvatar(
                                      backgroundColor: noteColor,
                                      radius: 12,
                                    ),
                                    title: Text(
                                      notaObj.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600),
                                    ),
                                    subtitle: Text(
                                      notaObj.isCornell
                                          ? "Método Cornell • ${notaObj.displayDescription.replaceAll('\n', ' ')}"
                                          : (notaObj.displayDescription.isNotEmpty
                                              ? notaObj.displayDescription.replaceAll('\n', ' ')
                                              : "Anotação salva"),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 10),
                                    ),
                                    trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                                  ),
                                );
                              }),
                            ]
                          ],

                          // Tasks Results
                          if (_selectedCategory == "Todos" || _selectedCategory == "Tarefas") ...[
                            if (_filteredTasks.isNotEmpty) ...[
                              _buildSectionHeader("Tarefas", Icons.task_outlined, userAccent),
                              ..._filteredTasks.map((task) {
                                return Card(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  child: ListTile(
                                    onTap: () {
                                      _showTaskDetailModal(task, userAccent);
                                    },
                                    leading: CircleAvatar(
                                      backgroundColor: userAccent.withOpacity(0.1),
                                      child: Icon(Icons.playlist_add_check, color: userAccent),
                                    ),
                                    title: Text(
                                      task["nome_tarefa"] ?? "",
                                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600),
                                    ),
                                    subtitle: Text(
                                      "Prazo: ${task["prazo"] ?? 'Sem prazo'}",
                                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 10),
                                    ),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: task["dificuldade"] == "Difícil"
                                            ? Colors.redAccent.withOpacity(0.1)
                                            : (task["dificuldade"] == "Média"
                                                ? Colors.orangeAccent.withOpacity(0.1)
                                                : Colors.green.withOpacity(0.1)),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        task["dificuldade"] ?? "",
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: task["dificuldade"] == "Difícil"
                                              ? Colors.redAccent
                                              : (task["dificuldade"] == "Média"
                                                  ? Colors.orangeAccent
                                                  : Colors.green),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ]
                          ],

                          // Subjects Results
                          if (_selectedCategory == "Todos" || _selectedCategory == "Matérias") ...[
                            if (_filteredSubjects.isNotEmpty) ...[
                              _buildSectionHeader("Matérias", Icons.book_outlined, userAccent),
                              ..._filteredSubjects.map((sub) {
                                Color subColor = _getThemeColor(sub["cor"] ?? '#ffbd59');
                                return Card(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  child: ListTile(
                                    onTap: () {
                                      context.push('/create/subjects', extra: widget.u).then((_) => _loadData());
                                    },
                                    leading: CircleAvatar(
                                      backgroundColor: subColor,
                                      radius: 14,
                                    ),
                                    title: Text(
                                      sub["nome"] ?? "",
                                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600),
                                    ),
                                    subtitle: const Text("Disciplina cadastrada", style: TextStyle(fontFamily: 'Poppins', fontSize: 10)),
                                    trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                                  ),
                                );
                              }),
                            ]
                          ],
                          const SizedBox(height: 24),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  void _showTaskDetailModal(Map<String, dynamic> task, Color accentColor) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          task["nome_tarefa"] ?? "Tarefa",
          style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((task["nome_materia"] ?? "").isNotEmpty) ...[
              Text("Matéria: ${task["nome_materia"]}", style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
            ],
            Text("Prazo: ${task["prazo"] ?? 'Não definido'}", style: const TextStyle(fontFamily: 'Poppins', fontSize: 12)),
            const SizedBox(height: 4),
            Text("Dificuldade: ${task["dificuldade"] ?? 'Média'}", style: const TextStyle(fontFamily: 'Poppins', fontSize: 12)),
            if ((task["descricao"] ?? "").isNotEmpty) ...[
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 6),
              Text(task["descricao"], style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: isDark ? Colors.white70 : Colors.black87)),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Fechar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.push('/create/tasks', extra: widget.u).then((_) => _loadData());
            },
            child: const Text("Ver em Tarefas", style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 12.5,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }
}
