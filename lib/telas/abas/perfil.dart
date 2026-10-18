import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sectio_aurea/widgets/imagem_perfil.dart';
import 'package:sectio_aurea/main.dart';
import 'package:sectio_aurea/telas/descricao_projeto.dart';
import 'package:sectio_aurea/telas/sobre_nos.dart';
import 'package:sectio_aurea/telas/busca.dart';
import 'package:sectio_aurea/services/banco_dados.dart';
import 'package:sectio_aurea/widgets/botao.dart';
import 'package:sectio_aurea/widgets/campo_texto.dart';

class PerfilTab extends StatefulWidget {
  final Map<String, dynamic> u;
  final ValueChanged<Map<String, dynamic>> onUserUpdated;

  const PerfilTab({super.key, required this.u, required this.onUserUpdated});

  @override
  State<PerfilTab> createState() => _PerfilTabState();
}

class _PerfilTabState extends State<PerfilTab> {
  // Statistics data
  int _totalHours = 0;
  int _daysStudied = 0;
  int _maxStreak = 0;
  double _dailyAverage = 0;
  List<Map<String, dynamic>> _timerEntries = [];
  List<Map<String, dynamic>> _subjects = [];

  // Statistics filter
  String _statsFilter = "Diário"; // Diário, Semanal, Mensal, Dia da Semana

  @override
  void initState() {
    super.initState();
    _loadStatsData();
  }

  DateTime? _parseEntryDate(dynamic raw) {
    if (raw == null) return null;
    String str = raw.toString().trim().replaceFirst(' ', 'T');
    return DateTime.tryParse(str);
  }

  Future<void> _loadStatsData() async {
    int userId = widget.u["id_usuario"] ?? 1;
    final db = DatabaseService();

    List<Map<String, dynamic>> entries = await db.getTimerEntries(userId);
    List<Map<String, dynamic>> mats = await db.getMaterias(userId);

    // Calculate metrics
    int totalSec = entries.fold(0, (sum, item) => sum + (item["tempo_cronometro"] as int));
    int hours = totalSec ~/ 3600;

    // Real unique days calculation
    final Set<String> uniqueDays = {};
    for (var entry in entries) {
      final dt = _parseEntryDate(entry["created_at"]);
      if (dt != null) {
        uniqueDays.add("${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}");
      }
    }
    int days = uniqueDays.length;

    // Real max streak calculation
    List<DateTime> sortedDates = uniqueDays.map((d) => DateTime.parse(d)).toList()..sort();
    int maxStreak = 0;
    int currentStreak = 0;
    DateTime? lastDate;

    for (var d in sortedDates) {
      if (lastDate == null) {
        currentStreak = 1;
      } else {
        final diff = d.difference(lastDate).inDays;
        if (diff == 1) {
          currentStreak++;
        } else if (diff > 1) {
          currentStreak = 1;
        }
      }
      if (currentStreak > maxStreak) {
        maxStreak = currentStreak;
      }
      lastDate = d;
    }

    double avg = days > 0 ? (totalSec / 60) / days : 0.0;

    if (mounted) {
      setState(() {
        _timerEntries = entries;
        _subjects = mats;
        _totalHours = hours;
        _daysStudied = days;
        _maxStreak = maxStreak;
        _dailyAverage = avg;
      });
    }
  }

  void _editProfile() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color accentColor = Colors.blueGrey;
    String? colorHex = widget.u["clas_inteli"];
    if (colorHex != null && colorHex.isNotEmpty) {
      try {
        accentColor = Color(int.parse(colorHex));
      } catch (_) {}
    }

    final nameController = TextEditingController(text: widget.u["nome"]);
    String selectedPhoto = widget.u["foto"].toString().isNotEmpty ? widget.u["foto"] : "";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text("Editar Perfil", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Two Circles: Bolinha 1 (Atual) and Bolinha 2 (Editar)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Circle 1: Current Photo
                        Column(
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundColor: widget.u["foto"].toString().isEmpty ? Colors.grey[300] : Colors.white,
                              backgroundImage: widget.u["foto"].toString().isNotEmpty
                                  ? getProfileImageProvider(widget.u["foto"])
                                  : null,
                              child: widget.u["foto"].toString().isEmpty
                                  ? Icon(Icons.person, size: 36, color: Colors.grey[500])
                                  : null,
                            ),
                            const SizedBox(height: 4),
                            Text("Atual", style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: isDark ? Colors.white54 : Colors.black54)),
                          ],
                        ),
                        const SizedBox(width: 24),
                        // Circle 2: Edit/New Photo Selection
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                title: const Text("Editar Foto", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                                content: const Text("Escolha uma opção para sua foto de perfil:", style: TextStyle(fontFamily: 'Poppins')),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      setDialogState(() {
                                        selectedPhoto = ""; // remove
                                      });
                                    },
                                    child: const Text("Remover Foto", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      final picker = ImagePicker();
                                      final image = await picker.pickImage(
                                        source: ImageSource.gallery,
                                        maxWidth: 200,
                                        maxHeight: 200,
                                        imageQuality: 70,
                                      );
                                      if (image != null) {
                                        final bytes = await image.readAsBytes();
                                        final base64String = base64Encode(bytes);
                                        setDialogState(() {
                                          selectedPhoto = 'data:image/png;base64,$base64String'; // base64 data URL
                                        });
                                      }
                                    },
                                    child: const Text("Selecionar Foto", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  CircleAvatar(
                                    radius: 36,
                                    backgroundColor: selectedPhoto.isEmpty ? Colors.grey[300] : Colors.white,
                                    backgroundImage: selectedPhoto.isNotEmpty
                                        ? getProfileImageProvider(selectedPhoto)
                                        : null,
                                    child: selectedPhoto.isEmpty
                                        ? Icon(Icons.person, size: 36, color: Colors.grey[500])
                                        : null,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.black87,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.edit, color: Colors.white, size: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text("Editar/Nova", style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: isDark ? Colors.white54 : Colors.black54)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    CampoTexto(
                      labelText: "Nome",
                      controller: nameController,
                      obscureText: false,
                      width: double.infinity,
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // close profile dialog
                        _showTrocarSenhaDialog(); // open change password
                      },
                      child: Text(
                        "Trocar Senha",
                        style: TextStyle(
                          color: isDark ? Colors.tealAccent : Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancelar",
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.black54,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? accentColor : Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    String name = nameController.text.trim();

                    if (name.isNotEmpty) {
                      final updated = Map<String, dynamic>.from(widget.u);
                      updated["nome"] = name;
                      updated["foto"] = selectedPhoto;

                      await DatabaseService().updateUser(updated);
                      widget.onUserUpdated(updated);
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: Text(
                    "Salvar",
                    style: TextStyle(
                      color: isDark ? Colors.black : Colors.white,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showTrocarSenhaDialog() {
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();
    bool isChanging = false;

    showDialog(
      context: context,
      builder: (context) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        Color accentColor = Colors.blueGrey;
        String? colorHex = widget.u["clas_inteli"];
        if (colorHex != null && colorHex.isNotEmpty) {
          try {
            accentColor = Color(int.parse(colorHex));
          } catch (_) {}
        }
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text("Trocar Senha", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CampoTexto(
                      labelText: "Senha Antiga",
                      controller: oldPassController,
                      obscureText: true,
                      width: double.infinity,
                    ),
                    const SizedBox(height: 8),
                    CampoTexto(
                      labelText: "Nova Senha",
                      controller: newPassController,
                      obscureText: true,
                      width: double.infinity,
                    ),
                    const SizedBox(height: 8),
                    CampoTexto(
                      labelText: "Confirmar Nova Senha",
                      controller: confirmPassController,
                      obscureText: true,
                      width: double.infinity,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context); // close trocar senha
                          _showEsqueciMinhaSenha(); // open esqueci minha senha
                        },
                        child: const Text(
                          "Esqueci minha senha",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: Colors.black54,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancelar", style: TextStyle(color: isDark ? Colors.white60 : Colors.black54)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? accentColor : Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: isChanging ? null : () async {
                    String oldPass = oldPassController.text.trim();
                    String newPass = newPassController.text.trim();
                    String confirmPass = confirmPassController.text.trim();

                    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          final bool isDarkAlert = Theme.of(context).brightness == Brightness.dark;
                          return AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            content: const Text("Por favor, preencha todos os campos.", style: TextStyle(fontFamily: 'Poppins')),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: Text("OK", style: TextStyle(color: isDarkAlert ? Colors.tealAccent : Colors.black, fontWeight: FontWeight.bold))),
                            ],
                          );
                        },
                      );
                      return;
                    }

                    if (newPass != confirmPass) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          final bool isDarkAlert = Theme.of(context).brightness == Brightness.dark;
                          return AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            content: const Text("A nova senha e a confirmação não coincidem.", style: TextStyle(fontFamily: 'Poppins')),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: Text("OK", style: TextStyle(color: isDarkAlert ? Colors.tealAccent : Colors.black, fontWeight: FontWeight.bold))),
                            ],
                          );
                        },
                      );
                      return;
                    }

                    setDialogState(() {
                      isChanging = true;
                    });

                    bool ok = await DatabaseService().trocarSenha(oldPass, newPass);

                    setDialogState(() {
                      isChanging = false;
                    });

                    if (ok) {
                      final updated = Map<String, dynamic>.from(widget.u);
                      updated["senha"] = newPass;
                      widget.onUserUpdated(updated);

                      if (!context.mounted) return;
                      Navigator.pop(context); // close trocar senha dialog
                      showDialog(
                        context: context,
                        builder: (context) {
                          final bool isDarkAlert = Theme.of(context).brightness == Brightness.dark;
                          return AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: const Text("Sucesso", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                            content: const Text("Senha alterada com sucesso!", style: TextStyle(fontFamily: 'Poppins')),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: Text("OK", style: TextStyle(color: isDarkAlert ? Colors.tealAccent : Colors.black, fontWeight: FontWeight.bold))),
                            ],
                          );
                        },
                      );
                    } else {
                      if (!context.mounted) return;
                      showDialog(
                        context: context,
                        builder: (context) {
                          final bool isDarkAlert = Theme.of(context).brightness == Brightness.dark;
                          return AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: const Text("Erro", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                            content: const Text("Senha antiga incorreta. Tente novamente.", style: TextStyle(fontFamily: 'Poppins')),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: Text("OK", style: TextStyle(color: isDarkAlert ? Colors.tealAccent : Colors.black, fontWeight: FontWeight.bold))),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: isChanging
                      ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: isDark ? Colors.black : Colors.white, strokeWidth: 2))
                      : Text("Alterar", style: TextStyle(color: isDark ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEsqueciMinhaSenha() {
    final emailController = TextEditingController(text: widget.u["email"]);
    bool isSending = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final bool isDark = Theme.of(context).brightness == Brightness.dark;
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text("Recuperar Senha", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Enviaremos um e-mail com um código de verificação para redefinir sua senha.",
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  CampoTexto(
                    labelText: "E-mail",
                    controller: emailController,
                    obscureText: false,
                    prefixIcon: Icons.email_outlined,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSending ? null : () => Navigator.pop(context),
                  child: Text("Cancelar", style: TextStyle(color: isDark ? Colors.white60 : Colors.black54)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.tealAccent : Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: isSending
                      ? null
                      : () async {
                          String email = emailController.text.trim();
                          if (email.isEmpty) return;

                          setDialogState(() {
                            isSending = true;
                          });

                          final code = await DatabaseService().recuperarSenha(email);

                          if (!context.mounted) return;
                          Navigator.pop(context); // Close email dialog

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Código enviado para $email! Insira abaixo para redefinir."),
                                backgroundColor: Colors.green,
                              ),
                            );
                            _showTelaRedefinirSenha(email, code ?? '');
                          }
                        },
                  child: isSending
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: isDark ? Colors.black : Colors.white),
                        )
                      : Text("Enviar Código", style: TextStyle(color: isDark ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showTelaRedefinirSenha(String email, String actualCode) {
    final codeController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Redefinir Senha", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Defina sua nova senha para o e-mail: $email",
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: isDark ? Colors.white60 : Colors.black54),
                ),
                const SizedBox(height: 16),
                CampoTexto(
                  labelText: "Código de Verificação",
                  controller: codeController,
                  obscureText: false,
                  helperText: "Insira o código enviado",
                  prefixIcon: Icons.pin_outlined,
                ),
                const SizedBox(height: 8),
                CampoTexto(
                  labelText: "Nova Senha",
                  controller: newPassController,
                  obscureText: true,
                  prefixIcon: Icons.lock_outline,
                ),
                const SizedBox(height: 8),
                CampoTexto(
                  labelText: "Confirmar Nova Senha",
                  controller: confirmPassController,
                  obscureText: true,
                  prefixIcon: Icons.lock_outline,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar", style: TextStyle(color: isDark ? Colors.white60 : Colors.black54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.tealAccent : Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                String code = codeController.text.trim();
                String newPass = newPassController.text.trim();
                String confirmPass = confirmPassController.text.trim();
                
                if (code.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      final bool isDarkAlert = Theme.of(context).brightness == Brightness.dark;
                      return AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        content: const Text("Por favor, preencha todos os campos.", style: TextStyle(fontFamily: 'Poppins')),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: Text("OK", style: TextStyle(color: isDarkAlert ? Colors.tealAccent : Colors.black))),
                        ],
                      );
                    },
                  );
                  return;
                }
                
                if (newPass != confirmPass) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      final bool isDarkAlert = Theme.of(context).brightness == Brightness.dark;
                      return AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        content: const Text("As senhas não coincidem.", style: TextStyle(fontFamily: 'Poppins')),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: Text("OK", style: TextStyle(color: isDarkAlert ? Colors.tealAccent : Colors.black))),
                        ],
                      );
                    },
                  );
                  return;
                }
                
                Navigator.pop(context); // close reset dialog
                
                bool ok = await DatabaseService().resetarSenha(email, code, newPass);
                
                if (ok) {
                  final updated = Map<String, dynamic>.from(widget.u);
                  updated["senha"] = newPass;
                  widget.onUserUpdated(updated);

                  if (!mounted) return;
                  showDialog(
                    context: context,
                    builder: (context) {
                      final bool isDarkAlert = Theme.of(context).brightness == Brightness.dark;
                      return AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: const Text("Sucesso", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                        content: const Text("Sua senha foi redefinida com sucesso!", style: TextStyle(fontFamily: 'Poppins')),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("OK", style: TextStyle(color: isDarkAlert ? Colors.tealAccent : Colors.black, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  if (!mounted) return;
                  showDialog(
                    context: context,
                    builder: (context) {
                      final bool isDarkAlert = Theme.of(context).brightness == Brightness.dark;
                      return AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: const Text("Erro", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                        content: const Text("Código de verificação incorreto ou expirado. Tente novamente.", style: TextStyle(fontFamily: 'Poppins')),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _showTelaRedefinirSenha(email, actualCode);
                            },
                            child: Text("Tentar Novamente", style: TextStyle(color: isDarkAlert ? Colors.tealAccent : Colors.black, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text("Redefinir Senha", style: TextStyle(color: isDark ? Colors.black : Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showStudyMethods() {
    context.push('/metodos', extra: widget.u);
  }

  void _showStatistics() {
    String plano = widget.u["plano"]?.toString().toLowerCase() ?? "gratuito";
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    if (plano == "gratuito") {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Recurso Premium", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
          content: const Text("As Estatísticas estão disponíveis apenas nos planos Básico e Pro. Faça o upgrade nas Configurações do seu perfil.", style: TextStyle(fontFamily: 'Poppins')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK", style: TextStyle(color: isDark ? Colors.tealAccent : Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
      return;
    }



    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xff1e1e1e) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            // Real aggregation per subject according to selected filter
            final now = DateTime.now();
            Map<String, double> aggregated = {};
            for (var entry in _timerEntries) {
              String desc = (entry["descricao"] ?? "Estudo Geral").toString().trim();
              if (desc.isEmpty) desc = "Estudo Geral";
              double seconds = (entry["tempo_cronometro"] as int).toDouble();
              final dt = _parseEntryDate(entry["created_at"]) ?? now;

              bool matches = false;
              if (_statsFilter == "Diário") {
                matches = (dt.year == now.year && dt.month == now.month && dt.day == now.day);
              } else if (_statsFilter == "Semanal") {
                matches = now.difference(dt).inDays <= 7;
              } else if (_statsFilter == "Mensal") {
                matches = (dt.year == now.year && dt.month == now.month);
              } else {
                // "Dia da Semana" ou visão completa de todas as sessões
                matches = true;
              }

              if (matches) {
                aggregated[desc] = (aggregated[desc] ?? 0) + seconds;
              }
            }

            List<double> chartValues = [];
            List<Color> chartColors = [];
            List<Map<String, dynamic>> legend = [];

            aggregated.forEach((subjectName, val) {
              // Find matching subject color
              Color color = Colors.grey;
              try {
                final match = _subjects.firstWhere((m) => m["nome"] == subjectName);
                color = Color(int.parse(match["cor"] ?? "0xff5170ff"));
              } catch (_) {}

              chartValues.add(val);
              chartColors.add(color);
              legend.add({"name": subjectName, "val": val, "color": color});
            });

            double totalVal = chartValues.fold(0, (sum, v) => sum + v);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Minhas Estatísticas",
                    style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black87),
                  ),
                  const SizedBox(height: 20),
                  // Filter selectors
                  Navigator.of(context).mounted ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: ["Diário", "Semanal", "Mensal", "Dia da Semana"].map((filter) {
                        bool isSel = _statsFilter == filter;
                        return GestureDetector(
                          onTap: () {
                            setSheetState(() {
                              _statsFilter = filter;
                            });
                            setState(() {
                              _statsFilter = filter;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSel ? (isDark ? Colors.tealAccent : Colors.black87) : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              filter,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isSel ? (isDark ? Colors.black : Colors.white) : (isDark ? Colors.white60 : Colors.black54),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ) : const SizedBox(),
                  const SizedBox(height: 32),

                  // Pie Chart painting
                  if (totalVal > 0) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(130, 130),
                          painter: PieChartPainter(chartValues, chartColors, isDark),
                        ),
                        const SizedBox(width: 28),
                        // Legend
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: legend.map((item) {
                              double pct = (item["val"] / totalVal) * 100;
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: item["color"],
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "${item["name"]} (${pct.toStringAsFixed(0)}%)",
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Container(
                      height: 100,
                      alignment: Alignment.center,
                      child: Text(
                        "Sem dados de estudos gravados.",
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: isDark ? Colors.white38 : Colors.black38),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  // Dashboard cards grid
                  Row(
                    children: [
                      _buildMetricTile("Total Horas", "$_totalHours h"),
                      const SizedBox(width: 12),
                      _buildMetricTile("Dias Estudados", "$_daysStudied dias"),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildMetricTile("Média Diária", "${_dailyAverage.toStringAsFixed(0)} min"),
                      const SizedBox(width: 12),
                      _buildMetricTile("Maior Sequência", "$_maxStreak dias"),
                    ],
                  ),
                  const SizedBox(height: 36),
                  Botao(
                    texto: "Fechar",
                    funcao: () => Navigator.pop(context),
                    cor: isDark ? Colors.tealAccent : Colors.black,
                    corTexto: isDark ? Colors.black : Colors.white,
                    width: 160,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMetricTile(String label, String value) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(fontFamily: 'Poppins', fontSize: 10, color: isDark ? Colors.white60 : Colors.black54),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            String currentPlan = widget.u['plano'] ?? 'Gratuito';
            final bool isDark = Theme.of(context).brightness == Brightness.dark;

            void _onPlanSelected(String name) {
              if (currentPlan.toLowerCase() == name.toLowerCase()) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    content: Text("Você já possui o plano $name ativo.", style: const TextStyle(fontFamily: 'Poppins')),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("OK", style: TextStyle(color: isDark ? Colors.tealAccent : Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
                return;
              }

              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  title: const Text("Confirmar Assinatura", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                  content: Text("Deseja mesmo assinar o plano $name?", style: const TextStyle(fontFamily: 'Poppins')),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text("Não", style: TextStyle(color: isDark ? Colors.white60 : Colors.black54)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.tealAccent : const Color(0xff00bf63),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx); // Close confirmation

                        final updated = Map<String, dynamic>.from(widget.u);
                        updated["plano"] = name;

                        bool ok = await DatabaseService().updateUser(updated);
                        if (ok) {
                          widget.onUserUpdated(updated);
                          setDialogState(() {
                            currentPlan = name;
                          });

                          if (!context.mounted) return;
                          showDialog(
                            context: context,
                            builder: (c) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              title: const Text("Sucesso!", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                              content: Text("Assinatura realizada com sucesso! Seu plano agora é $name.", style: const TextStyle(fontFamily: 'Poppins')),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(c),
                                  child: Text("OK", style: TextStyle(color: isDark ? Colors.tealAccent : Colors.black, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                        } else {
                          if (!context.mounted) return;
                          showDialog(
                            context: context,
                            builder: (c) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              title: const Text("Erro", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                              content: const Text("Falha ao atualizar plano. Tente novamente.", style: TextStyle(fontFamily: 'Poppins')),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(c),
                                  child: Text("OK", style: TextStyle(color: isDark ? Colors.tealAccent : Colors.black, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      child: Text("Sim", style: TextStyle(color: isDark ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text(
                "Configurações",
                style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dark Mode Switch
                      SwitchListTile(
                        title: const Text(
                          "Modo Escuro",
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        secondary: Icon(
                          ThemeManager.themeMode.value == ThemeMode.dark 
                              ? Icons.dark_mode 
                              : Icons.light_mode,
                          size: 20,
                        ),
                        value: ThemeManager.themeMode.value == ThemeMode.dark,
                        activeColor: const Color(0xff00bf63),
                        onChanged: (bool value) {
                          setDialogState(() {
                            ThemeManager.themeMode.value = value ? ThemeMode.dark : ThemeMode.light;
                          });
                        },
                      ),
                      const Divider(),
                      const SizedBox(height: 12),
                      const Text(
                        "Planos de Assinatura",
                        style: TextStyle(
                          fontFamily: 'Poppins', 
                          fontWeight: FontWeight.w900, 
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // 1. Gratuito
                      _buildPlanCard(
                        context,
                        "GRATUITO",
                        "R\$ 0",
                        [
                          "Revisão de conteúdos",
                        ],
                        currentPlan.toLowerCase() == 'gratuito',
                        onTap: () => _onPlanSelected("Gratuito"),
                      ),
                      
                      // 2. Basico
                      _buildPlanCard(
                        context,
                        "BÁSICO",
                        "R\$ 19/mês",
                        [
                          "Revisão de conteúdos",
                          "Personalização no guia de estudos",
                          "Edição do tempo pomodoro",
                          "Cronograma inteligente",
                          "Estatísticas mensais e semanais",
                        ],
                        currentPlan.toLowerCase() == 'básico' || currentPlan.toLowerCase() == 'basico',
                        onTap: () => _onPlanSelected("Básico"),
                      ),
                      
                      // 3. Pro
                      _buildPlanCard(
                        context,
                        "PRO",
                        "R\$ 39/mês",
                        [
                          "Revisão de conteúdos",
                          "Personalização no guia de estudos",
                          "Edição do tempo pomodoro",
                          "Cronograma inteligente",
                          "Estatísticas mensais e semanais",
                        ],
                        currentPlan.toLowerCase() == 'pro',
                        onTap: () => _onPlanSelected("Pro"),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("OK", style: TextStyle(color: isDark ? Colors.tealAccent : Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPlanCard(BuildContext context, String name, String price, List<String> features, bool isCurrent, {required VoidCallback onTap}) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardBgColor = isCurrent 
        ? const Color(0xff00bf63).withOpacity(0.08) 
        : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02));
        
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCurrent ? const Color(0xff00bf63) : (isDark ? Colors.white10 : Colors.black12),
            width: isCurrent ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 0.5,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                if (isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xff00bf63),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "Plano Atual",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 9,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              price,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: isCurrent ? const Color(0xff00bf63) : (isDark ? Colors.white : Colors.black87),
              ),
            ),
            const SizedBox(height: 8),
            ...features.map((f) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, size: 12, color: Color(0xff00bf63)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      f,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _handleLogout() {
    context.go('/');
  }

  void _openSearchScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchScreen(u: widget.u)),
    );
  }

  void _openProjectDescScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProjectDescScreen(u: widget.u)),
    );
  }

  void _openAboutUsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AboutUsScreen(u: widget.u)),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color accentColor = Colors.blueGrey;
    String? colorHex = widget.u["clas_inteli"];
    if (colorHex != null && colorHex.isNotEmpty) {
      try {
        accentColor = Color(int.parse(colorHex));
      } catch (_) {}
    }

    String photo = widget.u["foto"]?.toString() ?? "";
    ImageProvider? profileImage = getProfileImageProvider(photo);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          // Large Profile Photo
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: accentColor, width: 3),
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundImage: profileImage,
              backgroundColor: profileImage == null ? Colors.grey[300] : Colors.white,
              child: profileImage == null
                  ? Icon(Icons.person, size: 60, color: Colors.grey[500])
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          // User name
          Text(
            widget.u["nome"] ?? "Usuário",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w900,
              fontSize: 22,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          // User email
          Text(
            widget.u["email"] ?? "",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: isDark ? Colors.white70 : Colors.black45,
            ),
          ),
          const SizedBox(height: 36),

          // Options List
          _buildOptionTile("Editar Perfil", Icons.edit_outlined, _editProfile, accentColor),
          _buildOptionTile("Buscar Itens", Icons.search_outlined, _openSearchScreen, accentColor),
          _buildOptionTile("Métodos de Estudo", Icons.lightbulb_outline, _showStudyMethods, accentColor),
          _buildOptionTile("Estatísticas", Icons.bar_chart_outlined, _showStatistics, accentColor),
          _buildOptionTile("Sobre o Projeto", Icons.description_outlined, _openProjectDescScreen, accentColor),
          _buildOptionTile("Sobre Nós", Icons.info_outline, _openAboutUsScreen, accentColor),
          _buildOptionTile("Configurações", Icons.settings_outlined, _showSettings, accentColor),
          const SizedBox(height: 24),
          _buildOptionTile("Sair da Conta", Icons.logout_outlined, _handleLogout, Colors.redAccent, isDestructive: true),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildOptionTile(String title, IconData icon, VoidCallback onTap, Color color, {bool isDestructive = false}) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardBgColor = isDark ? const Color(0xff1e1e1e) : Colors.white;
    final Color textColor = isDestructive ? Colors.redAccent : (isDark ? Colors.white : Colors.black87);
    final Color arrowColor = isDark ? Colors.white30 : Colors.black26;

    return Card(
      color: cardBgColor,
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: textColor,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 14, color: arrowColor),
      ),
    );
  }
}

// Custom Painter for Pie Chart
class PieChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  final bool isDark;

  PieChartPainter(this.values, this.colors, this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    double total = values.fold(0.0, (sum, v) => sum + v);
    if (total == 0.0) return;

    double startAngle = -3.1415926535897932 / 2; // start from 12 o'clock
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2,
    );

    for (int i = 0; i < values.length; i++) {
      final sweepAngle = (values[i] / total) * 3.1415926535897932 * 2;
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;

      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
      startAngle += sweepAngle;
    }

    // Draw center circle for donut effect
    final centerPaint = Paint()..color = isDark ? const Color(0xff1e1e1e) : Colors.white;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 4, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
