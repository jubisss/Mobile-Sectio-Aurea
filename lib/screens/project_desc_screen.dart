import 'package:flutter/material.dart';

class ProjectDescScreen extends StatelessWidget {
  final Map<String, dynamic> u;

  const ProjectDescScreen({super.key, required this.u});

  Color _getThemeColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceAll('#', '0xff')));
    } catch (_) {
      return Colors.blueGrey;
    }
  }

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

    final List<Map<String, dynamic>> inteligencias = [
      {
        "nome": "Lógico-Matemática",
        "cor": "#ffbd59",
        "icon": "assets/images/logico.png",
        "desc": "Habilidade de raciocínio lógico, resolução de problemas e análise de padrões.",
        "pontos": "Raciocínio lógico, pensamento crítico, resolução de problemas e análise estratégica.",
        "areas": ["Engenheiro(a)", "Programador(a)", "Matemático(a)", "Cientista", "Analista de Sistemas", "Contador(a)"]
      },
      {
        "nome": "Linguística",
        "cor": "#9f042c",
        "icon": "assets/images/linguistica.png",
        "desc": "Gostam de ler, escrever, contar histórias, debater ideias e aprender novos idiomas.",
        "pontos": "Boa comunicação, argumentação, escrita clara e interpretação de textos.",
        "areas": ["Escritor(a)", "Jornalista", "Professor(a)", "Advogado(a)", "Redator(a)", "Roteirista", "Tradutor(a)"]
      },
      {
        "nome": "Musical",
        "cor": "#8a03d2",
        "icon": "assets/images/musical.png",
        "desc": "Sensibilidade a sons, ritmos, melodias e facilidade com instrumentos musicais.",
        "pontos": "Percepção rítmica, criatividade sonora e facilidade para composição.",
        "areas": ["Músico(a)", "Cantor(a)", "Compositor(a)", "Produtor(a) Musical", "Professor(a) de Música"]
      },
      {
        "nome": "Interpessoal",
        "cor": "#ff5f00",
        "icon": "assets/images/interpessoal.png",
        "desc": "Capacidade de entender emoções, intenções e sentimentos das outras pessoas.",
        "pontos": "Empatia, liderança, comunicação e trabalho em equipe.",
        "areas": ["Psicólogo(a)", "Professor(a)", "Líder de equipe", "Recursos Humanos", "Assistente Social"]
      },
      {
        "nome": "Intrapessoal",
        "cor": "#5170ff",
        "icon": "assets/images/intrapessoal.png",
        "desc": "Capacidade de compreender a si mesmo, suas emoções e objetivos pessoais.",
        "pontos": "Autoconhecimento, disciplina, reflexão e controle emocional.",
        "areas": ["Psicólogo(a)", "Escritor(a)", "Filósofo(a)", "Coach", "Pesquisador(a)"]
      },
      {
        "nome": "Espacial",
        "cor": "#d203a4",
        "icon": "assets/images/espacial.png",
        "desc": "Habilidade de visualizar objetos, espaços e formas mentalmente.",
        "pontos": "Criatividade visual, percepção espacial e imaginação.",
        "areas": ["Arquiteto(a)", "Designer", "Engenheiro(a)", "Ilustrador(a)", "Fotógrafo(a)"]
      },
      {
        "nome": "Corporal-Cinestésica",
        "cor": "#00bf63",
        "icon": "assets/images/corporal.png",
        "desc": "Habilidade de usar o corpo para resolver problemas ou expressar ideias e emoções.",
        "pontos": "Coordenação motora, expressão corporal e habilidades físicas.",
        "areas": ["Atleta", "Dançarino(a)", "Fisioterapeuta", "Educador(a) Físico", "Ator/Atriz"]
      }
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Sobre o Projeto",
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
              // Hero Image Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    "assets/images/todas.png",
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Quote Card
              Card(
                color: userAccent.withOpacity(0.08),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Icon(Icons.format_quote, size: 36, color: Colors.blueGrey),
                      const SizedBox(height: 8),
                      Text(
                        "Aprender não é sobre se encaixar em um modelo único. É sobre descobrir o seu jeito de aprender.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title: Howard Gardner Section
              Text(
                " Howard Gardner e Inteligências Múltiplas",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // Howard Gardner Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          "assets/images/Howard.png",
                          width: 80,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Howard Gardner",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Cada pessoa aprende de um jeito único. O Sectio Áurea foi desenvolvido com base na Teoria das Inteligências Múltiplas, criada pelo psicólogo de Howard Gardner. Ao identificar suas inteligências predominantes, sugerimos os melhores métodos de estudo personalizados.",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
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
              ),
              const SizedBox(height: 24),

              // Title: Las Inteligências
              Text(
                " As 7 Inteligências do App",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // Inteligencias List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: inteligencias.length,
                itemBuilder: (context, index) {
                  final intel = inteligencias[index];
                  final Color intelColor = _getThemeColor(intel["cor"]);

                  return Card(
                    elevation: 1.5,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: intelColor.withOpacity(0.1),
                        child: Image.asset(intel["icon"], width: 24, height: 24),
                      ),
                      title: Text(
                        intel["nome"],
                        style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 13.5),
                      ),
                      subtitle: Text(
                        intel["desc"],
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: isDark ? Colors.white54 : Colors.black54),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Pontos Fortes:",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: intelColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                intel["pontos"],
                                style: const TextStyle(fontFamily: 'Poppins', fontSize: 12),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Possíveis Áreas de Trabalho:",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: intelColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: (intel["areas"] as List<String>).map((area) {
                                  return Chip(
                                    label: Text(
                                      area,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 11,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                    backgroundColor: isDark ? Colors.white12 : Colors.grey[200],
                                    padding: EdgeInsets.zero,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        )
                      ],
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
