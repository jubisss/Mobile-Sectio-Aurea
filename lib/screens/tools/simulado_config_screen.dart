import 'package:flutter/material.dart';
import 'package:sectio_aurea/services/database_service.dart';
import 'package:sectio_aurea/screens/tools/simulado_runner_screen.dart';

class SimuladoConfigScreen extends StatefulWidget {
  final Map<String, dynamic> u;

  const SimuladoConfigScreen({super.key, required this.u});

  @override
  State<SimuladoConfigScreen> createState() => _SimuladoConfigScreenState();
}

class _SimuladoConfigScreenState extends State<SimuladoConfigScreen> {
  List<Map<String, dynamic>> _subjects = [];
  final List<Map<String, dynamic>> _customQuestions = [];

  String _selectedSubject = "Todas as matérias";
  String _selectedNumQuestions = "5";
  String _selectedTimePerQuestion = "1 minuto";
  String _selectedMode = "Treino"; // Treino vs Prova

  @override
  void initState() {
    super.initState();
    _loadSubjects();
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

  Future<void> _loadSubjects() async {
    int userId = widget.u["id_usuario"] ?? 1;
    List<Map<String, dynamic>> mats = await DatabaseService().getMaterias(userId);
    if (mounted) {
      setState(() {
        _subjects = mats;
      });
    }
  }

  void _showCriarPerguntaDialog() {
    final questionCtrl = TextEditingController();
    final List<TextEditingController> optionCtrls = [
      TextEditingController(),
      TextEditingController(),
    ];
    int selectedCorrectIndex = 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Criar Pergunta para o Simulado", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: questionCtrl,
                  decoration: InputDecoration(
                    hintText: "Digite a pergunta",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                ),
                const SizedBox(height: 12),
                const Text("Alternativas (Mínimo 2, Máximo 5):", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 6),

                ...List.generate(optionCtrls.length, (idx) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Radio<int>(
                          value: idx,
                          groupValue: selectedCorrectIndex,
                          onChanged: (v) {
                            if (v != null) setDialogState(() => selectedCorrectIndex = v);
                          },
                        ),
                        Expanded(
                          child: TextField(
                            controller: optionCtrls[idx],
                            decoration: InputDecoration(
                              hintText: "Opção ${String.fromCharCode(65 + idx)} ${idx == selectedCorrectIndex ? '(Correta)' : ''}",
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                            style: const TextStyle(fontFamily: 'Poppins', fontSize: 12),
                          ),
                        ),
                        if (optionCtrls.length > 2)
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
                            onPressed: () {
                              setDialogState(() {
                                optionCtrls.removeAt(idx);
                                if (selectedCorrectIndex >= optionCtrls.length) {
                                  selectedCorrectIndex = optionCtrls.length - 1;
                                }
                              });
                            },
                          ),
                      ],
                    ),
                  );
                }),

                if (optionCtrls.length < 5)
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        setDialogState(() {
                          optionCtrls.add(TextEditingController());
                        });
                      },
                      icon: Icon(Icons.add_circle_outline, color: _getPrimaryColor(), size: 18),
                      label: Text("Adicionar Alternativa", style: TextStyle(color: _getPrimaryColor(), fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar", style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _getPrimaryColor()),
              onPressed: () {
                String q = questionCtrl.text.trim();
                List<String> options = optionCtrls.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();

                if (q.isNotEmpty && options.length >= 2) {
                  String correctAnswer = optionCtrls[selectedCorrectIndex].text.trim();
                  if (correctAnswer.isEmpty) correctAnswer = options.first;

                  setState(() {
                    _customQuestions.add({
                      "question": q,
                      "answer": correctAnswer,
                      "options": options,
                    });
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Pergunta com alternativas adicionada com sucesso!")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Preencha a pergunta e no mínimo 2 alternativas!")),
                  );
                }
              },
              child: const Text("Adicionar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _iniciarSimulado() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SimuladoRunnerScreen(
          u: widget.u,
          materia: _selectedSubject,
          numQuestions: _selectedNumQuestions,
          timePerQuestion: _selectedTimePerQuestion,
          modo: _selectedMode,
          customQuestions: _customQuestions,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = _getPrimaryColor();
    final Color pageBg = isDark ? const Color(0xff121212) : const Color(0xfff4f1eb);
    final Color cardBg = isDark ? const Color(0xff1e1e1e) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Configurar Simulado",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seção 1: Criar Perguntas antes do Simulado
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Banco de Questões (${_customQuestions.length})",
                        style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 14, color: textColor),
                      ),
                      ElevatedButton(
                        onPressed: _showCriarPerguntaDialog,
                        style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                        child: const Text("Criar Pergunta", style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  if (_customQuestions.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Column(
                      children: _customQuestions.map((q) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xff2a2a2a) : const Color(0xfff9f9f9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.help_outline, size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(q["question"]!, style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: textColor)),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Seção 2: Configuração do Simulado
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit_note, color: primaryColor, size: 24),
                      const SizedBox(width: 8),
                      Text("Configurações da Prova", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Matéria
                  const Text("Matéria:", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedSubject,
                        isExpanded: true,
                        dropdownColor: cardBg,
                        items: ["Todas as matérias", ..._subjects.map((m) => m["nome"].toString())].map((s) {
                          return DropdownMenuItem<String>(
                            value: s,
                            child: Text(s, style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: textColor)),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _selectedSubject = v);
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Número de questões
                  const Text("Número de questões:", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(
                    children: ["5", "10", "15", "Todas"].map((numQ) {
                      bool isSel = _selectedNumQuestions == numQ;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedNumQuestions = numQ),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSel ? primaryColor : Colors.transparent,
                              border: Border.all(color: isSel ? primaryColor : Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                numQ,
                                style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 12, color: isSel ? Colors.white : textColor),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // Tempo por questão
                  const Text("Tempo por questão:", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedTimePerQuestion,
                        isExpanded: true,
                        dropdownColor: cardBg,
                        items: ["Sem limite", "1 minuto", "2 minutos", "3 minutos"].map((t) {
                          return DropdownMenuItem<String>(
                            value: t,
                            child: Text(t, style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: textColor)),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _selectedTimePerQuestion = v);
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Modo
                  const Text("Modo:", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 6),
                  RadioListTile<String>(
                    dense: true,
                    title: const Text("Treino (feedback imediato)", style: TextStyle(fontFamily: 'Poppins', fontSize: 12)),
                    value: "Treino",
                    groupValue: _selectedMode,
                    activeColor: primaryColor,
                    onChanged: (v) => setState(() => _selectedMode = v!),
                  ),
                  RadioListTile<String>(
                    dense: true,
                    title: const Text("Prova (feedback no final)", style: TextStyle(fontFamily: 'Poppins', fontSize: 12)),
                    value: "Prova",
                    groupValue: _selectedMode,
                    activeColor: primaryColor,
                    onChanged: (v) => setState(() => _selectedMode = v!),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _iniciarSimulado,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text("Iniciar Simulado", style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
