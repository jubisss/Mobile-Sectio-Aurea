import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sectio_aurea/services/database_service.dart';
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

    setState(() {
      isLoading = true;
    });

    final db = DatabaseService();
    final user = await db.register(nome, email, password);

    setState(() {
      isLoading = false;
    });

    if (user != null) {
      // User registered successfully! Show test invitation dialog
      irParaTeste(user);
    } else {
      showError("E-mail já cadastrado ou falha no servidor.");
    }
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
