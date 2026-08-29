import 'package:flutter/material.dart';
import 'package:sectio_aurea/services/database_service.dart';
import 'package:sectio_aurea/widgets/botao.dart';
import 'package:sectio_aurea/widgets/campo_texto.dart';

class RevisaoTab extends StatefulWidget {
  final Map<String, dynamic> u;

  const RevisaoTab({super.key, required this.u});

  @override
  State<RevisaoTab> createState() => _RevisaoTabState();
}

class _RevisaoTabState extends State<RevisaoTab> {
  List<Map<String, dynamic>> _flashcards = [];
  List<Map<String, dynamic>> _subjects = [];
  String _filterSubject = "Todas"; // "Todas" or specific subject name
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    int userId = widget.u["id_usuario"] ?? 1;
    final db = DatabaseService();

    List<Map<String, dynamic>> loadedCards = await db.getFlashcards(userId);
    List<Map<String, dynamic>> loadedmats = await db.getMaterias(userId);

    // Sort flashcards by ID descending (newest first)
    loadedCards.sort((a, b) => b["id_flash"].compareTo(a["id_flash"]));

    if (mounted) {
      setState(() {
        _flashcards = loadedCards;
        _subjects = loadedmats;
        _isLoading = false;
      });
    }
  }

  void _createFlashcard() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color accentColor = Colors.blueGrey;
    String? colorHex = widget.u["clas_inteli"];
    if (colorHex != null && colorHex.isNotEmpty) {
      try {
        accentColor = Color(int.parse(colorHex));
      } catch (_) {}
    }

    if (_subjects.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Aviso", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
          content: const Text("Crie ao menos uma Matéria antes de adicionar flashcards."),
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

    int? selectedMateriaId = int.tryParse(_subjects.first["id_materia"].toString());
    final themeController = TextEditingController();
    final questionController = TextEditingController();
    final answerController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text("Novo Flashcard", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      value: selectedMateriaId,
                      decoration: const InputDecoration(labelText: "Matéria"),
                      dropdownColor: isDark ? const Color(0xff1e1e1e) : Colors.white,
                      items: _subjects.map((m) {
                        int? mId = int.tryParse(m["id_materia"].toString());
                        return DropdownMenuItem<int>(
                          value: mId,
                          child: Text(m["nome"], style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setDialogState(() {
                          selectedMateriaId = val;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    CampoTexto(
                      labelText: "Tema / Assunto",
                      controller: themeController,
                      obscureText: false,
                      width: double.infinity,
                    ),
                    const SizedBox(height: 8),
                    CampoTexto(
                      labelText: "Pergunta / Frente",
                      controller: questionController,
                      obscureText: false,
                      width: double.infinity,
                    ),
                    const SizedBox(height: 8),
                    CampoTexto(
                      labelText: "Resposta / Verso",
                      controller: answerController,
                      obscureText: false,
                      width: double.infinity,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancelar", style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontFamily: 'Poppins')),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? accentColor : Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    String theme = themeController.text.trim();
                    String q = questionController.text.trim();
                    String a = answerController.text.trim();

                    if (selectedMateriaId != null && q.isNotEmpty && a.isNotEmpty) {
                      final db = DatabaseService();
                      int userId = widget.u["id_usuario"] ?? 1;
                      int flashId = await db.createFlashcard(
                        selectedMateriaId!,
                        q,
                        theme.isEmpty ? "Estudo" : theme,
                        a,
                        userId,
                      );
                      if (flashId > 0) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Flashcard cadastrado com sucesso!")),
                          );
                          Navigator.pop(context);
                        }
                        _loadData();
                      } else {
                        if (context.mounted) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              title: const Text("Erro", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                              content: const Text("Não foi possível cadastrar o flashcard no banco de dados."),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text("OK", style: TextStyle(color: isDark ? Colors.tealAccent : Colors.black, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: const Text("Criar", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteFlashcard(int id) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Excluir Flashcard?", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
          content: const Text("Deseja apagar este flashcard permanentemente?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Cancelar", style: TextStyle(color: isDark ? Colors.white60 : Colors.black54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Excluir", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final db = DatabaseService();
      int userId = widget.u["id_usuario"] ?? 1;
      await db.deleteFlashcard(id, userId);
      _loadData();
    }
  }

  void _startStudySession(List<Map<String, dynamic>> cards, {int startIndex = 0}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        Color accentColor = Colors.blueGrey;
        String? colorHex = widget.u["clas_inteli"];
        if (colorHex != null && colorHex.isNotEmpty) {
          try {
            accentColor = Color(int.parse(colorHex));
          } catch (_) {}
        }

        int currentIndex = startIndex;
        return StatefulBuilder(
          builder: (context, setSessionState) {
            final card = cards[currentIndex];
            
            // Get subject color
            Color matColor = Colors.grey;
            try {
              final mat = _subjects.firstWhere((m) => m["id_materia"].toString() == card["id_materia"].toString());
              matColor = Color(int.parse(mat["cor"] ?? "0xff5170ff"));
            } catch (_) {}

            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Main Expanded FlipCard
                  Container(
                    width: 310,
                    height: 390,
                    child: FlipCard(
                      key: ValueKey(currentIndex), // Forces rebuild to front side on index change
                      front: _buildCardSide(
                        card["tema"],
                        card["pergunta"],
                        "Toque para revelar a resposta",
                        matColor,
                        card["id_flash"],
                        isExpanded: true,
                      ),
                      back: _buildCardSide(
                        "Resposta",
                        card["resposta"],
                        "Toque para ver a pergunta",
                        matColor.withOpacity(0.95),
                        card["id_flash"],
                        isBack: true,
                        isExpanded: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  
                  // Progress and Control Row
                  Container(
                    width: 310,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xff1e1e1e) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.black54 : Colors.black12,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${currentIndex + 1} de ${cards.length}",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        Row(
                          children: [
                            if (currentIndex > 0) ...[
                              IconButton(
                                icon: Icon(Icons.arrow_back, color: isDark ? Colors.white70 : Colors.black54),
                                onPressed: () {
                                  setSessionState(() {
                                    currentIndex--;
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                            ],
                            if (currentIndex < cards.length - 1)
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark ? accentColor : Colors.black,
                                  foregroundColor: isDark ? Colors.black : Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                icon: const Icon(Icons.arrow_forward, size: 14),
                                label: const Text(
                                  "Próximo",
                                  style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                                onPressed: () {
                                  setSessionState(() {
                                    currentIndex++;
                                  });
                                },
                              )
                            else
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff9f042c),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  "Concluir",
                                  style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor = isDark ? const Color(0xff121212) : const Color(0xfff4f1eb);
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color subtextColor = isDark ? Colors.white60 : Colors.black54;
    final Color cardBg = isDark ? const Color(0xff1e1e1e) : Colors.white;
    final Color borderCol = isDark ? Colors.white12 : Colors.black12;

    Color accentColor = Colors.blueGrey;
    String? colorHex = widget.u["clas_inteli"];
    if (colorHex != null && colorHex.isNotEmpty) {
      try {
        accentColor = Color(int.parse(colorHex));
      } catch (_) {}
    }

    // Filter cards
    final filteredCards = _flashcards.where((card) {
      if (_filterSubject == "Todas") return true;
      return card["nome_materia"] == _filterSubject;
    }).toList();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: isDark ? Colors.tealAccent : Colors.black))
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // Header control bar (Dropdown filter + create button)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Filter dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderCol),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _filterSubject,
                            dropdownColor: cardBg,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                            items: [
                              DropdownMenuItem(
                                value: "Todas", 
                                child: Text("Filtrar: Todas", style: TextStyle(color: textColor, fontFamily: 'Poppins')),
                              ),
                              ..._subjects.map((m) => DropdownMenuItem(
                                    value: m["nome"],
                                    child: Text(m["nome"], style: TextStyle(color: textColor, fontFamily: 'Poppins')),
                                  )),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                  setState(() {
                                    _filterSubject = val;
                                  });
                              }
                            },
                          ),
                        ),
                      ),
                      // Create button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? accentColor : Colors.black87,
                          foregroundColor: isDark ? Colors.black : Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text(
                          "Criar Flashcard",
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        onPressed: _createFlashcard,
                      ),
                    ],
                  ),

                  // Subject Study session option
                  if (filteredCards.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Botao(
                      texto: _filterSubject == "Todas" 
                          ? "Estudar Todos os Flashcards" 
                          : "Estudar $_filterSubject",
                      funcao: () => _startStudySession(filteredCards),
                      cor: accentColor,
                      corTexto: isDark ? Colors.black : const Color(0xfff4f1eb),
                      width: double.infinity,
                      height: 44,
                    ),
                  ],

                  const SizedBox(height: 16),
                  // Grid View
                  Expanded(
                    child: filteredCards.isEmpty
                        ? Center(
                            child: Text(
                              _flashcards.isEmpty
                                  ? "Nenhum flashcard criado.\nClique no botão acima para adicionar!"
                                  : "Nenhum flashcard para a disciplina selecionada.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                color: isDark ? Colors.white38 : Colors.black38,
                              ),
                            ),
                          )
                        : GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.9,
                            ),
                            itemCount: filteredCards.length,
                            padding: const EdgeInsets.only(bottom: 80),
                            itemBuilder: (context, index) {
                              final card = filteredCards[index];

                              // Get subject color
                              Color matColor = Colors.grey;
                              try {
                                final mat = _subjects.firstWhere((m) => m["id_materia"].toString() == card["id_materia"].toString());
                                matColor = Color(int.parse(mat["cor"] ?? "0xff5170ff"));
                              } catch (_) {}

                              return GestureDetector(
                                onTap: () => _startStudySession(filteredCards, startIndex: index),
                                child: _buildCardSide(
                                  card["tema"],
                                  card["pergunta"],
                                  "Toque para expandir",
                                  matColor,
                                  card["id_flash"],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCardSide(String header, String body, String footer, Color color, int id, {bool isBack = false, bool isExpanded = false}) {
    final bool isLightBg = color.computeLuminance() > 0.5;
    final Color textColor = isLightBg ? Colors.black87 : Colors.white;
    final Color headerBgColor = isLightBg ? Colors.black.withOpacity(0.08) : Colors.white.withOpacity(0.15);
    final Color footerColor = isLightBg ? Colors.black54 : Colors.white60;

    return Card(
      color: color,
      elevation: isExpanded ? 6 : 3,
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(isExpanded ? 24.0 : 14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Topic / Title)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: headerBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    header,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: isExpanded ? 11 : 9,
                      color: textColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Spacer(),
                // Main Question or Answer body
                Center(
                  child: Text(
                    body,
                    textAlign: TextAlign.center,
                    maxLines: isExpanded ? 8 : 4,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: isExpanded ? 18 : 13,
                      color: textColor,
                    ),
                  ),
                ),
                const Spacer(),
                // Tap notice footer
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    footer,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: isExpanded ? 10 : 8,
                      color: footerColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Deletion button (top right, only visible on front in grid view)
          if (!isExpanded && !isBack)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _deleteFlashcard(id),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.black12,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: isLightBg ? Colors.black54 : Colors.white70,
                    size: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// 3D Flip Card Widget
class FlipCard extends StatefulWidget {
  final Widget front;
  final Widget back;

  const FlipCard({super.key, required this.front, required this.back});

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleCard() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    _isFront = !_isFront;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleCard,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * 3.1415926535897932;
          final isBack = angle >= 3.1415926535897932 / 2;

          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // 3D perspective
              ..rotateY(angle),
            alignment: Alignment.center,
            child: isBack
                ? Transform(
                    transform: Matrix4.identity()..rotateY(3.1415926535897932),
                    alignment: Alignment.center,
                    child: widget.back,
                  )
                : widget.front,
          );
        },
      ),
    );
  }
}
