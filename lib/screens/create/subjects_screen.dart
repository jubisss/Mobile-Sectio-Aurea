import 'package:flutter/material.dart';
import 'package:sectio_aurea/services/database_service.dart';
import 'package:sectio_aurea/widgets/botao.dart';
import 'package:sectio_aurea/widgets/campo_texto.dart';

class SubjectsScreen extends StatefulWidget {
  final Map<String, dynamic> u;

  const SubjectsScreen({super.key, required this.u});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  List<Map<String, dynamic>> _subjects = [];
  Map<String, int> _subjectTimes = {}; // maps subject name to total seconds studied
  bool _isLoading = true;

  final List<String> _subjectColors = [
    "0xffffbd59", // Yellow
    "0xff9f042c", // Red
    "0xff00bf63", // Green
    "0xff5170ff", // Blue
    "0xffff5f00", // Orange
    "0xff8a03d2", // Purple
    "0xffd203a4", // Pink
    "0xff3b5998", // Dark Blue
    "0xff9b59b6", // Light Purple
    "0xffe67e22", // Light Orange
  ];

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

    // Fetch subjects
    List<Map<String, dynamic>> mats = await db.getMaterias(userId);

    // Fetch chronometer entries to calculate studied times
    List<Map<String, dynamic>> timerEntries = await db.getTimerEntries(userId);
    Map<String, int> times = {};
    for (var entry in timerEntries) {
      String desc = entry["descricao"] ?? "Estudo Geral";
      int duration = entry["tempo_cronometro"] ?? 0;
      times[desc] = (times[desc] ?? 0) + duration;
    }

    if (mounted) {
      setState(() {
        _subjects = mats;
        _subjectTimes = times;
        _isLoading = false;
      });
    }
  }

  void _addSubject() {
    final titleController = TextEditingController();
    String selectedHex = _subjectColors.first;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final bool isDarkDlg = Theme.of(context).brightness == Brightness.dark;
            Color accentColor = Colors.blueGrey;
            String? colorHex = widget.u["clas_inteli"];
            if (colorHex != null && colorHex.isNotEmpty) {
              try {
                accentColor = Color(int.parse(colorHex));
              } catch (_) {}
            }

            return AlertDialog(
              backgroundColor: isDarkDlg ? const Color(0xff1e1e1e) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(
                "Nova Matéria",
                style: TextStyle(
                  fontFamily: 'Poppins', 
                  fontWeight: FontWeight.bold, 
                  fontSize: 16,
                  color: isDarkDlg ? Colors.white : Colors.black87,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CampoTexto(
                      labelText: "Nome da Disciplina",
                      controller: titleController,
                      obscureText: false,
                      width: double.infinity,
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Cor de Fundo",
                        style: TextStyle(
                          fontFamily: 'Poppins', 
                          fontWeight: FontWeight.bold, 
                          fontSize: 12,
                          color: isDarkDlg ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Grid of colors
                    SizedBox(
                      height: 85,
                      width: double.maxFinite,
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: _subjectColors.length,
                        itemBuilder: (context, index) {
                          String hex = _subjectColors[index];
                          Color color = Color(int.parse(hex));
                          bool isSel = selectedHex == hex;

                          return GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                selectedHex = hex;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSel 
                                      ? (isDarkDlg ? Colors.tealAccent : Colors.black87) 
                                      : (isDarkDlg ? Colors.transparent : Colors.white),
                                  width: isSel ? 2.5 : 1.5,
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
                    String name = titleController.text.trim();
                    if (name.isNotEmpty) {
                      final db = DatabaseService();
                      int userId = widget.u["id_usuario"] ?? 1;
                      int matId = await db.createMateria(name, selectedHex, userId);
                      if (matId > 0) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Matéria cadastrada com sucesso!")),
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
                                  "Não foi possível cadastrar a matéria no banco de dados.",
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
                    "Criar", 
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

  void _deleteSubject(int id, String name) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final bool isDarkAlert = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDarkAlert ? const Color(0xff1e1e1e) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            "Excluir Matéria?", 
            style: TextStyle(
              fontFamily: 'Poppins', 
              fontWeight: FontWeight.bold,
              color: isDarkAlert ? Colors.white : Colors.black87
            )
          ),
          content: Text(
            "Deseja apagar '$name'? As aulas vinculadas a ela também podem ser afetadas.",
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
              child: const Text("Excluir", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final db = DatabaseService();
      int userId = widget.u["id_usuario"] ?? 1;
      await db.deleteMateria(id, userId);
      _loadData();
    }
  }

  void _showSubjectDetail(Map<String, dynamic> m) {
    String name = m["nome"];
    int seconds = _subjectTimes[name] ?? 0;
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    Color matColor = Color(int.parse(m["cor"] ?? "0xff5170ff"));

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final bool isDarkDlg = Theme.of(context).brightness == Brightness.dark;
        Color accentColor = Colors.blueGrey;
        String? colorHex = widget.u["clas_inteli"];
        if (colorHex != null && colorHex.isNotEmpty) {
          try {
            accentColor = Color(int.parse(colorHex));
          } catch (_) {}
        }

        return Container(
          decoration: BoxDecoration(
            color: isDarkDlg ? const Color(0xff1e1e1e) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: isDarkDlg ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),
              // Subject icon & name
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: matColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(color: matColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      name,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDarkDlg ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                "Tempo total estudado para esta matéria:",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: isDarkDlg ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                hours > 0 ? "$hours h e $minutes min" : "$minutes minutos",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: matColor,
                ),
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text("Excluir Matéria", style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.pop(context);
                      _deleteSubject(m["id_materia"], name);
                    },
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkDlg ? accentColor : Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Fechar", 
                      style: TextStyle(
                        color: isDarkDlg ? (accentColor.computeLuminance() > 0.5 ? Colors.black : Colors.white) : Colors.white, 
                        fontFamily: 'Poppins', 
                        fontWeight: FontWeight.bold
                      )
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
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
          "Matérias",
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
              child: _subjects.isEmpty
                  ? Center(
                      child: Text(
                        "Sem disciplinas cadastradas.\nToque no botão abaixo para adicionar!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: isDark ? Colors.white30 : Colors.black38,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _subjects.length,
                      padding: const EdgeInsets.only(top: 10, bottom: 80),
                      itemBuilder: (context, index) {
                        final m = _subjects[index];
                        Color matColor = Color(int.parse(m["cor"] ?? "0xff5170ff"));

                        // Study statistics
                        int sec = _subjectTimes[m["nome"]] ?? 0;
                        int min = sec ~/ 60;

                        final bool isCardLight = matColor.computeLuminance() > 0.5;
                        final Color cardTextColor = isCardLight ? Colors.black87 : Colors.white;
                        final Color cardSubtextColor = isCardLight ? Colors.black54 : Colors.white70;

                        return Card(
                          color: matColor,
                          elevation: 3,
                          shadowColor: matColor.withOpacity(0.3),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          child: InkWell(
                            onTap: () => _showSubjectDetail(m),
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 22.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          m["nome"],
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                            color: cardTextColor,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Tempo estudado: $min min",
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 11,
                                            color: cardSubtextColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: cardSubtextColor,
                                    size: 16,
                                  ),
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
        onPressed: _addSubject,
        child: Icon(Icons.add, color: contrastColor, size: 28),
      ),
    );
  }
}
