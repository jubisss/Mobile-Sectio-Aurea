import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  final Map<String, dynamic> u;

  const AboutUsScreen({super.key, required this.u});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // User primary intelligence color accent
    Color userAccent = Colors.blueGrey;
    String? colorHex = u["clas_inteli"];
    if (colorHex != null && colorHex.isNotEmpty) {
      try {
        userAccent = Color(int.parse(colorHex));
      } catch (_) {}
    }

    final List<Map<String, dynamic>> team = [
      {
        "nome": "Juliana L. Almeida",
        "funcao": "Desenvolvedora Mobile",
        "tecnologias": "Flutter, Dart, PHP",
        "desc": "Responsável por desenvolver o aplicativo mobile integrado com a API, aplicando o design responsivo, gerenciamento de perfil e redefinição de senhas, além do suporte dinâmico a temas e controle de planos.",
        "iniciais": "JA"
      },
      {
        "nome": "Ana Beatriz J. B. Santos",
        "funcao": "Desenvolvedora Web",
        "tecnologias": "HTML, CSS, JavaScript, React",
        "desc": "Focou na criação e estilização da interface web do projeto Sectio Áurea, construindo páginas informativas, modais elegantes de login e cadastro e a visualização dos perfis de inteligência.",
        "iniciais": "AB"
      },
      {
        "nome": "Ana Clara L. Vicente",
        "funcao": "Desenvolvedora Web",
        "tecnologias": "HTML, CSS, JavaScript, React",
        "desc": "Colaborou no desenvolvimento front-end da plataforma web, implementando layouts modernos de bootstrap, controles dinâmicos de toggle de tema e as seções de informações dos planos de assinatura.",
        "iniciais": "AC"
      },
      {
        "nome": "Lara Fernanda de Napoli",
        "funcao": "Desenvolvedora Desktop",
        "tecnologias": "Electron, HTML, CSS, JavaScript",
        "desc": "Responsável pela criação da aplicação desktop usando o framework Electron, empacotando os recursos e oferecendo suporte nativo para computadores.",
        "iniciais": "LN"
      }
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Sobre Nós",
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: userAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Card(
                color: userAccent.withOpacity(0.08),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Quem Somos",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: userAccent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Somos uma equipe de estudantes dedicadas a construir soluções de software voltadas para a educação personalizada. O Sectio Áurea é o resultado do nosso Projeto Integrador, onde aplicamos tecnologias mobile, web e desktop integradas para criar um ambiente de aprendizado inteligente baseado nas inteligências múltiplas.",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12.5,
                          height: 1.5,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title: Team Members
              Text(
                " Desenvolvedores do Projeto",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // Members List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: team.length,
                itemBuilder: (context, index) {
                  final dev = team[index];

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Styled Initials Avatar
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: userAccent.withOpacity(0.12),
                            child: Text(
                              dev["iniciais"],
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: userAccent,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      dev["nome"],
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13.5,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                    if (dev["funcao"].contains("Juliana")) // tag highlight for Juliana
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: userAccent.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          "Você",
                                          style: TextStyle(fontFamily: 'Poppins', fontSize: 9, fontWeight: FontWeight.bold, color: userAccent),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  dev["funcao"],
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11.5,
                                    color: userAccent,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Tech: ${dev["tecnologias"]}",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 10,
                                    color: isDark ? Colors.white38 : Colors.black38,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  dev["desc"],
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 11.5,
                                    height: 1.4,
                                    color: isDark ? Colors.white60 : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
