import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sectio_aurea/services/database_service.dart';
import 'package:sectio_aurea/widgets/botao.dart';

class StopwatchScreen extends StatefulWidget {
  final Map<String, dynamic> u;
  final String materia;

  const StopwatchScreen({super.key, required this.u, required this.materia});

  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  int _secondsElapsed = 0;
  int _targetMinutes = 60; // target study time in minutes
  bool _isRunning = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
        setState(() {
          _secondsElapsed++;
        });
      });
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _secondsElapsed = 0;
    });
  }

  void _changeTargetTime() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color accentColor = Colors.blueGrey;
    String? colorHex = widget.u["clas_inteli"];
    if (colorHex != null && colorHex.isNotEmpty) {
      try {
        accentColor = Color(int.parse(colorHex));
      } catch (_) {}
    }

    final controller = TextEditingController(text: _targetMinutes.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Definir Meta (Minutos)", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: TextStyle(fontFamily: 'Poppins', color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: "Digite os minutos",
            hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: accentColor)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar", style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontFamily: 'Poppins')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: isDark ? accentColor : Colors.black),
            onPressed: () {
              int? val = int.tryParse(controller.text);
              if (val != null && val > 0) {
                setState(() {
                  _targetMinutes = val;
                });
              }
              Navigator.pop(context);
            },
            child: Text("Salvar", style: TextStyle(color: isDark ? Colors.black : Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _finishSession() async {
    _timer?.cancel();
    if (_secondsElapsed > 0) {
      final db = DatabaseService();
      int userId = widget.u["id_usuario"] ?? 1;
      await db.createTimerEntry(_secondsElapsed, widget.materia, userId);
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }

  String _formatTime() {
    int hours = _secondsElapsed ~/ 3600;
    int minutes = (_secondsElapsed % 3600) ~/ 60;
    int seconds = _secondsElapsed % 60;

    String hrStr = hours > 0 ? "${hours.toString().padLeft(2, '0')}:" : "";
    return "$hrStr${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
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

    double progress = (_secondsElapsed / (_targetMinutes * 60)).clamp(0.0, 1.0);

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
                      if (_secondsElapsed > 0) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: const Text("Finalizar Sessão?", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                            content: const Text("Seu tempo de estudo será gravado nas estatísticas.", style: TextStyle(fontFamily: 'Poppins')),
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
                      const SizedBox(height: 8),
                      // Clickable Target Meta
                      GestureDetector(
                        onTap: _changeTargetTime,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: cardBgColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderCol),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit, size: 12, color: accentColor),
                              const SizedBox(width: 4),
                              Text(
                                "META: $_targetMinutes MIN",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: accentColor,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                "Cronômetro Progressivo de Estudos.",
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
                  // Finish
                  _buildCircleButton(Icons.check, _finishSession, Colors.green),
                ],
              ),
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
