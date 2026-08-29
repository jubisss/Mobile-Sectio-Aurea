import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sectio_aurea/widgets/botao.dart';

class PagInicial extends StatelessWidget {
  const PagInicial({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xff121212) : const Color(0xfff4f1eb),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                // Logo Area
                Image.asset(
                  isDark ? "assets/images/logoBranca.png" : "assets/images/LogoPreta.png",
                  width: 150,
                  height: 150,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.blur_on,
                    size: 150,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                // Title
                Text(
                  "Sectio Aurea",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w900,
                    fontSize: 32,
                    color: isDark ? Colors.white : Colors.black87,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Equilíbrio, inteligência e organização nos seus estudos.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                const Spacer(flex: 2),
                // Buttons Area
                Column(
                  children: [
                    Botao(
                      texto: "Cadastrar-se",
                      funcao: () {
                        context.push('/cadastro');
                      },
                      width: 180,
                    ),
                    const SizedBox(height: 12),
                    Botao(
                      texto: "Login",
                      funcao: () {
                        context.push('/login');
                      },
                      cor: isDark ? const Color(0xff1e1e1e) : const Color(0xfff4f1eb),
                      corTexto: isDark ? Colors.white70 : Colors.black87,
                      width: 180,
                    ),
                  ],
                ),
                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
