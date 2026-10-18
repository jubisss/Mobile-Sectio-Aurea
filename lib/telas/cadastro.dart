import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sectio_aurea/services/banco_dados.dart';
import 'package:sectio_aurea/widgets/botao.dart';
import 'package:sectio_aurea/widgets/campo_texto.dart';

class Cadastro extends StatefulWidget {
  const Cadastro({super.key});

  @override
  State<Cadastro> createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  final TextEditingController controllerNome = TextEditingController();
  final TextEditingController controllerEmail = TextEditingController();
  final TextEditingController controllerSenha = TextEditingController();
  bool isLoading = false;

  void handleCadastro() async {
    String nome = controllerNome.text.trim();
    String email = controllerEmail.text.trim();
    String password = controllerSenha.text.trim();

    if (nome.isEmpty || email.isEmpty || password.isEmpty) {
      showError("Por favor, preencha todos os campos.");
      return;
    }

    if (!email.contains("@") || !email.contains(".")) {
      showError("Por favor, insira um e-mail válido.");
      return;
    }

    setState(() {
      isLoading = true;
    });

    final db = DatabaseService();
    final code = await db.enviarCodigoCadastro(email);

    setState(() {
      isLoading = false;
    });

    if (code != null) {
      _showDialogVerificacaoCodigo(nome, email, password, code);
    } else {
      showError("Erro ao enviar código de verificação para o e-mail.");
    }
  }

  void _showDialogVerificacaoCodigo(String nome, String email, String password, String expectedCode) {
    final codeController = TextEditingController();
    String currentExpectedCode = expectedCode;
    bool isVerifying = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final bool isDark = Theme.of(context).brightness == Brightness.dark;
            final Color textColor = isDark ? Colors.white : Colors.black87;

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.mark_email_read_outlined, color: Color(0xFF00bf63)),
                  SizedBox(width: 8),
                  Text("Verificar E-mail", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Enviamos um código de verificação de 6 dígitos para:",
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: isDark ? Colors.white70 : Colors.black87),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    email,
                    style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 13, color: textColor),
                  ),
                  const SizedBox(height: 16),
                  CampoTexto(
                    labelText: "Código de Verificação",
                    controller: codeController,
                    obscureText: false,
                    prefixIcon: Icons.security,
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () async {
                        final newCode = await DatabaseService().enviarCodigoCadastro(email);
                        if (newCode != null) {
                          setDialogState(() {
                            currentExpectedCode = newCode;
                          });
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Novo código enviado para seu e-mail!"), backgroundColor: Colors.green),
                            );
                          }
                        }
                      },
                      child: const Text("Reenviar Código", style: TextStyle(fontFamily: 'Poppins', fontSize: 12)),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancelar", style: TextStyle(color: isDark ? Colors.white60 : Colors.black54)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00bf63),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: isVerifying
                      ? null
                      : () async {
                          final inputCode = codeController.text.trim();
                          if (inputCode.isEmpty) return;

                          if (inputCode != currentExpectedCode) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Código incorreto! Tente novamente."), backgroundColor: Colors.redAccent),
                            );
                            return;
                          }

                          setDialogState(() => isVerifying = true);
                          final user = await DatabaseService().register(nome, email, password);
                          setDialogState(() => isVerifying = false);

                          if (context.mounted) {
                            Navigator.pop(context);
                            if (user != null) {
                              irParaTeste(user);
                            } else {
                              showError("E-mail já cadastrado ou falha no servidor.");
                            }
                          }
                        },
                  child: isVerifying
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Confirmar e Criar Conta", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
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
            "Erro no Cadastro",
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
          ),
          content: Text(
            msg,
            style: const TextStyle(fontFamily: 'Poppins'),
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
  }

  void irParaTeste(Map<String, dynamic> u) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "Deseja realizar o teste agora?",
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 18),
          ),
          content: Text(
            "As funcionalidades e cores do aplicativo só estarão disponíveis depois do resultado do teste de inteligência dominante.",
            style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: isDark ? Colors.white60 : Colors.black54),
          ),
          actions: [
            TextButton(
              child: Text("Não", style: TextStyle(color: isDark ? Colors.white60 : Colors.black, fontFamily: 'Poppins')),
              onPressed: () {
                // Navigate to home but with no dominant intelligence yet
                Navigator.pop(context); // Close dialog
                context.push('/home', extra: u);
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.tealAccent : Colors.black,
                foregroundColor: isDark ? Colors.black : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Sim", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.pop(context); // Close dialog
                context.push('/teste', extra: u);
              },
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
                "Criar sua conta",
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
                "Comece sua jornada de estudos de maneira inteligente.",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              CampoTexto(
                labelText: 'Nome',
                controller: controllerNome,
                obscureText: false,
                helperText: 'Como prefere ser chamado',
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 8),
              CampoTexto(
                labelText: 'E-mail',
                controller: controllerEmail,
                obscureText: false,
                helperText: 'Seu melhor e-mail',
                prefixIcon: Icons.email_outlined,
              ),
              const SizedBox(height: 8),
              CampoTexto(
                labelText: 'Senha',
                controller: controllerSenha,
                obscureText: true,
                helperText: 'Mínimo de 6 caracteres',
                prefixIcon: Icons.lock_outline,
              ),
              const SizedBox(height: 36),
              if (isLoading)
                CircularProgressIndicator(color: isDark ? Colors.tealAccent : Colors.black)
              else
                Column(
                  children: [
                    Botao(
                      texto: "Cadastrar-se",
                      funcao: handleCadastro,
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
