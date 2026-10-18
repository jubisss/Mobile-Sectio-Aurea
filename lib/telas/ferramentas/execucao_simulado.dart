import 'dart:async';
import 'package:flutter/material.dart';

class SimuladoRunnerScreen extends StatefulWidget {
  final Map<String, dynamic> u;
  final String materia;
  final String numQuestions;
  final String timePerQuestion;
  final String modo;
  final List<Map<String, dynamic>> customQuestions;

  const SimuladoRunnerScreen({
    super.key,
    required this.u,
    required this.materia,
    required this.numQuestions,
    required this.timePerQuestion,
    required this.modo,
    required this.customQuestions,
  });

  @override
  State<SimuladoRunnerScreen> createState() => _SimuladoRunnerScreenState();
}

class _SimuladoRunnerScreenState extends State<SimuladoRunnerScreen> {
  int _currentIndex = 0;
  final Map<int, String> _selectedAnswers = {};
  final Set<int> _revealedAnswers = {};
  bool _isFinished = false;
  int _score = 0;

  // Timer
  Timer? _timer;
  int _secondsRemaining = 60;

  late List<Map<String, dynamic>> _questions;

  @override
  void initState() {
    super.initState();
    _prepareQuestions();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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

  void _prepareQuestions() {
    if (widget.customQuestions.isNotEmpty) {
      _questions = widget.customQuestions.map((q) {
        List<String> opts = [];
        if (q["options"] != null && (q["options"] as List).isNotEmpty) {
          opts = List<String>.from(q["options"]);
        } else {
          opts = [
            (q["answer"] ?? q["correctAnswer"] ?? "Resposta A").toString(),
            "Opção B",
          ];
        }
        String correct = (q["correctAnswer"] ?? q["answer"] ?? (opts.isNotEmpty ? opts.first : "")).toString();
        return {
          "question": q["question"] ?? "Pergunta",
          "correctAnswer": correct,
          "answer": correct,
          "options": opts,
        };
      }).toList();
    } else {
      _questions = [
        {
          "question": "Qual é a principal função da mitocôndria na célula?",
          "correctAnswer": "Produção de ATP (Respiração celular)",
          "answer": "Produção de ATP (Respiração celular)",
          "options": [
            "Produção de ATP (Respiração celular)",
            "Síntese de proteínas",
            "Digestão celular",
            "Armazenamento de água",
          ]..shuffle(),
        },
        {
          "question": "Qual é a fórmula química da água?",
          "correctAnswer": "H2O",
          "answer": "H2O",
          "options": ["H2O", "CO2", "NaCl", "O2"]..shuffle(),
        },
        {
          "question": "Quem escreveu a obra 'Dom Casmurro'?",
          "correctAnswer": "Machado de Assis",
          "answer": "Machado de Assis",
          "options": ["Machado de Assis", "Jose de Alencar", "Monteiro Lobato", "Clarice Lispector"]..shuffle(),
        },
      ];
    }

    int limit = int.tryParse(widget.numQuestions) ?? _questions.length;
    if (limit < _questions.length) {
      _questions = _questions.sublist(0, limit);
    }
  }

  void _startTimer() {
    int perQMin = 1;
    if (widget.timePerQuestion.contains("2")) perQMin = 2;
    if (widget.timePerQuestion.contains("3")) perQMin = 3;
    _secondsRemaining = perQMin * 60;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _nextQuestion();
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _startTimer();
    } else {
      _finishSimulado();
    }
  }

  void _finishSimulado() {
    _timer?.cancel();
    int correct = 0;
    for (int i = 0; i < _questions.length; i++) {
      String expected = (_questions[i]["correctAnswer"] ?? _questions[i]["answer"] ?? "").toString().trim();
      if (_selectedAnswers[i]?.trim() == expected) {
        correct++;
      }
    }
    setState(() {
      _score = correct;
      _isFinished = true;
    });
  }

  String _formatTimer(int sec) {
    int m = sec ~/ 60;
    int s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = _getPrimaryColor();
    final Color pageBg = isDark ? const Color(0xff121212) : const Color(0xfff4f1eb);
    final Color cardBg = isDark ? const Color(0xff1e1e1e) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black87;

    if (_isFinished) {
      double percent = (_score / _questions.length) * 100;
      return Scaffold(
        backgroundColor: pageBg,
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: const Text("Resultado do Simulado", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.white)),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  percent >= 60 ? Icons.check_circle_outline : Icons.highlight_off,
                  size: 80,
                  color: percent >= 60 ? const Color(0xFF22c55e) : Colors.redAccent,
                ),
                const SizedBox(height: 16),
                Text(
                  "Simulado Concluído!",
                  style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 22, color: textColor),
                ),
                const SizedBox(height: 8),
                Text(
                  "Você acertou $_score de ${_questions.length} questões (${percent.toStringAsFixed(0)}%)",
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text("Voltar", style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentQ = _questions[_currentIndex];
    final List<String> options = List<String>.from(currentQ["options"]);

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Questão ${_currentIndex + 1} de ${_questions.length}",
          style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                child: Text(_formatTimer(_secondsRemaining), style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Matéria: ${widget.materia}",
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.bold, color: primaryColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentQ["question"],
                    style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 15, color: textColor),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text("Selecione a resposta correta:", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 10),

            // Options List
            Column(
              children: options.map((opt) {
                final String correct = (currentQ["correctAnswer"] ?? currentQ["answer"] ?? "").toString().trim();
                bool isSelected = _selectedAnswers[_currentIndex]?.trim() == opt.trim();
                bool isTreino = widget.modo == "Treino";
                bool isAnswered = _selectedAnswers[_currentIndex] != null;
                bool isCorrectAnswer = opt.trim() == correct;
                bool isRevealed = _revealedAnswers.contains(_currentIndex);

                Color optBg = isSelected ? primaryColor.withValues(alpha: 0.15) : cardBg;
                Color optBorder = isSelected ? primaryColor : (isDark ? Colors.white12 : Colors.grey.shade300);
                IconData optIcon = isSelected ? Icons.radio_button_checked : Icons.radio_button_off;
                Color iconColor = isSelected ? primaryColor : Colors.grey;

                if (isTreino && isAnswered) {
                  if (isSelected) {
                    if (isCorrectAnswer) {
                      optBg = Colors.green.withValues(alpha: 0.15);
                      optBorder = Colors.green;
                      optIcon = Icons.check_circle;
                      iconColor = Colors.green;
                    } else {
                      optBg = Colors.redAccent.withValues(alpha: 0.15);
                      optBorder = Colors.redAccent;
                      optIcon = Icons.cancel;
                      iconColor = Colors.redAccent;
                    }
                  } else if (isRevealed && isCorrectAnswer) {
                    optBg = Colors.green.withValues(alpha: 0.15);
                    optBorder = Colors.green;
                    optIcon = Icons.check_circle_outline;
                    iconColor = Colors.green;
                  }
                }

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedAnswers[_currentIndex] = opt;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: optBg,
                      border: Border.all(color: optBorder, width: isSelected || (isTreino && isRevealed && isCorrectAnswer) ? 2 : 1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          optIcon,
                          color: iconColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            opt,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            // Feedback in Treino mode
            if (widget.modo == "Treino" && _selectedAnswers[_currentIndex] != null) ...[
              const SizedBox(height: 10),
              Builder(
                builder: (context) {
                  final String correct = (currentQ["correctAnswer"] ?? currentQ["answer"] ?? "").toString().trim();
                  final bool acertou = _selectedAnswers[_currentIndex]?.trim() == correct;

                  if (acertou) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 18),
                          SizedBox(width: 8),
                          Text("Você acertou esta questão! 🎉", style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                    );
                  } else if (!_revealedAnswers.contains(_currentIndex)) {
                    return Center(
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _revealedAnswers.add(_currentIndex);
                          });
                        },
                        icon: const Icon(Icons.visibility_outlined, size: 18, color: Colors.blueAccent),
                        label: const Text(
                          "Deseja ver a resposta correta?",
                          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueAccent),
                        ),
                      ),
                    );
                  } else {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Resposta correta: $correct",
                              style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ],

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedAnswers[_currentIndex] == null ? null : _nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  _currentIndex == _questions.length - 1 ? "Finalizar Simulado" : "Próxima Questão",
                  style: const TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
