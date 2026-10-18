import 'package:flutter/material.dart';
import 'package:sectio_aurea/services/banco_dados.dart';
import 'package:sectio_aurea/widgets/botao.dart';
import 'package:sectio_aurea/widgets/campo_texto.dart';
import 'package:sectio_aurea/widgets/seletor_cores.dart';

class CalendarScreen extends StatefulWidget {
  final Map<String, dynamic> u;

  const CalendarScreen({super.key, required this.u});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  List<Map<String, dynamic>> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
    });

    int userId = widget.u["id_usuario"] ?? 1;
    final db = DatabaseService();
    List<Map<String, dynamic>> loadedEvents = await db.getEvents(userId);

    // Sort by date ascending
    loadedEvents.sort((a, b) {
      String dateA = a["data"] ?? '';
      String dateB = b["data"] ?? '';
      return dateA.compareTo(dateB);
    });

    if (mounted) {
      setState(() {
        _events = loadedEvents;
        _isLoading = false;
      });
    }
  }

  void _addEvent() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    DateTime? selectedDate;
    String selectedEventColorHex = widget.u["clas_inteli"] ?? "0xff5170ff";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> pickDate() async {
              final bool isDark = Theme.of(context).brightness == Brightness.dark;
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: isDark ? Colors.tealAccent : Colors.black87,
                        onPrimary: isDark ? Colors.black : Colors.white,
                        onSurface: isDark ? Colors.white : Colors.black87,
                        surface: isDark ? const Color(0xff1e1e1e) : Colors.white,
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(foregroundColor: isDark ? Colors.tealAccent : Colors.black87),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setDialogState(() {
                  selectedDate = picked;
                });
              }
            }

            final bool isDark = Theme.of(context).brightness == Brightness.dark;
            Color accentColor = Colors.blueGrey;
            String? colorHex = widget.u["clas_inteli"];
            if (colorHex != null && colorHex.isNotEmpty) {
              try {
                accentColor = Color(int.parse(colorHex));
              } catch (_) {}
            }

            return AlertDialog(
              backgroundColor: isDark ? const Color(0xff1e1e1e) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(
                "Novo Evento / Avaliação",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CampoTexto(
                      labelText: "Título / Tipo de Evento *",
                      controller: titleController,
                      obscureText: false,
                      width: double.infinity,
                    ),
                    const SizedBox(height: 8),
                    CampoTexto(
                      labelText: "Descrição (Opcional)",
                      controller: descController,
                      obscureText: false,
                      width: double.infinity,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Data do Evento *",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: pickDate,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xff2d2d2d) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedDate == null
                                  ? "Selecionar data"
                                  : "${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                            Icon(Icons.calendar_today, size: 16, color: isDark ? Colors.white54 : Colors.black54),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Cor do Evento",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            final String? picked = await SeletorCoresModal.abrir(
                              context: context,
                              corAtual: selectedEventColorHex,
                              titulo: "Cor do Evento",
                            );
                            if (picked != null) {
                              setDialogState(() {
                                selectedEventColorHex = picked;
                              });
                            }
                          },
                          icon: Icon(Icons.palette_outlined, size: 16, color: accentColor),
                          label: Text(
                            "Paleta Docs",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        final String? picked = await SeletorCoresModal.abrir(
                          context: context,
                          corAtual: selectedEventColorHex,
                          titulo: "Cor do Evento",
                        );
                        if (picked != null) {
                          setDialogState(() {
                            selectedEventColorHex = picked;
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xff2d2d2d) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: Color(int.parse(selectedEventColorHex)),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black12),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "Toque para escolher cor",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.palette, size: 16, color: isDark ? Colors.white54 : Colors.black45),
                          ],
                        ),
                      ),
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
                    backgroundColor: isDark ? accentColor : Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    String title = titleController.text.trim();
                    String desc = descController.text.trim();

                    if (title.isEmpty) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          final bool isDarkAlert = Theme.of(context).brightness == Brightness.dark;
                          return AlertDialog(
                            backgroundColor: isDarkAlert ? const Color(0xff1e1e1e) : Colors.white,
                            title: Text("Aviso", style: TextStyle(color: isDarkAlert ? Colors.white : Colors.black87)),
                            content: Text("O título é obrigatório.", style: TextStyle(color: isDarkAlert ? Colors.white70 : Colors.black54)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("OK", style: TextStyle(color: isDarkAlert ? Colors.tealAccent : Colors.black87)),
                              ),
                            ],
                          );
                        },
                      );
                      return;
                    }

                    if (selectedDate == null) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          final bool isDarkAlert = Theme.of(context).brightness == Brightness.dark;
                          return AlertDialog(
                            backgroundColor: isDarkAlert ? const Color(0xff1e1e1e) : Colors.white,
                            title: Text("Aviso", style: TextStyle(color: isDarkAlert ? Colors.white : Colors.black87)),
                            content: Text("Selecione a data do evento.", style: TextStyle(color: isDarkAlert ? Colors.white70 : Colors.black54)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("OK", style: TextStyle(color: isDarkAlert ? Colors.tealAccent : Colors.black87)),
                              ),
                            ],
                          );
                        },
                      );
                      return;
                    }

                    // Pack Title and Description
                    String typeField = title;
                    if (desc.isNotEmpty) {
                      typeField = "$title|$desc";
                    }

                    String dateStr = "${selectedDate!.year.toString().padLeft(4, '0')}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";

                    final db = DatabaseService();
                    int userId = widget.u["id_usuario"] ?? 1;

                    int evId = await db.createEvent(typeField, dateStr, selectedEventColorHex, userId);

                    if (evId > 0) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Evento agendado com sucesso!")),
                        );
                        Navigator.pop(context);
                      }
                      _loadEvents();
                    } else {
                      if (context.mounted) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            final bool isDarkAlert = Theme.of(context).brightness == Brightness.dark;
                            return AlertDialog(
                              backgroundColor: isDarkAlert ? const Color(0xff1e1e1e) : Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              title: Text("Erro", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: isDarkAlert ? Colors.white : Colors.black87)),
                              content: Text("Não foi possível cadastrar o evento no banco de dados.", style: TextStyle(color: isDarkAlert ? Colors.white70 : Colors.black54)),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text("OK", style: TextStyle(color: isDarkAlert ? Colors.tealAccent : Colors.black)),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    }
                  },
                  child: Text(
                    "Salvar",
                    style: TextStyle(
                      color: accentColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteEvent(int id) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final bool isDarkAlert = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDarkAlert ? const Color(0xff1e1e1e) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("Excluir Evento?", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: isDarkAlert ? Colors.white : Colors.black87)),
          content: Text("Deseja apagar este evento permanentemente do calendário?", style: TextStyle(color: isDarkAlert ? Colors.white70 : Colors.black54)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Cancelar", style: TextStyle(color: isDarkAlert ? Colors.white60 : Colors.black54)),
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
      bool success = await db.deleteEvent(id, userId);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Evento excluído com sucesso.")),
          );
        }
        _loadEvents();
      } else {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) {
              final bool isDarkAlert = Theme.of(context).brightness == Brightness.dark;
              return AlertDialog(
                backgroundColor: isDarkAlert ? const Color(0xff1e1e1e) : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: Text("Erro", style: TextStyle(color: isDarkAlert ? Colors.white : Colors.black87)),
                content: Text("Não foi possível excluir o evento do banco de dados.", style: TextStyle(color: isDarkAlert ? Colors.white70 : Colors.black54)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("OK", style: TextStyle(color: isDarkAlert ? Colors.tealAccent : Colors.black87)),
                  ),
                ],
              );
            },
          );
        }
      }
    }
  }

  Map<String, String> _parseEventText(String text) {
    if (text.contains("|")) {
      List<String> parts = text.split("|");
      return {"title": parts[0], "description": parts[1]};
    }
    return {"title": text, "description": ""};
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
    final Color contrastColor = accentColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;

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
          "Calendário de Eventos",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: isDark ? Colors.tealAccent : Colors.black))
          : _events.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 60, color: isDark ? Colors.white30 : Colors.black26),
                      const SizedBox(height: 16),
                      Text(
                        "Nenhum evento cadastrado.",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: isDark ? Colors.white60 : Colors.black45,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Botao(
                        texto: "Criar Evento",
                        funcao: _addEvent,
                        cor: accentColor,
                        corTexto: contrastColor,
                        width: 180,
                      )
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _events.length,
                  itemBuilder: (context, index) {
                    final ev = _events[index];
                    final parse = _parseEventText(ev["tipo"] ?? "");
                    final String title = parse["title"]!;
                    final String description = parse["description"]!;
                    final String dateStr = ev["data"] ?? "";
                    
                    // Format date to local standard DD/MM/YYYY
                    String formattedDate = dateStr;
                    try {
                      List<String> parts = dateStr.split("-");
                      if (parts.length == 3) {
                        formattedDate = "${parts[2]}/${parts[1]}/${parts[0]}";
                      }
                    } catch (_) {}

                    Color cardColor = accentColor;
                    String? evHex = ev["cor"];
                    if (evHex != null && evHex.isNotEmpty) {
                      try {
                        cardColor = Color(int.parse(evHex));
                      } catch (_) {}
                    }

                    return Card(
                      color: isDark ? const Color(0xff1e1e1e) : Colors.white,
                      elevation: 1.5,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: cardColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.event_note, color: cardColor),
                        ),
                        title: Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (description.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                description,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  color: isDark ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            ],
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 12, color: isDark ? Colors.white30 : Colors.black38),
                                const SizedBox(width: 4),
                                Text(
                                  formattedDate,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 11,
                                    color: isDark ? Colors.white30 : Colors.black38,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                          onPressed: () => _deleteEvent(ev["id_evento"]),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: _events.isNotEmpty
          ? FloatingActionButton(
              onPressed: _addEvent,
              backgroundColor: accentColor,
              child: Icon(Icons.add, color: contrastColor),
            )
          : null,
    );
  }
}
