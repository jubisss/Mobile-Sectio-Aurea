import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sectio_aurea/services/banco_dados.dart';
import 'package:sectio_aurea/widgets/botao.dart';
import 'package:sectio_aurea/widgets/dialogo_planos.dart';

class PomodoroScreen extends StatefulWidget {
  final Map<String, dynamic> u;
  final String materia;

  const PomodoroScreen({super.key, required this.u, required this.materia});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  int studyDuration = 25 * 60; // 25 minutes
  int breakDuration = 5 * 60;  // 5 minutes

  late int _secondsRemaining = studyDuration;
  bool _isStudyPhase = true;
  bool _isRunning = false;
  Timer? _timer;
  int _totalSecondsStudied = 0;
  int _completedStudyBlocks = 0;

  late String _currentMateria;
  final TextEditingController _temaController = TextEditingController();
  List<Map<String, dynamic>> _userSubjects = [];

  @override
  void initState() {
    super.initState();
    _currentMateria = widget.materia.isNotEmpty ? widget.materia : "Estudo Geral";
    _loadUserSubjects();
  }

  Future<void> _loadUserSubjects() async {
    int userId = widget.u["id_usuario"] ?? 1;
    List<Map<String, dynamic>> subs = await DatabaseService().getMaterias(userId);
    if (mounted) {
      setState(() {
        _userSubjects = subs;
        if (_currentMateria.isEmpty) {
          _currentMateria = "Estudo Geral";
        }
      });
    }
  }

  void _showSelectMateriaModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Selecione o Foco do Estudo", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Escolha uma matéria cadastrada ou selecione Estudo Geral:", style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: _currentMateria.isNotEmpty ? _currentMateria : "Estudo Geral",
                isExpanded: true,
                items: [
                  const DropdownMenuItem<String>(
                    value: "Estudo Geral",
                    child: Text("Estudo Geral", style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                  ..._userSubjects.map((s) {
                    String name = s["nome"].toString();
                    return DropdownMenuItem<String>(value: name, child: Text(name, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)));
                  }),
                ],
                onChanged: (v) {
                  if (v != null) {
                    setModalState(() => _currentMateria = v);
                    setState(() => _currentMateria = v);
                  }
                },
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (_currentMateria.isEmpty) {
                  setState(() => _currentMateria = "Estudo Geral");
                }
                Navigator.pop(context);
              },
              child: const Text("Confirmar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _temaController.dispose();
    super.dispose();
  }

  void _toggleTimer() {
    if (_currentMateria.isEmpty) {
      _showSelectMateriaModal();
      return;
    }
    if (_isRunning) {
      _timer?.cancel();
      setState(() {
        _isRunning = false;
      });
    } else {
      setState(() {
        _isRunning = true;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_secondsRemaining > 0) {
          setState(() {
            _secondsRemaining--;
            if (_isStudyPhase) {
              _totalSecondsStudied++;
            }
          });
        } else {
          _timer?.cancel();
          _switchPhase();
        }
      });
    }
  }

  void _switchPhase() {
    setState(() {
      if (_isStudyPhase) {
        _completedStudyBlocks++;
      }
      _isStudyPhase = !_isStudyPhase;
      if (_isStudyPhase) {
        _secondsRemaining = studyDuration;
      } else {
        if (_completedStudyBlocks > 0 && _completedStudyBlocks % 4 == 0) {
          _secondsRemaining = 15 * 60; // Long break after 4 study blocks
        } else {
          _secondsRemaining = breakDuration; // Standard 5-minute break
        }
      }
      _isRunning = false;
    });
    _showPhaseAlert();
  }

  void _showPhaseAlert() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    bool isLongBreak = !_isStudyPhase && (_completedStudyBlocks > 0 && _completedStudyBlocks % 4 == 0);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          _isStudyPhase ? "Hora de Focar!" : "Hora de Descansar!",
          style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
        content: Text(
          _isStudyPhase
              ? "Seu intervalo acabou. Vamos começar mais uma sessão de estudos para ${widget.materia}?"
              : isLongBreak
                  ? "Parabéns por concluir 4 blocos de estudo! Tire um descanso longo de 15 minutos."
                  : "Parabéns por concluir esta sessão! Tire 5 minutos para relaxar.",
          style: const TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _toggleTimer();
            },
            child: Text(
              "Começar",
              style: TextStyle(
                color: isDark ? Colors.tealAccent : Colors.black,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _secondsRemaining = _isStudyPhase ? studyDuration : breakDuration;
    });
  }

  void _skipBlock() {
    _timer?.cancel();
    _switchPhase();
  }

  void _finishSession() async {
    _timer?.cancel();
    if (_totalSecondsStudied > 0) {
      final db = DatabaseService();
      int userId = widget.u["id_usuario"] ?? 1;
      int? matId;
      for (var s in _userSubjects) {
        if (s["nome"] == _currentMateria) {
          matId = int.tryParse(s["id_materia"].toString());
          break;
        }
      }
      String desc = _currentMateria.isNotEmpty ? _currentMateria : "Estudo Geral";
      await db.createTimerEntry(_totalSecondsStudied, desc, userId, matId);
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _showPomodoroSettings() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    String plano = widget.u["plano"]?.toString().toLowerCase() ?? "gratuito";
    bool isPaid = plano == "básico" || plano == "basico" || plano == "pro";
    
    Color accentColor = Colors.blueGrey;
    String? colorHex = widget.u["clas_inteli"];
    if (colorHex != null && colorHex.isNotEmpty) {
      try {
        accentColor = Color(int.parse(colorHex));
      } catch (_) {}
    }
    
    if (!isPaid) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Recurso Premium", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
          content: const Text(
            "A edição do tempo do Pomodoro está disponível apenas nos planos Básico e Pro. Conheça nossos planos para personalizar seus blocos de foco!",
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Agora Não", style: TextStyle(color: isDark ? Colors.white60 : Colors.black54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff00bf63),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(context);
                mostrarDialogoPlanos(context, widget.u, onPlanUpdated: (updatedUser) {
                  setState(() {
                    widget.u["plano"] = updatedUser["plano"];
                  });
                });
              },
              child: const Text("Ver Planos", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
            ),
          ],
        ),
      );
      return;
    }
    
    final studyController = TextEditingController(text: (studyDuration ~/ 60).toString());
    final breakController = TextEditingController(text: (breakDuration ~/ 60).toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Configurar Pomodoro", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: studyController,
              keyboardType: TextInputType.number,
              style: TextStyle(fontFamily: 'Poppins', color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                labelText: "Tempo de Estudo (minutos)",
                labelStyle: TextStyle(fontFamily: 'Poppins', color: isDark ? Colors.white60 : Colors.black54),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: accentColor)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: breakController,
              keyboardType: TextInputType.number,
              style: TextStyle(fontFamily: 'Poppins', color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                labelText: "Tempo de Descanso Curto (minutos)",
                labelStyle: TextStyle(fontFamily: 'Poppins', color: isDark ? Colors.white60 : Colors.black54),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: accentColor)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar", style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontFamily: 'Poppins')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? accentColor : Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              int? newStudy = int.tryParse(studyController.text.trim());
              int? newBreak = int.tryParse(breakController.text.trim());
              
              if (newStudy != null && newStudy > 0 && newBreak != null && newBreak > 0) {
                setState(() {
                  studyDuration = newStudy * 60;
                  breakDuration = newBreak * 60;
                  _secondsRemaining = _isStudyPhase ? studyDuration : breakDuration;
                  _isRunning = false;
                  _timer?.cancel();
                });
                Navigator.pop(context);
              }
            },
            child: Text("Salvar", style: TextStyle(color: isDark ? Colors.black : Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String _formatTime() {
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor = isDark ? const Color(0xff121212) : const Color(0xfff4f1eb);
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color subtextColor = isDark ? Colors.white60 : Colors.black54;
    final Color iconColor = isDark ? Colors.white70 : Colors.black87;
    final Color dotUncheckedColor = isDark ? Colors.white24 : Colors.black26;
    final Color cycleTextColor = isDark ? Colors.white38 : Colors.black45;

    Color accentColor = Colors.blueGrey;
    String? colorHex = widget.u["clas_inteli"];
    if (colorHex != null && colorHex.isNotEmpty) {
      try {
        accentColor = Color(int.parse(colorHex));
      } catch (_) {}
    }

    int currentPhaseDuration = _isStudyPhase 
        ? studyDuration 
        : ((_completedStudyBlocks > 0 && _completedStudyBlocks % 4 == 0) ? 15 * 60 : breakDuration);
    double progress = _secondsRemaining / currentPhaseDuration;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: iconColor),
                    onPressed: () {
                      // Prompt before exiting
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          title: const Text("Sair da Sessão?", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                          content: const Text("Seu progresso atual de estudos será salvo.", style: TextStyle(fontFamily: 'Poppins')),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("Cancelar", style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontFamily: 'Poppins')),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: accentColor),
                              onPressed: () {
                                Navigator.pop(context); // close dialog
                                _finishSession();
                              },
                              child: const Text("Salvar e Sair", style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Text(
                    widget.materia,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.settings, color: iconColor),
                    onPressed: _showPomodoroSettings,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Subject Dropdown & Optional Tema Field
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xff1e1e1e) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text("Matéria *: ", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 12, color: textColor)),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _currentMateria.isNotEmpty ? _currentMateria : "Estudo Geral",
                              isExpanded: true,
                              dropdownColor: isDark ? const Color(0xff1e1e1e) : Colors.white,
                              hint: const Text("Selecione a matéria"),
                              items: [
                                DropdownMenuItem<String>(
                                  value: "Estudo Geral",
                                  child: Text("Estudo Geral", style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
                                ),
                                ..._userSubjects.where((s) => s["nome"].toString() != "Estudo Geral").map((s) {
                                  String name = s["nome"].toString();
                                  return DropdownMenuItem<String>(value: name, child: Text(name, style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: textColor)));
                                }),
                              ],
                              onChanged: (v) {
                                if (v != null) setState(() => _currentMateria = v);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _temaController,
                      decoration: InputDecoration(
                        hintText: "Tema do Estudo (opcional, ex: Capítulo 3)",
                        hintStyle: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: subtextColor),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                        filled: true,
                        fillColor: isDark ? const Color(0xff2a2a2a) : const Color(0xfff5f5f5),
                      ),
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: textColor),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Timer Display
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 250,
                    height: 250,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 10,
                      valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                      backgroundColor: isDark ? Colors.white12 : Colors.black12,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isStudyPhase ? "FOCO" : "DESCANSO",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                "Total estudado nesta sessão: ${(_totalSecondsStudied ~/ 60)} min",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: subtextColor,
                ),
              ),
              const SizedBox(height: 12),
              // Dots representing 4-pomodoro cycle progress
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  bool isCompleted = false;
                  int currentCycleBlock = _completedStudyBlocks % 4;
                  if (_completedStudyBlocks > 0) {
                    if (currentCycleBlock == 0) {
                      isCompleted = true;
                    } else {
                      isCompleted = index < currentCycleBlock;
                    }
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: Icon(
                       isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                      size: 18,
                      color: isCompleted ? accentColor : dotUncheckedColor,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 6),
              Text(
                "Ciclo Pomodoro: ${_completedStudyBlocks % 4}/4 blocos",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: cycleTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const Spacer(),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Reset button
                  _buildCircleButton(Icons.refresh, _resetTimer, isDark ? Colors.white30 : Colors.black38),
                  const SizedBox(width: 20),
                  // Play/Pause button
                  _buildCircleButton(
                    _isRunning ? Icons.pause : Icons.play_arrow,
                    _toggleTimer,
                    accentColor,
                    isLarge: true,
                  ),
                  const SizedBox(width: 20),
                  // Skip button
                  _buildCircleButton(Icons.skip_next, _skipBlock, isDark ? Colors.white30 : Colors.black38),
                ],
              ),
              const SizedBox(height: 48),

              Botao(
                texto: "Concluir Sessão",
                funcao: _finishSession,
                cor: isDark ? accentColor : Colors.black,
                corTexto: isDark ? Colors.black : const Color(0xfff4f1eb),
                width: 200,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap, Color color, {bool isLarge = false}) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: color,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: EdgeInsets.all(isLarge ? 20.0 : 12.0),
            child: Icon(
              icon,
              color: Colors.white,
              size: isLarge ? 32 : 24,
            ),
          ),
        ),
      ),
    );
  }
}
