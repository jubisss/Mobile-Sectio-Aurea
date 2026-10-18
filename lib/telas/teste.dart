import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sectio_aurea/services/banco_dados.dart';
import 'package:sectio_aurea/widgets/botao.dart';

class Teste extends StatefulWidget {
  final Map<String, dynamic> u;

  const Teste({super.key, required this.u});

  @override
  State<Teste> createState() => _TesteState();
}

class _TesteState extends State<Teste> {
  static const Color verde = Color(0xff00bf63);
  static const Color amarelo = Color(0xffffbd59);
  static const Color vermelho = Color(0xff9f042c);
  static const Color azul = Color(0xff5170ff);
  static const Color laranja = Color(0xffff5f00);
  static const Color roxo = Color(0xff8a03d2);
  static const Color rosa = Color(0xffd203a4);

  final List<Map<String, dynamic>> inteligencias = [
    {"nome": "Lógico-matemática", "cor": amarelo, "cor_hex": "0xffffbd59", "logo": "logico.png"},
    {"nome": "Linguística", "cor": vermelho, "cor_hex": "0xff9f042c", "logo": "linguistica.png"},
    {"nome": "Corporal", "cor": verde, "cor_hex": "0xff00bf63", "logo": "corporal.png"},
    {"nome": "Intrapessoal", "cor": azul, "cor_hex": "0xff5170ff", "logo": "intrapessoal.png"},
    {"nome": "Interpessoal", "cor": laranja, "cor_hex": "0xffff5f00", "logo": "interpessoal.png"},
    {"nome": "Musical", "cor": roxo, "cor_hex": "0xff8a03d2", "logo": "musical.png"},
    {"nome": "Espacial", "cor": rosa, "cor_hex": "0xffd203a4", "logo": "espacial.png"},
  ];

  final List<Map<String, dynamic>> opcoesPerg1 = [
    {"id": "Ágil", "rank": null, "cor": verde},
    {"id": "Detalhista", "rank": null, "cor": rosa},
    {"id": "Amigo", "rank": null, "cor": laranja},
    {"id": "Sensível", "rank": null, "cor": azul},
    {"id": "Comunicativo", "rank": null, "cor": vermelho},
    {"id": "Racional", "rank": null, "cor": amarelo},
    {"id": "Musical", "rank": null, "cor": roxo},
  ];

  /*
  // --- ESTRUTURA PARA EXPANSÃO FUTURA DO TESTE (PERGUNTAS ADICIONAIS) ---
  // Pergunta 2: Em momentos livres, qual atividade você mais gosta de fazer?
  final List<Map<String, dynamic>> opcoesPerg2 = [
    {"id": "Praticar esportes ou dançar", "rank": null, "cor": verde}, // Corporal
    {"id": "Desenhar, pintar ou montar quebra-cabeças", "rank": null, "cor": rosa}, // Espacial
    {"id": "Conversar e sair com amigos", "rank": null, "cor": laranja}, // Interpessoal
    {"id": "Ficar sozinho refletindo ou escrevendo", "rank": null, "cor": azul}, // Intrapessoal
    {"id": "Ler livros, artigos ou poemas", "rank": null, "cor": vermelho}, // Linguística
    {"id": "Jogar jogos de lógica, xadrez ou resolver enigmas", "rank": null, "cor": amarelo}, // Lógico-matemática
    {"id": "Tocar um instrumento ou ouvir músicas", "rank": null, "cor": roxo}, // Musical
  ];

  // Pergunta 3: Qual método de estudo funciona melhor para você?
  final List<Map<String, dynamic>> opcoesPerg3 = [
    {"id": "Caminhar enquanto revisa ou criar gestos", "rank": null, "cor": verde}, // Corporal
    {"id": "Mapas mentais, diagramas coloridos e gráficos", "rank": null, "cor": rosa}, // Espacial
    {"id": "Grupos de estudo e ensinar outras pessoas", "rank": null, "cor": laranja}, // Interpessoal
    {"id": "Estudar sozinho em silêncio com autoavaliação", "rank": null, "cor": azul}, // Intrapessoal
    {"id": "Resumos escritos, fichamentos e leitura ativa", "rank": null, "cor": vermelho}, // Linguística
    {"id": "Resolução de exercícios, fórmulas e problemas", "rank": null, "cor": amarelo}, // Lógico-matemática
    {"id": "Mnemônicas com ritmo, rimas ou ouvir podcasts", "rank": null, "cor": roxo}, // Musical
  ];

  // Pergunta 4: Quando enfrenta um problema complexo, como prefere abordar?
  final List<Map<String, dynamic>> opcoesPerg4 = [
    {"id": "Colocar a mão na massa e experimentar na prática", "rank": null, "cor": verde}, // Corporal
    {"id": "Visualizar o cenário mentalmente ou esboçar num papel", "rank": null, "cor": rosa}, // Espacial
    {"id": "Pedir a opinião de outras pessoas e debater soluções", "rank": null, "cor": laranja}, // Interpessoal
    {"id": "Analisar meus sentimentos e motivações antes de agir", "rank": null, "cor": azul}, // Intrapessoal
    {"id": "Pesquisar textos e redigir os prós e contras", "rank": null, "cor": vermelho}, // Linguística
    {"id": "Dividir o problema em partes lógicas e criar um algoritmo", "rank": null, "cor": amarelo}, // Lógico-matemática
    {"id": "Buscar um padrão harmônico e trabalhar com trilha sonora", "rank": null, "cor": roxo}, // Musical
  ];
  */

  void selecionar(String id, int valor) {
    setState(() {
      for (var item in opcoesPerg1) {
        if (item["rank"] == valor) {
          item["rank"] = null; // Clear duplicate rank
        }
      }
      for (var item in opcoesPerg1) {
        if (item["id"] == id) {
          item["rank"] = (item["rank"] == valor) ? null : valor;
        }
      }
    });
  }

  bool numeroJaUsado(int num) {
    return opcoesPerg1.any((item) => item["rank"] == num);
  }

  bool todosRanksDefinidos() {
    return opcoesPerg1.every((item) => item["rank"] != null);
  }

  void calcular() async {
    if (!todosRanksDefinidos()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Aviso", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
          content: const Text("Por favor, atribua uma nota de 1 a 7 para cada um dos adjetivos, sem repetir.", style: TextStyle(fontFamily: 'Poppins')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      );
      return;
    }

    var maiorPerg1 = opcoesPerg1.firstWhere(
      (item) => item["rank"] == 7,
      orElse: () => {"id": "Nenhum"},
    );

    var dominante = inteligencias.firstWhere(
      (inteligencia) => maiorPerg1["cor"] == inteligencia["cor"],
      orElse: () => inteligencias.first,
    );

    // Calculate top 3 intelligences based on rank sorted descending
    final sortedOptions = List<Map<String, dynamic>>.from(opcoesPerg1);
    sortedOptions.sort((a, b) => (b["rank"] as int).compareTo(a["rank"] as int));
    
    final List<String> top3Names = [];
    for (int i = 0; i < 3; i++) {
      final optColor = sortedOptions[i]["cor"];
      final intel = inteligencias.firstWhere((intel) => intel["cor"] == optColor, orElse: () => inteligencias.first);
      top3Names.add(intel["nome"]);
    }

    // Update user local object
    final updatedUser = Map<String, dynamic>.from(widget.u);
    updatedUser["tipo_dom"] = dominante["nome"];
    updatedUser["clas_inteli"] = dominante["cor_hex"];
    updatedUser["inteligencias_dominantes"] = top3Names;

    // Save user update to DB
    await DatabaseService().updateUser(updatedUser);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: dominante["cor"],
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              const Text(
                "Sua inteligência dominante é:",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                dominante["nome"],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Image.asset(
                "assets/images/${dominante['logo']}",
                width: 90,
                height: 90,
                color: Colors.white,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.lightbulb_outline,
                  size: 90,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: dominante["cor"],
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text(
                  "Ir para o aplicativo",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w800,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  context.push('/home', extra: updatedUser);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Teste de Inteligência Múltipla",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Atribua notas de 1 a 7 (sendo 7 a que mais se identifica e 1 a que menos se identifica) sem repetir números.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Eu me considero:",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Column(
                  children: opcoesPerg1.map((item) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xff1e1e1e) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.black38 : Colors.black.withOpacity(0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item["id"],
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: item["cor"],
                            ),
                          ),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(7, (numIdx) {
                                int score = numIdx + 1;
                                bool isSelected = item["rank"] == score;
                                bool isUsed = numeroJaUsado(score);
 
                                Color pillColor = isDark ? const Color(0xff2a2a2a) : Colors.white;
                                Color borderColor = isDark ? Colors.white12 : Colors.black12;
                                Color textColor = isDark ? Colors.white70 : Colors.black87;
 
                                if (isSelected) {
                                  pillColor = item["cor"];
                                  borderColor = item["cor"];
                                  textColor = Colors.white;
                                } else if (isUsed) {
                                  pillColor = isDark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.04);
                                  borderColor = Colors.transparent;
                                  textColor = isDark ? Colors.white24 : Colors.black38;
                                }
 
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                  child: GestureDetector(
                                    onTap: isUsed && !isSelected
                                        ? null
                                        : () => selecionar(item["id"], score),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 150),
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: pillColor,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: borderColor, width: 1.5),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "$score",
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                            color: textColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Botao(
                      texto: "Limpar Notas",
                      funcao: () {
                        setState(() {
                          for (var item in opcoesPerg1) {
                            item["rank"] = null;
                          }
                        });
                      },
                      cor: isDark ? const Color(0xff1e1e1e) : Colors.white,
                      corTexto: isDark ? Colors.white70 : Colors.black87,
                      width: 110,
                    ),
                    const SizedBox(width: 16),
                    Botao(
                      texto: "Concluir",
                      funcao: calcular,
                      width: 110,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
