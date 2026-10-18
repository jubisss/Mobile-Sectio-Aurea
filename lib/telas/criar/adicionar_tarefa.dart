import 'package:flutter/material.dart';
import 'package:sectio_aurea/services/banco_dados.dart';
import 'package:sectio_aurea/widgets/botao.dart';
import 'package:sectio_aurea/widgets/campo_texto.dart';

class AddTaskScreen extends StatefulWidget {
  final Map<String, dynamic> u;

  const AddTaskScreen({super.key, required this.u});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String _difficulty = "Média"; // default
  DateTime? _selectedDate;

  void _saveTask() async {
    String title = _titleController.text.trim();
    if (title.isEmpty) {
      _showAlert("Campo Obrigatório", "O título da tarefa é obrigatório!");
      return;
    }

    String deadlineStr = "";
    if (_selectedDate != null) {
      deadlineStr = "${_selectedDate!.year.toString().padLeft(4, '0')}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";
    }

    final db = DatabaseService();
    int userId = widget.u["id_usuario"] ?? 1;

    int taskId = await db.createTarefa(title, _difficulty, deadlineStr, userId);

    if (taskId > 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tarefa cadastrada com sucesso!")),
        );
        Navigator.pop(context);
      }
    } else {
      _showAlert("Erro de Conexão", "Não foi possível cadastrar a tarefa no banco de dados.");
    }
  }

  void _showAlert(String title, String msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        content: Text(msg, style: const TextStyle(fontFamily: 'Poppins')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
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
      setState(() {
        _selectedDate = picked;
      });
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
          "Nova Tarefa",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Criar Nova Atividade",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 18),
            // Title input
            CampoTexto(
              labelText: "Título da Tarefa *",
              controller: _titleController,
              obscureText: false,
              helperText: "Obrigatório",
              width: double.infinity,
            ),
            const SizedBox(height: 8),
            // Description input
            CampoTexto(
              labelText: "Descrição / Detalhes (Opcional)",
              controller: _descController,
              obscureText: false,
              width: double.infinity,
            ),
            const SizedBox(height: 20),

            // Date Selection
            Text(
              "Prazo de Conclusão",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xff1e1e1e) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDate == null
                          ? "Selecionar data"
                          : "${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    Icon(Icons.calendar_today_outlined, size: 18, color: isDark ? Colors.white30 : Colors.black54),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Difficulty Selection
            Text(
              "Dificuldade *",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: ["Fácil", "Média", "Difícil"].map((diff) {
                bool isSel = _difficulty == diff;
                Color btnColor = diff == "Difícil"
                    ? const Color(0xff9f042c)
                    : diff == "Média"
                        ? Colors.orangeAccent
                        : Colors.green;

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _difficulty = diff;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSel ? btnColor : (isDark ? const Color(0xff1e1e1e) : Colors.white),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSel ? Colors.transparent : (isDark ? Colors.white12 : Colors.black12),
                          width: 1.2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          diff,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: isSel ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 48),
            Center(
              child: Botao(
                texto: "Salvar Tarefa",
                funcao: _saveTask,
                cor: accentColor,
                corTexto: isDark ? Colors.black : Colors.white,
                width: 200,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
