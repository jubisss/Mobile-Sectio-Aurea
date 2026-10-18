import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sectio_aurea/services/banco_dados.dart';

class TasksScreen extends StatefulWidget {
  final Map<String, dynamic> u;

  const TasksScreen({super.key, required this.u});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<Map<String, dynamic>> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
    });

    int userId = widget.u["id_usuario"] ?? 1;
    final db = DatabaseService();
    List<Map<String, dynamic>> loadedTasks = await db.getTarefas(userId);

    // Sort by priority: shortest deadline first, then difficulty (Difícil -> Média -> Fácil)
    loadedTasks.sort((a, b) {
      String prazoA = a["prazo"] ?? '';
      String prazoB = b["prazo"] ?? '';

      // Shorter deadline first
      if (prazoA.isNotEmpty && prazoB.isEmpty) return -1;
      if (prazoA.isEmpty && prazoB.isNotEmpty) return 1;
      if (prazoA.isNotEmpty && prazoB.isNotEmpty) {
        int dateComp = prazoA.compareTo(prazoB);
        if (dateComp != 0) return dateComp;
      }

      // If deadlines are equal, sort by difficulty (Difícil -> Média -> Fácil)
      final diffWeight = {'Difícil': 3, 'Média': 2, 'Fácil': 1};
      int wA = diffWeight[a["dificuldade"]] ?? 2;
      int wB = diffWeight[b["dificuldade"]] ?? 2;
      return wB.compareTo(wA);
    });

    if (mounted) {
      setState(() {
        _tasks = loadedTasks;
        _isLoading = false;
      });
    }
  }

  void _deleteTask(int id) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xff1e1e1e) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            "Excluir Tarefa?", 
            style: TextStyle(
              fontFamily: 'Poppins', 
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            )
          ),
          content: Text(
            "Esta ação não poderá ser desfeita.",
            style: TextStyle(
              fontFamily: 'Poppins',
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
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
      await db.deleteTarefa(id, userId);
      _loadTasks();
    }
  }

  Color _getDifficultyColor(String diff) {
    if (diff == 'Difícil') return const Color(0xff9f042c);
    if (diff == 'Média') return Colors.orangeAccent;
    return Colors.green;
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
          "Tarefas",
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _tasks.isEmpty
                  ? Center(
                      child: Text(
                        "Sem tarefas cadastradas.\nToque no botão abaixo para criar!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: isDark ? Colors.white30 : Colors.black38,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _tasks.length,
                      padding: const EdgeInsets.only(top: 10, bottom: 80),
                      itemBuilder: (context, index) {
                        final t = _tasks[index];
                        final bool isCompleted = (t["ativo"] ?? 1) == 0;
                        final diffColor = isCompleted
                            ? Colors.grey
                            : _getDifficultyColor(t["dificuldade"]);
                        final Color textColor = isCompleted
                            ? (isDark ? Colors.white30 : Colors.black38)
                            : (isDark ? Colors.white : Colors.black87);

                        return Card(
                          color: isDark ? const Color(0xff1e1e1e) : Colors.white,
                          elevation: 1.5,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                // Left indicator of difficulty
                                Container(
                                  width: 5,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: diffColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Check/uncheck completion button
                                IconButton(
                                  icon: Icon(
                                    isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                                    color: isCompleted ? Colors.grey : accentColor,
                                  ),
                                  onPressed: () async {
                                    int newAtivo = isCompleted ? 1 : 0;
                                    final updatedTask = Map<String, dynamic>.from(t);
                                    updatedTask["ativo"] = newAtivo;

                                    final db = DatabaseService();
                                    bool success = await db.updateTarefa(updatedTask);
                                    if (success) {
                                      _loadTasks();
                                    } else {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Erro ao atualizar status da tarefa")),
                                        );
                                      }
                                    }
                                  },
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t["nome_tarefa"],
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: textColor,
                                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today_outlined, 
                                            size: 12, 
                                            color: isCompleted ? Colors.grey.withOpacity(0.3) : (isDark ? Colors.white30 : Colors.black38)
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            t["prazo"].toString().isNotEmpty ? t["prazo"] : 'Sem prazo',
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 11,
                                              color: isCompleted ? Colors.grey.withOpacity(0.5) : (isDark ? Colors.white60 : Colors.black45),
                                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: diffColor.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              t["dificuldade"],
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: diffColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete_outline, color: isDark ? Colors.white30 : Colors.black38),
                                  onPressed: () => _deleteTask(t["id_tarefa"]),
                                ),
                              ],
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
          context.push('/create/tasks/add', extra: widget.u).then((_) => _loadTasks());
        },
        child: Icon(Icons.add, color: accentColor.computeLuminance() > 0.5 ? Colors.black : Colors.white, size: 28),
      ),
    );
  }
}
