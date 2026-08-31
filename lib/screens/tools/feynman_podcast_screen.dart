import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sectio_aurea/services/tool_storage_service.dart';

class FeynmanPodcastScreen extends StatefulWidget {
  final Map<String, dynamic> u;
  final String title;
  final Color themeColor;

  const FeynmanPodcastScreen({
    super.key,
    required this.u,
    this.title = "Técnica Feynman",
    this.themeColor = const Color(0xFFff5f00),
  });

  @override
  State<FeynmanPodcastScreen> createState() => _FeynmanPodcastScreenState();
}

class _FeynmanPodcastScreenState extends State<FeynmanPodcastScreen> {
  bool _isRecording = false;
  bool _isPaused = false;
  bool _hasPermission = false;
  int _seconds = 0;
  Timer? _timer;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  bool _check1 = false;
  bool _check2 = false;
  bool _check3 = false;
  bool _check4 = false;

  List<Map<String, dynamic>> _savedRecordings = [];

  @override
  void initState() {
    super.initState();
    _loadRecordings();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _getStorageKey() {
    int userId = widget.u["id_usuario"] ?? 1;
    return "PI_GravacoesAudio_User_$userId";
  }

  Future<void> _loadRecordings() async {
    String? raw = await ToolStorageService.getString(_getStorageKey());
    if (raw != null && raw.isNotEmpty) {
      try {
        List<dynamic> list = jsonDecode(raw);
        if (mounted) {
          setState(() {
            _savedRecordings = list.cast<Map<String, dynamic>>();
          });
        }
      } catch (_) {}
    }
  }

  void _requestMicPermission() {
    showDialog(
      context: context,
      builder: (context) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.mic, color: Colors.blueAccent),
              SizedBox(width: 8),
              Text("Permissão de Microfone", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: const Text(
            "O Sectio Aurea precisa de permissão para acessar seu microfone para gravar as explicações áudio.",
            style: TextStyle(fontFamily: 'Poppins', fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Negar", style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontFamily: 'Poppins')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: widget.themeColor),
              onPressed: () {
                setState(() {
                  _hasPermission = true;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Permissão de microfone concedida!"), backgroundColor: Colors.green),
                );
              },
              child: const Text("Permitir", style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _toggleRecording() {
    if (!_hasPermission) {
      _requestMicPermission();
      return;
    }

    if (_isRecording) {
      if (_isPaused) {
        // Resume
        setState(() {
          _isPaused = false;
        });
      } else {
        // Pause
        setState(() {
          _isPaused = true;
        });
      }
    } else {
      // Start recording
      setState(() {
        _isRecording = true;
        _isPaused = false;
        _seconds = 0;
      });
      _startTimer();
    }
  }

  void _stopRecording() {
    _stopTimer();
    setState(() {
      _isRecording = false;
      _isPaused = false;
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!_isPaused) {
        setState(() {
          _seconds++;
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  String _formatTimer(int sec) {
    int m = sec ~/ 60;
    int s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _saveRecording() async {
    String recName = _nameController.text.trim();
    if (recName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Digite um título para a gravação antes de salvar!"), backgroundColor: Colors.orange),
      );
      return;
    }

    String notes = _notesController.text.trim();

    Map<String, dynamic> recObj = {
      "id": DateTime.now().millisecondsSinceEpoch.toString(),
      "title": recName,
      "duration": _formatTimer(_seconds),
      "date": "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
      "notes": notes.isEmpty ? "Nenhuma anotação" : notes,
      "checklist": {
        "palavrasSimples": _check1,
        "analogias": _check2,
        "lacunas": _check3,
        "simplificado": _check4,
      },
    };

    List<Map<String, dynamic>> recordings = List.from(_savedRecordings);
    recordings.insert(0, recObj);

    await ToolStorageService.setString(_getStorageKey(), jsonEncode(recordings));

    if (mounted) {
      setState(() {
        _savedRecordings = recordings;
        _nameController.clear();
        _notesController.clear();
        _seconds = 0;
        _isRecording = false;
        _isPaused = false;
        _check1 = false;
        _check2 = false;
        _check3 = false;
        _check4 = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gravação salva com sucesso no repositório de áudios!"), backgroundColor: Colors.green),
      );
    }
  }

  void _deleteRecording(String id) async {
    List<Map<String, dynamic>> recordings = List.from(_savedRecordings);
    recordings.removeWhere((r) => r["id"] == id);
    await ToolStorageService.setString(_getStorageKey(), jsonEncode(recordings));
    if (mounted) {
      setState(() {
        _savedRecordings = recordings;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = widget.themeColor;
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
        title: Text(
          widget.title,
          style: const TextStyle(
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
            // Title Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Título da Gravação / Conceito *", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 13, color: primaryColor)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: "Ex: Leis de Newton explicadas",
                      hintStyle: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: isDark ? Colors.white38 : Colors.black38),
                      filled: true,
                      fillColor: isDark ? const Color(0xff2a2a2a) : const Color(0xfff9f9f9),
                      contentPadding: const EdgeInsets.all(12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: textColor),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Recording Controls Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  // Timer
                  Text(
                    _formatTimer(_seconds),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: _isRecording ? Colors.redAccent : textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isRecording
                        ? (_isPaused ? "Gravação Pausada" : "Gravando explicação...")
                        : "Pronto para gravar",
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey),
                  ),

                  const SizedBox(height: 20),

                  // Responsive Action Buttons
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 10,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _toggleRecording,
                        icon: Icon(
                          _isRecording ? (_isPaused ? Icons.play_arrow : Icons.pause) : Icons.mic,
                          color: Colors.white,
                        ),
                        label: Text(
                          _isRecording ? (_isPaused ? "Continuar" : "Pausar") : "Iniciar Gravação",
                          style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isRecording ? Colors.orangeAccent : primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),

                      if (_isRecording)
                        ElevatedButton.icon(
                          onPressed: _stopRecording,
                          icon: const Icon(Icons.stop, color: Colors.white),
                          label: const Text("Parar", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Self assessment checklist
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xff2a2a2a) : const Color(0xFFf0fdf4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFbbf7d0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.assignment_turned_in_outlined, size: 16, color: Color(0xFF166534)),
                            SizedBox(width: 6),
                            Text("Autoavaliação:", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF166534))),
                          ],
                        ),
                        CheckboxListTile(
                          dense: true,
                          title: const Text("Expliquei com palavras simples?", style: TextStyle(fontFamily: 'Poppins', fontSize: 12)),
                          value: _check1,
                          activeColor: primaryColor,
                          onChanged: (v) => setState(() => _check1 = v ?? false),
                        ),
                        CheckboxListTile(
                          dense: true,
                          title: const Text("Usei analogias ou exemplos?", style: TextStyle(fontFamily: 'Poppins', fontSize: 12)),
                          value: _check2,
                          activeColor: primaryColor,
                          onChanged: (v) => setState(() => _check2 = v ?? false),
                        ),
                        CheckboxListTile(
                          dense: true,
                          title: const Text("Identifiquei lacunas no entendimento?", style: TextStyle(fontFamily: 'Poppins', fontSize: 12)),
                          value: _check3,
                          activeColor: primaryColor,
                          onChanged: (v) => setState(() => _check3 = v ?? false),
                        ),
                        CheckboxListTile(
                          dense: true,
                          title: const Text("Consegui simplificar o conceito?", style: TextStyle(fontFamily: 'Poppins', fontSize: 12)),
                          value: _check4,
                          activeColor: primaryColor,
                          onChanged: (v) => setState(() => _check4 = v ?? false),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    "Anotações do que melhorar:",
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Enquanto ouve, anote os pontos que precisa melhorar...",
                      hintStyle: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: isDark ? Colors.white38 : Colors.black38),
                      filled: true,
                      fillColor: isDark ? const Color(0xff2a2a2a) : const Color(0xfff9f9f9),
                      contentPadding: const EdgeInsets.all(12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: textColor),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveRecording,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10b981),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text("Salvar Gravação", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              "🎙️ Minhas Gravações Salvas",
              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
            ),
            const SizedBox(height: 10),

            _savedRecordings.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
                    child: const Center(
                      child: Text("Nenhuma gravação salva ainda. Grave e salve um áudio acima!", style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey)),
                    ),
                  )
                : Column(
                    children: _savedRecordings.map((rec) {
                      String title = rec["title"] ?? "Gravação";
                      String durationStr = rec["duration"] ?? "00:00";
                      String notes = rec["notes"] ?? "";

                      return Card(
                        color: cardBg,
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: primaryColor,
                            child: const Icon(Icons.mic, color: Colors.white, size: 20),
                          ),
                          title: Text(title, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 13, color: textColor)),
                          subtitle: Text("Duração: $durationStr | Salvo em ${rec['date'] ?? ''}", style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.grey)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.play_circle_fill, color: primaryColor, size: 28),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      title: Text(title, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 15)),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.graphic_eq, size: 60, color: primaryColor),
                                          const SizedBox(height: 10),
                                          Text("Reproduzindo áudio ($durationStr)...", style: const TextStyle(fontFamily: 'Poppins', fontSize: 12)),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Fechar")),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () => _deleteRecording(rec["id"]),
                              ),
                            ],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Anotações de Melhoria:", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 12, color: primaryColor)),
                                  const SizedBox(height: 4),
                                  Text(notes, style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: textColor)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }
}
