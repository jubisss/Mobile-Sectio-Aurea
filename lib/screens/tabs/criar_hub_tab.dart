import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CriarHubTab extends StatelessWidget {
  final Map<String, dynamic> u;

  const CriarHubTab({super.key, required this.u});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color accentColor = Colors.blueGrey;
    String? colorHex = u["clas_inteli"];
    if (colorHex != null && colorHex.isNotEmpty) {
      try {
        accentColor = Color(int.parse(colorHex));
      } catch (_) {}
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(
            "Gerenciadores de Estudo",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w900,
              fontSize: 22,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Text(
            "Crie e organize seus horários, matérias, tarefas e notas.",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                _buildHubCard(
                  context,
                  "Tarefas",
                  "Organize suas atividades por prioridade e prazos.",
                  Icons.checklist_rtl_outlined,
                  const Color(0xff9f042c), // Deep Red
                  () => context.push('/create/tasks', extra: u),
                ),
                _buildHubCard(
                  context,
                  "Notas",
                  "Crie anotações, listas de verificação e resumos formatados.",
                  Icons.note_alt_outlined,
                  const Color(0xff00bf63), // Green
                  () => context.push('/create/notes', extra: u),
                ),
                _buildHubCard(
                  context,
                  "Matérias",
                  "Cadastre disciplinas e controle o tempo total dedicado a cada uma.",
                  Icons.menu_book_outlined,
                  const Color(0xffff5f00), // Orange
                  () => context.push('/create/subjects', extra: u),
                ),
                _buildHubCard(
                  context,
                  "Cronograma",
                  "Monitore sua rotina semanal em blocos integrados.",
                  Icons.calendar_month_outlined,
                  const Color(0xff5170ff), // Blue
                  () {
                    String plano = u["plano"]?.toString().toLowerCase() ?? "gratuito";
                    if (plano == "gratuito") {
                      showDialog(
                        context: context,
                        builder: (context) {
                          final bool isDarkAlert = Theme.of(context).brightness == Brightness.dark;
                          return AlertDialog(
                            backgroundColor: isDarkAlert ? const Color(0xff1e1e1e) : Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: Text(
                              "Recurso Premium", 
                              style: TextStyle(
                                fontFamily: 'Poppins', 
                                fontWeight: FontWeight.bold,
                                color: isDarkAlert ? Colors.white : Colors.black87,
                              )
                            ),
                            content: Text(
                              "O Cronograma Inteligente está disponível apenas nos planos Básico e Pro. Faça o upgrade nas Configurações do seu perfil.", 
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: isDarkAlert ? Colors.white70 : Colors.black54,
                              )
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  "OK", 
                                  style: TextStyle(
                                    color: isDarkAlert ? Colors.tealAccent : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  )
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      context.push('/create/schedule', extra: u);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHubCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
  ) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardBgColor = isDark ? const Color(0xff1e1e1e) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color descColor = isDark ? Colors.white60 : Colors.black54;
    final Color arrowColor = isDark ? Colors.white30 : Colors.black26;

    return Card(
      color: cardBgColor,
      elevation: 2,
      shadowColor: isDark ? Colors.black38 : Colors.black12,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: descColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: arrowColor,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
