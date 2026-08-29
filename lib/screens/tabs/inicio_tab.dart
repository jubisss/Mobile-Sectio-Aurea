import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sectio_aurea/services/database_service.dart';
import 'package:sectio_aurea/widgets/workspace_tutorial_dialog.dart';

class InicioTab extends StatefulWidget {
  final Map<String, dynamic> u;

  const InicioTab({super.key, required this.u});

  @override
  State<InicioTab> createState() => _InicioTabState();
}

class _InicioTabState extends State<InicioTab> {
  List<Map<String, dynamic>> _tasks = [];
  Map<String, dynamic>? _nextEvent;
  Map<String, dynamic>? _nextSchedule;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    int userId = widget.u["id_usuario"] ?? 1;
    final db = DatabaseService();

    // Load Tasks
    List<Map<String, dynamic>> rawTasks = await db.getTarefas(userId);
    // Sort Tasks by priority (simulating comparator)
    rawTasks.sort((a, b) {
      String prazoA = a["prazo"] ?? '';
      String prazoB = b["prazo"] ?? '';
      if (prazoA.isNotEmpty && prazoB.isEmpty) return -1;
      if (prazoA.isEmpty && prazoB.isNotEmpty) return 1;
      if (prazoA.isNotEmpty && prazoB.isNotEmpty) {
        int dateComp = prazoA.compareTo(prazoB);
        if (dateComp != 0) return dateComp;
      }
      final diffWeight = {'Difícil': 3, 'Média': 2, 'Fácil': 1};
      int wA = diffWeight[a["dificuldade"]] ?? 2;
      int wB = diffWeight[b["dificuldade"]] ?? 2;
      return wB.compareTo(wA);
    });

    // Load Events
    List<Map<String, dynamic>> events = await db.getEvents(userId);
    // Sort events by date
    events.sort((a, b) {
      String dateA = a["data"] ?? '';
      String dateB = b["data"] ?? '';
      return dateA.compareTo(dateB);
    });

    // Load Schedules
    List<Map<String, dynamic>> schedules = await db.getCronograma(userId);
    // Find next schedule (simple mock pick or first slot)
    Map<String, dynamic>? nextSched;
    if (schedules.isNotEmpty) {
      nextSched = schedules.first;
    }

    if (mounted) {
      setState(() {
        _tasks = rawTasks.take(3).toList();
        _nextEvent = events.isNotEmpty ? events.first : null;
        _nextSchedule = nextSched;
        _isLoading = false;
      });
    }
  }

  void _showWorkspaceTutorial() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const WorkspaceTutorialDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: isDark ? Colors.tealAccent : Colors.black));
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: isDark ? Colors.tealAccent : Colors.black,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Text(
              "Olá, ${widget.u["nome"]}!",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w900,
                fontSize: 24,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              widget.u["tipo_dom"] != null && widget.u["tipo_dom"].toString().isNotEmpty
                  ? "Seu perfil dominante: ${widget.u["tipo_dom"]}"
                  : "Complete o teste no perfil para definir seu tema de estudos.",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 24),

            // 1. Três primeiras tarefas
            _buildSectionHeader("Suas Principais Tarefas", () {
              context.push('/create/tasks', extra: widget.u).then((_) => _loadData());
            }),
            const SizedBox(height: 8),
            if (_tasks.isEmpty)
              _buildEmptyCard("Nenhuma tarefa para fazer. Toque para criar!", () {
                context.push('/create/tasks', extra: widget.u).then((_) => _loadData());
              })
            else
              Column(
                children: _tasks.map((t) {
                  return Card(
                    color: isDark ? const Color(0xff1e1e1e) : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    elevation: 1.5,
                    child: ListTile(
                      onTap: () {
                        context.push('/create/tasks', extra: widget.u).then((_) => _loadData());
                      },
                      leading: CircleAvatar(
                        backgroundColor: t["dificuldade"] == 'Difícil'
                            ? const Color(0xff9f042c).withOpacity(0.1)
                            : t["dificuldade"] == 'Média'
                                ? Colors.orangeAccent.withOpacity(0.1)
                                : Colors.green.withOpacity(0.1),
                        child: Icon(
                          Icons.task_alt,
                          color: t["dificuldade"] == 'Difícil'
                              ? const Color(0xff9f042c)
                              : t["dificuldade"] == 'Média'
                                  ? Colors.orangeAccent
                                  : Colors.green,
                        ),
                      ),
                      title: Text(
                        t["nome_tarefa"],
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        "Prazo: ${t["prazo"]} • Dificuldade: ${t["dificuldade"]}",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: isDark ? Colors.white60 : Colors.black45,
                        ),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, size: 14, color: isDark ? Colors.white30 : Colors.black26),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 20),

            // 2. Próximo evento
            _buildSectionHeader("Próximo Evento", () {
              context.push('/create/calendar', extra: widget.u).then((_) => _loadData());
            }),
            const SizedBox(height: 8),
            if (_nextEvent == null)
              _buildEmptyCard("Sem eventos agendados. Toque para criar!", () {
                context.push('/create/calendar', extra: widget.u).then((_) => _loadData());
              })
            else
              Card(
                color: isDark ? const Color(0xff1e1e1e) : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 1.5,
                child: ListTile(
                  onTap: () {
                    context.push('/create/calendar', extra: widget.u).then((_) => _loadData());
                  },
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.event, color: Colors.white),
                  ),
                  title: Text(
                    _nextEvent!["tipo"].toString().split('|')[0],
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    "Data: ${() {
                      String dateStr = _nextEvent!["data"] ?? "";
                      try {
                        List<String> parts = dateStr.split("-");
                        if (parts.length == 3) {
                          return "${parts[2]}/${parts[1]}/${parts[0]}";
                        }
                      } catch (_) {}
                      return dateStr;
                    }()}",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: isDark ? Colors.white60 : Colors.black45,
                    ),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 14, color: isDark ? Colors.white30 : Colors.black26),
                ),
              ),
            const SizedBox(height: 20),

            // 3. Próxima matéria do cronograma
            _buildSectionHeader("Próxima Aula do Cronograma", () {
              String plano = widget.u["plano"]?.toString().toLowerCase() ?? "gratuito";
              if (plano == "gratuito") {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: const Text("Recurso Premium", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                    content: const Text("O Cronograma Inteligente está disponível apenas nos planos Básico e Pro. Faça o upgrade nas Configurações do seu perfil.", style: TextStyle(fontFamily: 'Poppins')),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("OK", style: TextStyle(color: Colors.black)),
                      ),
                    ],
                  ),
                );
              } else {
                context.push('/create/schedule', extra: widget.u).then((_) => _loadData());
              }
            }),
            const SizedBox(height: 8),
            if (_nextSchedule == null)
              _buildEmptyCard("Nenhuma aula configurada no cronograma.", () {
                String plano = widget.u["plano"]?.toString().toLowerCase() ?? "gratuito";
                if (plano == "gratuito") {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: const Text("Recurso Premium", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                      content: const Text("O Cronograma Inteligente está disponível apenas nos planos Básico e Pro. Faça o upgrade nas Configurações do seu perfil.", style: TextStyle(fontFamily: 'Poppins')),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("OK", style: TextStyle(color: Colors.black)),
                        ),
                      ],
                    ),
                  );
                } else {
                  context.push('/create/schedule', extra: widget.u).then((_) => _loadData());
                }
              })
            else
              Card(
                color: isDark ? const Color(0xff1e1e1e) : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 1.5,
                child: ListTile(
                  onTap: () {
                    context.push('/create/schedule', extra: widget.u).then((_) => _loadData());
                  },
                  leading: const CircleAvatar(
                    backgroundColor: Colors.indigo,
                    child: Icon(Icons.school, color: Colors.white),
                  ),
                  title: Text(
                    _nextSchedule!["nome_materia"],
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    "Toda ${_nextSchedule!["dia_semana"]} das ${_nextSchedule!["hora_inicio"]} às ${_nextSchedule!["hora_final"]}",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: isDark ? Colors.white60 : Colors.black45,
                    ),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 14, color: isDark ? Colors.white30 : Colors.black26),
                ),
              ),
            const SizedBox(height: 24),

            // 4. Tutorial de organização de espaço
            GestureDetector(
              onTap: _showWorkspaceTutorial,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.black, Colors.black87],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white12,
                      child: Icon(Icons.clean_hands, color: Colors.orangeAccent),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Organizar Espaço de Estudo",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Clique para ver o tutorial em 6 etapas.",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onTap) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(
            "Ver tudo",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.tealAccent : Colors.black54,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCard(String msg, VoidCallback onTap) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xff1e1e1e) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black12, style: BorderStyle.solid),
        ),
        child: Center(
          child: Text(
            msg,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: isDark ? Colors.white30 : Colors.black38,
            ),
          ),
        ),
      ),
    );
  }
}
