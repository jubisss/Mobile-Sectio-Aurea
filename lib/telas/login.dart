import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sectio_aurea/services/banco_dados.dart';
import 'package:sectio_aurea/widgets/botao.dart';
import 'package:sectio_aurea/widgets/campo_texto.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController controllerEmail = TextEditingController();
  final TextEditingController controllerSenha = TextEditingController();
  bool isLoading = false;

  void handleLogin() async {
    String email = controllerEmail.text.trim();
    String password = controllerSenha.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showError("Por favor, preencha todos os campos.");
      return;
    }

    setState(() {
      isLoading = true;
    });

    final db = DatabaseService();
    final user = await db.login(email, password);

    setState(() {
      isLoading = false;
    });

    if (user != null) {
      // Login successful! Check if test has been completed
      // If type_dom is empty or null, they must do the test
      if (user["tipo_dom"] == null || user["tipo_dom"].toString().isEmpty) {
        context.push('/teste', extra: user);
      } else {
        context.push('/home', extra: user);
      }
    } else {
      showError("E-mail ou senha incorretos.");
    }
  }

  void _showEsqueciMinhaSenha() {
    String email = controllerEmail.text.trim();
    final editEmailController = TextEditingController(text: email);
    bool isEditingEmail = email.isEmpty;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final bool isDark = Theme.of(context).brightness == Brightness.dark;
            final Color textColor = isDark ? Colors.white : Colors.black87;

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.lock_reset_rounded, color: Color(0xFFffbd59)),
                  SizedBox(width: 8),
                  Text("Recuperar Senha", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isEditingEmail) ...[
                    const Text(
                      "Deseja enviar o código de verificação para o seguinte e-mail?",
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFffbd59).withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.email_outlined, size: 20, color: Color(0xFFffbd59)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              email,
                              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 13, color: textColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    const Text(
                      "Digite seu e-mail para receber o código de recuperação:",
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    CampoTexto(
                      labelText: "E-mail",
                      controller: editEmailController,
                      obscureText: false,
                      prefixIcon: Icons.email_outlined,
                    ),
                  ],
                ],
              ),
              actions: [
                if (!isEditingEmail) ...[
                  TextButton(
                    onPressed: () {
                      setDialogState(() {
                        isEditingEmail = true;
                      });
                    },
                    child: Text(
                      "Esse não é o meu e-mail",
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: isDark ? Colors.orangeAccent : Colors.orange.shade800),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.tealAccent : Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _dispararRecuperacao(email),
                    child: Text("Enviar Código", style: TextStyle(color: isDark ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ] else ...[
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancelar", style: TextStyle(color: isDark ? Colors.white60 : Colors.black54)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.tealAccent : Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      final novoEmail = editEmailController.text.trim();
                      if (novoEmail.isNotEmpty) {
                        _dispararRecuperacao(novoEmail);
                      }
                    },
                    child: Text("Enviar Código", style: TextStyle(color: isDark ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }

  void _dispararRecuperacao(String email) async {
    Navigator.pop(context);
    setState(() => isLoading = true);

    final code = await DatabaseService().recuperarSenha(email);

    setState(() => isLoading = false);

    if (code != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Código de verificação enviado para $email!"),
          backgroundColor: Colors.green,
        ),
      );
      _showTelaRedefinirSenha(email, code);
    } else {
      if (!mounted) return;
      showError("Erro ao solicitar código de recuperação. Verifique se o e-mail está cadastrado.");
    }
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
                
                setState(() {
                  isLoading = true;
                });
                
                bool ok = await DatabaseService().resetarSenha(email, code, newPass);
                
                setState(() {
                  isLoading = false;
                });
                
                if (ok) {
                  if (!mounted) return;
                  setState(() => isLoading = true);
                  final user = await DatabaseService().login(email, newPass);
                  setState(() => isLoading = false);

                  if (user != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Senha redefinida com sucesso! Você já está conectado(a)."),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 3),
                      ),
                    );
                    if (user["tipo_dom"] == null || user["tipo_dom"].toString().isEmpty) {
                      context.push('/teste', extra: user);
                    } else {
                      context.push('/home', extra: user);
                    }
                    return;
                  }

                  showDialog(
                    context: context,
                    builder: (context) {
                      final bool isDarkAlert = Theme.of(context).brightness == Brightness.dark;
                      return AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: const Text("Sucesso", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                        content: const Text("Sua senha foi redefinida com sucesso! Faça login com a nova senha.", style: TextStyle(fontFamily: 'Poppins')),
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

  void showError(String msg) {
    showDialog(
      context: context,
      builder: (context) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            "Falha no Login",
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
          ),
          content: Text(
            msg,
            style: const TextStyle(fontFamily: 'Poppins'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK", style: TextStyle(color: isDark ? Colors.tealAccent : Colors.black)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xff121212) : const Color(0xfff4f1eb),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xff121212) : const Color(0xfff4f1eb),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(isDark ? "assets/images/logoBranca.png" : "assets/images/LogoPreta.png", width: 28),
            const SizedBox(width: 8),
            Text(
              "Sectio Aurea",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Bem-vindo de volta!",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                "Entre para acessar seus cronogramas e estudos.",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),
              CampoTexto(
                labelText: 'E-mail',
                controller: controllerEmail,
                obscureText: false,
                helperText: 'Digite seu e-mail de acesso',
                prefixIcon: Icons.email_outlined,
              ),
              const SizedBox(height: 8),
              CampoTexto(
                labelText: 'Senha',
                controller: controllerSenha,
                obscureText: true,
                helperText: 'Digite sua senha',
                prefixIcon: Icons.lock_outline,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _showEsqueciMinhaSenha,
                  child: Text(
                    "Esqueci minha senha",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: isDark ? Colors.tealAccent : Colors.black54,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (isLoading)
                CircularProgressIndicator(color: isDark ? Colors.tealAccent : Colors.black)
              else
                Column(
                  children: [
                    Botao(
                      texto: "Entrar",
                      funcao: handleLogin,
                      width: 180,
                    ),
                    const SizedBox(height: 12),
                    Botao(
                      texto: "Voltar",
                      funcao: () {
                        context.push('/');
                      },
                      cor: isDark ? const Color(0xff1e1e1e) : const Color(0xfff4f1eb),
                      corTexto: isDark ? Colors.white70 : Colors.black87,
                      width: 180,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
