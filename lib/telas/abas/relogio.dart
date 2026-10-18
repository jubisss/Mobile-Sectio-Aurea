import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sectio_aurea/services/banco_dados.dart';
import 'package:sectio_aurea/widgets/botao.dart';
import 'package:sectio_aurea/widgets/organizacao_espaco.dart';

class RelogioTab extends StatefulWidget {
  final Map<String, dynamic> u;

  const RelogioTab({super.key, required this.u});

  @override
  State<RelogioTab> createState() => _RelogioTabState();
}

class _RelogioTabState extends State<RelogioTab> {
  List<Map<String, dynamic>> _subjects = [];
  String? _selectedSubject;
  String _selectedMode = "pomodoro"; // pomodoro, countdown, stopwatch
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    setState(() {
      _isLoading = true;
    });
    int userId = widget.u["id_usuario"] ?? 1;
    final db = DatabaseService();
    List<Map<String, dynamic>> mats = await db.getMaterias(userId);
    if (mounted) {
      setState(() {
        _subjects = mats;
        if (mats.isNotEmpty) {
          _selectedSubject = mats.first["nome"];
        } else {
          _selectedSubject = "Estudo Geral";
        }
        _isLoading = false;
      });
    }
  }

  void _startStudying() {
    final Map<String, dynamic> params = {
      "user": widget.u,
      "materia": _selectedSubject ?? "Estudo Geral",
    };

    if (_selectedMode == "pomodoro") {
      context.push('/timers/pomodoro', extra: params);
    } else if (_selectedMode == "countdown") {
      context.push('/timers/countdown', extra: params);
    } else {
      context.push('/timers/stopwatch', extra: params);
    }
  }

  void _showWorkspaceTutorial() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const WorkspaceTutorialDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.black));
    }

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    Color accentColor = Colors.blueGrey;
    String? colorHex = widget.u["clas_inteli"];
    if (colorHex != null && colorHex.isNotEmpty) {
      try {
        accentColor = Color(int.parse(colorHex));
      } catch (_) {}
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          Text(
            "Foco & Tempo",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w900,
              fontSize: 22,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Text(
            "Selecione o método de estudo ideal para hoje.",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          const SizedBox(height: 32),

          // Dropdown Materia
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xff1e1e1e) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black38 : Colors.black.withOpacity(0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedSubject,
                isExpanded: true,
                dropdownColor: isDark ? const Color(0xff1e1e1e) : Colors.white,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
                icon: Icon(Icons.keyboard_arrow_down, color: isDark ? Colors.white70 : Colors.black54),
                items: [
                  DropdownMenuItem<String>(
                    value: "Estudo Geral",
                    child: Text("Estudo Geral", style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                  ),
                  ..._subjects.map<DropdownMenuItem<String>>((m) {
                    return DropdownMenuItem<String>(
                      value: m["nome"] as String,
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(int.parse(m["cor"] ?? "0xff5170ff")),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(m["nome"] as String, style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                        ],
                      ),
                    );
                  }).toList()
                ],
                onChanged: (val) {
                  setState(() {
                    _selectedSubject = val;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Selector Modes
          Row(
            children: [
              _buildModeCard("pomodoro", Icons.timer, "Pomodoro", "Ciclos de 25 min", accentColor, isDark),
              const SizedBox(width: 12),
              _buildModeCard("countdown", Icons.hourglass_empty, "Temporizador", "Contagem regressiva", accentColor, isDark),
              const SizedBox(width: 12),
              _buildModeCard("stopwatch", Icons.play_arrow, "Cronômetro", "Tempo livre progressivo", accentColor, isDark),
            ],
          ),
          const SizedBox(height: 48),

          // Start Button
          Botao(
            texto: "Ir Estudar",
            funcao: _startStudying,
            cor: accentColor,
            corTexto: isDark ? Colors.black : const Color(0xfff4f1eb),
            width: 200,
            height: 52,
          ),
          const SizedBox(height: 24),

          // Tutorial Button
          TextButton.icon(
            onPressed: _showWorkspaceTutorial,
            icon: Icon(Icons.info_outline, color: accentColor, size: 18),
            label: Text(
              "Dicas de organização de espaço",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard(
      String mode, IconData icon, String title, String subtitle, Color activeColor, bool isDark) {
    bool isSelected = _selectedMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedMode = mode;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : (isDark ? const Color(0xff1e1e1e) : Colors.white),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Colors.transparent : (isDark ? Colors.white12 : Colors.black12),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? activeColor.withOpacity(0.2)
                    : (isDark ? Colors.black54 : Colors.black.withOpacity(0.02)),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
                size: 26,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black87),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 9,
                  color: isSelected ? Colors.white70 : (isDark ? Colors.white30 : Colors.black38),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
