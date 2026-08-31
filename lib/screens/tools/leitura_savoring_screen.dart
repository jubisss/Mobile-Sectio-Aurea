import 'dart:async';
import 'package:flutter/material.dart';

class LeituraSavoringScreen extends StatefulWidget {
  final Map<String, dynamic> u;

  const LeituraSavoringScreen({super.key, required this.u});

  @override
  State<LeituraSavoringScreen> createState() => _LeituraSavoringScreenState();
}

class _LeituraSavoringScreenState extends State<LeituraSavoringScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textController = TextEditingController();

  String _selectedMinutes = "2 minutos";
  final List<String> _timeOptions = ["1 minuto", "2 minutos", "3 minutos", "5 minutos"];

  // Guided Reading Active Mode
  bool _isReadingMode = false;
  List<String> _sections = [];
  int _currentSectionIndex = 0;
  int _remainingSeconds = 0;
  Timer? _timer;
  final TextEditingController _reflectionController = TextEditingController();

  @override
  void dispose() {
    _timer?.cancel();
    _titleController.dispose();
    _textController.dispose();
    _reflectionController.dispose();
    super.dispose();
  }

  void _startGuidedReading() {
    String fullText = _textController.text.trim();
    if (fullText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cole ou digite um texto para iniciar a leitura!")),
      );
      return;
    }

    // Split text by double newlines (\n\n) or single newlines
    List<String> rawParts = fullText.split('\n\n');
    List<String> cleanParts = rawParts.where((p) => p.trim().isNotEmpty).toList();

    if (cleanParts.isEmpty) {
      cleanParts = [fullText];
    }

    int mins = int.tryParse(_selectedMinutes.split(' ')[0]) ?? 2;

    setState(() {
      _sections = cleanParts;
      _currentSectionIndex = 0;
      _isReadingMode = true;
      _remainingSeconds = mins * 60;
    });

    _startSectionTimer();
  }

  void _startSectionTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  void _nextSection() {
    _timer?.cancel();
    if (_currentSectionIndex < _sections.length - 1) {
      int mins = int.tryParse(_selectedMinutes.split(' ')[0]) ?? 2;
      setState(() {
        _currentSectionIndex++;
        _remainingSeconds = mins * 60;
        _reflectionController.clear();
      });
      _startSectionTimer();
    } else {
      // Finished all sections
      setState(() {
        _isReadingMode = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Parabéns! Leitura Savoring concluída com sucesso!")),
      );
    }
  }

  String _formatTimer(int sec) {
    int m = sec ~/ 60;
    int s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Color _getPrimaryColor() {
    String? hex = widget.u["clas_inteli"];
    if (hex != null && hex.isNotEmpty) {
      try {
        return Color(int.parse(hex));
      } catch (_) {}
    }
    return const Color(0xFF9f042c);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color themeColor = _getPrimaryColor(); // Cor Intrapessoal
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
          onPressed: () {
            if (_isReadingMode) {
              setState(() => _isReadingMode = false);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          "Leitura Savoring",
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
        child: _isReadingMode ? _buildGuidedReadingView(themeColor, cardBg, textColor, isDark) : _buildSetupView(themeColor, cardBg, textColor, isDark),
      ),
    );
  }

  Widget _buildSetupView(Color themeColor, Color cardBg, Color textColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card Principal (idêntico ao web)
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.menu_book, color: themeColor, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    "Leitura Savoring",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                "Leia com calma, reflita e anote suas ideias",
                style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // Título da Leitura
              const Text("📚 Título da Leitura", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: "Ex: Capítulo 3 - Biologia Celular",
                  hintStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey),
                  filled: true,
                  fillColor: isDark ? const Color(0xff2a2a2a) : const Color(0xfff9f9f9),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: textColor),
              ),

              const SizedBox(height: 16),

              // Texto para leitura
              const Text("📝 Texto para leitura (cole aqui)", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: _textController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: "Cole o texto que deseja estudar...",
                  hintStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey),
                  filled: true,
                  fillColor: isDark ? const Color(0xff2a2a2a) : const Color(0xfff9f9f9),
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: textColor),
              ),

              const SizedBox(height: 12),

              // Dica verde do Web
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xff182b24) : const Color(0xFFf0fdf4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? Colors.green.withValues(alpha: 0.3) : const Color(0xFFbbf7d0)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Color(0xFF16a34a), size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Dica: Separe os trechos com uma linha em branco (pressione Enter duas vezes). Cada trecho será lido separadamente com pausa para reflexão.",
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Color(0xFF166534)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Tempo de leitura por trecho (Dropdown)
              const Text("⏱ Tempo de leitura por trecho", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xff2a2a2a) : const Color(0xfff9f9f9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedMinutes,
                    isExpanded: true,
                    dropdownColor: cardBg,
                    items: _timeOptions.map((opt) {
                      return DropdownMenuItem<String>(
                        value: opt,
                        child: Text(opt, style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: textColor)),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedMinutes = v);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _startGuidedReading,
                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                  label: const Text("Iniciar Leitura", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGuidedReadingView(Color themeColor, Color cardBg, Color textColor, bool isDark) {
    String currentText = _sections[_currentSectionIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status de Progresso
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Trecho ${_currentSectionIndex + 1} de ${_sections.length}",
              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 14, color: themeColor),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: themeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(Icons.timer, size: 16, color: themeColor),
                  const SizedBox(width: 4),
                  Text(
                    _formatTimer(_remainingSeconds),
                    style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 13, color: themeColor),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Card do Trecho Atual
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: themeColor.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Leia atentamente e reflita:",
                style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white60 : Colors.black54),
              ),
              const SizedBox(height: 10),
              Text(
                currentText,
                style: TextStyle(fontFamily: 'Poppins', fontSize: 14, height: 1.6, color: textColor),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Campo de Reflexão do Trecho
        Text("Anotação / Reflexão sobre este trecho:", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 13, color: textColor)),
        const SizedBox(height: 6),
        TextField(
          controller: _reflectionController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: "O que você entendeu deste parágrafo?",
            hintStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey),
            filled: true,
            fillColor: cardBg,
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          ),
          style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: textColor),
        ),

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _nextSection,
            icon: Icon(_currentSectionIndex < _sections.length - 1 ? Icons.arrow_forward : Icons.check_circle, color: Colors.white),
            label: Text(
              _currentSectionIndex < _sections.length - 1 ? "Próximo Trecho" : "Finalizar Leitura",
              style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }
}
