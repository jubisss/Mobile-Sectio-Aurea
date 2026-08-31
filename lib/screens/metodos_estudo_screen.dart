import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sectio_aurea/data/metodos_data.dart';

class MetodosEstudoScreen extends StatefulWidget {
  final Map<String, dynamic> u;

  const MetodosEstudoScreen({super.key, required this.u});

  @override
  State<MetodosEstudoScreen> createState() => _MetodosEstudoScreenState();
}

class _MetodosEstudoScreenState extends State<MetodosEstudoScreen> {
  late InteligenicaInfo _selectedIntelligence;

  @override
  void initState() {
    super.initState();
    String userIntelName = widget.u["tipo_dom"] ?? "Lógico-matemática";
    if (userIntelName.isEmpty) {
      userIntelName = "Lógico-matemática";
    }
    _selectedIntelligence = getIntelligenceByDomName(userIntelName);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color intelColor = _selectedIntelligence.cor;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xff121212) : const Color(0xfff4f1eb),
      appBar: AppBar(
        backgroundColor: intelColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Métodos de Estudo",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner informativo da Inteligência do Usuário
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: intelColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: intelColor.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _selectedIntelligence.icone,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Sua Inteligência: ${_selectedIntelligence.nome}",
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedIntelligence.descricao,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Título dos Métodos Recomendados
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Métodos Recomendados (${_selectedIntelligence.metodos.length})",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                PopupMenuButton<InteligenicaInfo>(
                  icon: Icon(
                    Icons.filter_list,
                    color: isDark ? Colors.tealAccent : Colors.black87,
                  ),
                  tooltip: "Filtrar por Inteligência",
                  onSelected: (intel) {
                    setState(() {
                      _selectedIntelligence = intel;
                    });
                  },
                  itemBuilder: (context) {
                    return todasInteligencias.map((intel) {
                      return PopupMenuItem<InteligenicaInfo>(
                        value: intel,
                        child: Row(
                          children: [
                            Icon(intel.icone, color: intel.cor, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              intel.nome,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList();
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Grid com 2 Colunas de Métodos
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemCount: _selectedIntelligence.metodos.length,
              itemBuilder: (context, index) {
                final metodo = _selectedIntelligence.metodos[index];
                return _buildMetodoCard(context, metodo, intelColor, isDark);
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildMetodoCard(
    BuildContext context,
    MetodoEstudo metodo,
    Color accentColor,
    bool isDark,
  ) {
    final Color cardBg = isDark ? const Color(0xff1e1e1e) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black87;

    return Card(
      elevation: 2,
      color: cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: accentColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          final Map<String, dynamic> params = {
            "user": widget.u,
            "metodo": metodo,
            "inteligencia": _selectedIntelligence,
          };
          context.push('/metodos/detalhe', extra: params);
        },
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header do Card: Ícone e Dificuldade
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      metodo.icone,
                      color: accentColor,
                      size: 22,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: getDificuldadeColor(metodo.dificuldade, isBackground: true),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      metodo.dificuldade,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: getDificuldadeColor(metodo.dificuldade, isBackground: false),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Título
              Text(
                metodo.titulo,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 6),

              // Resuminho igual ao web
              Expanded(
                child: Text(
                  metodo.descricao,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: isDark ? Colors.white60 : Colors.black54,
                    height: 1.3,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              // Footer: Tempo e Ver mais
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: isDark ? Colors.white38 : Colors.black45,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        metodo.tempo,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          color: isDark ? Colors.white38 : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        "Ver mais",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 10,
                        color: accentColor,
                      ),
                    ],
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
