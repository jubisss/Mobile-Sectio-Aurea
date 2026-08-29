import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sectio_aurea/services/database_service.dart';
import 'package:sectio_aurea/widgets/botao.dart';

class CountdownScreen extends StatefulWidget {
  final Map<String, dynamic> u;
  final String materia;

  const CountdownScreen({super.key, required this.u, required this.materia});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  int _targetMinutes = 30; // default 30 min
  int _secondsRemaining = 30 * 60;
  bool _isRunning = false;
  bool _hasStarted = false;
  Timer? _timer;
  int _totalSecondsStudied = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _hasStarted = true;
      _secondsRemaining = _targetMinutes * 60;
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
          _totalSecondsStudied++;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _isRunning = false;
        });
        _showFinishedAlert();
      }
    });
  }

  void _toggleTimer() {
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
            _totalSecondsStudied++;
          });
        } else {
          _timer?.cancel();
          setState(() {
            _isRunning = false;
          });
          _showFinishedAlert();
        }
      });
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _hasStarted = false;
      _secondsRemaining = _targetMinutes * 60;
    });
  }

  void _showFinishedAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Tempo Esgotado!", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        content: Text("Parabéns! Você concluiu a sua meta de $_targetMinutes minutos de estudos!"),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _finishSession();
            },
            child: const Text("Salvar e Concluir", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _finishSession() async {
    _timer?.cancel();
    if (_totalSecondsStudied > 0) {
      final db = DatabaseService();
      int userId = widget.u["id_usuario"] ?? 1;
      await db.createTimerEntry(_totalSecondsStudied, widget.materia, userId);
    }
    if (mounted) {
      Navigator.pop(context);
    }
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
    final Color cardBgColor = isDark ? const Color(0xff1e1e1e) : Colors.white;
    final Color borderCol = isDark ? Colors.white12 : Colors.black12;

    Color accentColor = Colors.blueGrey;
    String? colorHex = widget.u["clas_inteli"];
    if (colorHex != null && colorHex.isNotEmpty) {
      try {
        accentColor = Color(int.parse(colorHex));
      } catch (_) {}
    }

    double progress = _hasStarted
        ? _secondsRemaining / (_targetMinutes * 60)
        : 1.0;

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
                      if (_hasStarted) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: const Text("Abandonar Timer?", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                            content: const Text("O tempo de estudo realizado até agora será salvo.", style: TextStyle(fontFamily: 'Poppins')),
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
                                child: Text(
                                  "Salvar e Sair",
                                  style: TextStyle(
                                    color: isDark ? Colors.black : Colors.white,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        Navigator.pop(context);
                      }
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
                  const SizedBox(width: 48), // spacer
                ],
              ),
              const Spacer(),

              if (!_hasStarted) ...[
                Text(
                  "Defina sua meta de tempo:",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 24),
                // Grid of options
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [10, 15, 30, 45, 60, 90, 120].map((min) {
                    bool isSelected = _targetMinutes == min;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _targetMinutes = min;
                          _secondsRemaining = min * 60;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? accentColor : cardBgColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isSelected ? Colors.transparent : borderCol),
                        ),
                        child: Text(
                          "$min min",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            color: isSelected 
                                ? (isDark ? Colors.black : Colors.white) 
                                : textColor,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const Spacer(),
                Botao(
                  texto: "Iniciar Meta",
                  funcao: _startTimer,
                  cor: accentColor,
                  corTexto: isDark ? Colors.black : const Color(0xfff4f1eb),
                  width: 200,
                  height: 52,
                ),
              ] else ...[
                // Active Display
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
                          "META: $_targetMinutes MIN",
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
                  "Progresso atual de estudo: ${(_totalSecondsStudied ~/ 60)} min",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: subtextColor,
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Reset
                    _buildCircleButton(Icons.refresh, _resetTimer, isDark ? Colors.white30 : Colors.black38),
                    const SizedBox(width: 24),
                    // Play/Pause
                    _buildCircleButton(
                      _isRunning ? Icons.pause : Icons.play_arrow,
                      _toggleTimer,
                      accentColor,
                      isLarge: true,
                    ),
                    const SizedBox(width: 24),
                    // Done
                    _buildCircleButton(Icons.check, _finishSession, Colors.green),
                  ],
                ),
              ],
              const SizedBox(height: 48),
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
