import 'package:flutter/material.dart';
import 'package:sectio_aurea/services/banco_dados.dart';

class ScheduleScreen extends StatefulWidget {
  final Map<String, dynamic> u;

  const ScheduleScreen({super.key, required this.u});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _scheduleItems = [];
  List<Map<String, dynamic>> _subjects = [];
  bool _isLoading = true;

  late TabController _tabController;
  final List<String> _weekdays = [
    "Segunda",
    "Terça",
    "Quarta",
    "Quinta",
    "Sexta",
    "Sábado",
    "Domingo"
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _weekdays.length, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    int userId = widget.u["id_usuario"] ?? 1;
    final db = DatabaseService();

    List<Map<String, dynamic>> items = await db.getCronograma(userId);
    List<Map<String, dynamic>> mats = await db.getMaterias(userId);

    if (mounted) {
      setState(() {
        _scheduleItems = items;
        _subjects = mats;
        _isLoading = false;
      });
    }
  }

  void _addScheduleItem() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color accentColor = Colors.blueGrey;
    String? colorHex = widget.u["clas_inteli"];
    if (colorHex != null && colorHex.isNotEmpty) {
      try {
        accentColor = Color(int.parse(colorHex));
      } catch (_) {}
    }

    if (_subjects.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          final bool isDarkAlert = Theme.of(context).brightness == Brightness.dark;
          return AlertDialog(
            backgroundColor: isDarkAlert ? const Color(0xff1e1e1e) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              "Aviso", 
              style: TextStyle(
                fontFamily: 'Poppins', 
                fontWeight: FontWeight.bold, 
                color: isDarkAlert ? Colors.white : Colors.black87
              )
            ),
            content: Text(
              "Por favor, crie ao menos uma Matéria antes de agendar horários.", 
              style: TextStyle(
                fontFamily: 'Poppins', 
                color: isDarkAlert ? Colors.white70 : Colors.black54
              )
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK", style: TextStyle(color: isDarkAlert ? Colors.tealAccent : Colors.black)),
              ),
            ],
          );
        },
      );
      return;
    }

    int? selectedMateriaId = _subjects.first["id_materia"];
    String selectedDay = _weekdays[_tabController.index];
    TimeOfDay startTime = const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 9, minute: 30);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final bool isDarkDlg = Theme.of(context).brightness == Brightness.dark;

            String formatTime(TimeOfDay t) {
              return "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";
            }

            Future<void> selectTime(bool isStart) async {
              TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: isStart ? startTime : endTime,
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: isDarkDlg ? Colors.tealAccent : Colors.black87,
                        onPrimary: isDarkDlg ? Colors.black : Colors.white,
                        surface: isDarkDlg ? const Color(0xff1e1e1e) : Colors.white,
                        onSurface: isDarkDlg ? Colors.white : Colors.black87,
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(foregroundColor: isDarkDlg ? Colors.tealAccent : Colors.black87),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setDialogState(() {
                  if (isStart) {
                    startTime = picked;
                  } else {
                    endTime = picked;
                  }
                });
              }
            }

            return AlertDialog(
              backgroundColor: isDarkDlg ? const Color(0xff1e1e1e) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(
                "Adicionar Horário", 
                style: TextStyle(
                  fontFamily: 'Poppins', 
                  fontWeight: FontWeight.bold, 
                  fontSize: 16,
                  color: isDarkDlg ? Colors.white : Colors.black87
                )
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Subject Dropdown
                    DropdownButtonFormField<int>(
                      value: selectedMateriaId,
                      dropdownColor: isDarkDlg ? const Color(0xff2d2d2d) : Colors.white,
                      style: TextStyle(fontFamily: 'Poppins', color: isDarkDlg ? Colors.white : Colors.black87, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: "Matéria",
                        labelStyle: TextStyle(color: isDarkDlg ? Colors.white60 : Colors.black54),
                      ),
                      items: _subjects.map((m) {
                        return DropdownMenuItem<int>(
                          value: m["id_materia"],
                          child: Text(m["nome"]),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setDialogState(() {
                          selectedMateriaId = val;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    // Weekday Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedDay,
                      dropdownColor: isDarkDlg ? const Color(0xff2d2d2d) : Colors.white,
                      style: TextStyle(fontFamily: 'Poppins', color: isDarkDlg ? Colors.white : Colors.black87, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: "Dia da Semana",
                        labelStyle: TextStyle(color: isDarkDlg ? Colors.white60 : Colors.black54),
                      ),
                      items: _weekdays.map((day) {
                        return DropdownMenuItem<String>(
                          value: day,
                          child: Text(day),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setDialogState(() {
                          selectedDay = val ?? selectedDay;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    // Time Pickers
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => selectTime(true),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Início", style: TextStyle(fontSize: 10, color: isDarkDlg ? Colors.white60 : Colors.black54)),
                              Text(
                                formatTime(startTime), 
                                style: TextStyle(
                                  fontSize: 16, 
                                  fontWeight: FontWeight.bold, 
                                  color: isDarkDlg ? Colors.tealAccent : Colors.black87
                                )
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward, color: isDarkDlg ? Colors.white30 : Colors.black26),
                        TextButton(
                          onPressed: () => selectTime(false),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Término", style: TextStyle(fontSize: 10, color: isDarkDlg ? Colors.white60 : Colors.black54)),
                              Text(
                                formatTime(endTime), 
                                style: TextStyle(
                                  fontSize: 16, 
                                  fontWeight: FontWeight.bold, 
                                  color: isDarkDlg ? Colors.tealAccent : Colors.black87
                                )
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancelar", style: TextStyle(color: isDarkDlg ? Colors.white60 : Colors.black54)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkDlg ? accentColor : Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    if (selectedMateriaId != null) {
                      final db = DatabaseService();
                      int userId = widget.u["id_usuario"] ?? 1;
                      int schedId = await db.createCronograma(
                        selectedMateriaId!,
                        selectedDay,
                        formatTime(startTime),
                        formatTime(endTime),
                        userId,
                      );
                      if (schedId > 0) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Horário agendado com sucesso!")),
                          );
                          Navigator.pop(context);
                        }
                        _loadData();
                      } else {
                        if (context.mounted) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              final bool isDarkAlert = Theme.of(context).brightness == Brightness.dark;
                              return AlertDialog(
                                backgroundColor: isDarkAlert ? const Color(0xff1e1e1e) : Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                title: Text(
                                  "Erro", 
                                  style: TextStyle(
                                    fontFamily: 'Poppins', 
                                    fontWeight: FontWeight.bold,
                                    color: isDarkAlert ? Colors.white : Colors.black87
                                  )
                                ),
                                content: Text(
                                  "Não foi possível agendar o horário no banco de dados.",
                                  style: TextStyle(color: isDarkAlert ? Colors.white70 : Colors.black54)
                                ),
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
                    }
                  },
                  child: Text(
                    "Agendar", 
                    style: TextStyle(
                      color: accentColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold
                    )
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteScheduleItem(int id) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final bool isDarkAlert = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDarkAlert ? const Color(0xff1e1e1e) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            "Remover Horário?", 
            style: TextStyle(
              fontFamily: 'Poppins', 
              fontWeight: FontWeight.bold,
              color: isDarkAlert ? Colors.white : Colors.black87
            )
          ),
          content: Text(
            "Deseja apagar este horário do seu cronograma?",
            style: TextStyle(color: isDarkAlert ? Colors.white70 : Colors.black54)
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Cancelar", style: TextStyle(color: isDarkAlert ? Colors.white60 : Colors.black54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Remover", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final db = DatabaseService();
      int userId = widget.u["id_usuario"] ?? 1;
      await db.deleteCronograma(id, userId);
      _loadData();
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
          "Cronograma Semanal",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: isDark ? Colors.tealAccent : accentColor,
          unselectedLabelColor: isDark ? Colors.white38 : Colors.black38,
          indicatorColor: isDark ? Colors.tealAccent : accentColor,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 12),
          tabs: _weekdays.map((day) => Tab(text: day)).toList(),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: isDark ? Colors.tealAccent : Colors.black))
          : TabBarView(
              controller: _tabController,
              children: _weekdays.map((day) {
                // Filter schedule items for this specific day
                final itemsForDay = _scheduleItems.where((item) => item["dia_semana"] == day).toList();

                // Sort items by start time
                itemsForDay.sort((a, b) => (a["hora_inicio"] ?? "").compareTo(b["hora_inicio"] ?? ""));

                if (itemsForDay.isEmpty) {
                  return Center(
                    child: Text(
                      "Nenhuma aula agendada para esta $day.\nToque no botão + para adicionar!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: itemsForDay.length,
                  itemBuilder: (context, index) {
                    final item = itemsForDay[index];

                    // Find subject color
                    Color matColor = Colors.grey;
                    try {
                      final mat = _subjects.firstWhere((m) => m["id_materia"] == item["id_materia"]);
                      matColor = Color(int.parse(mat["cor"] ?? "0xff5170ff"));
                    } catch (_) {}

                    return Card(
                      color: isDark ? const Color(0xff1e1e1e) : Colors.white,
                      elevation: 1.5,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            // Subject Color indicator bubble
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(color: matColor, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item["nome_materia"] ?? "Matéria",
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time, size: 12, color: isDark ? Colors.white30 : Colors.black38),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${item["hora_inicio"]} - ${item["hora_final"]}",
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 12,
                                          color: isDark ? Colors.white70 : Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline, color: isDark ? Colors.white30 : Colors.black38),
                              onPressed: () => _deleteScheduleItem(item["id_cronograma"]),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: accentColor,
        elevation: 6,
        onPressed: _addScheduleItem,
        child: Icon(Icons.add, color: contrastColor, size: 28),
      ),
    );
  }
}
