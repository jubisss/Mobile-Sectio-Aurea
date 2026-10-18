import 'package:flutter/material.dart';

class SeletorCoresModal extends StatelessWidget {
  final String? corSelecionada;
  final ValueChanged<String> onCorSelecionada;
  final String titulo;
  final String? corPadraoTexto;

  const SeletorCoresModal({
    super.key,
    required this.corSelecionada,
    required this.onCorSelecionada,
    this.titulo = "Selecionar Cor",
    this.corPadraoTexto,
  });

  // Docs-inspired 6-row palette
  static const List<List<String>> docsColorGrid = [
    // Grayscale / Neutrals
    ["0xff000000", "0xff434343", "0xff666666", "0xff999999", "0xffb7b7b7", "0xffcccccc", "0xffe0e0e0", "0xfff4f1eb", "0xffffffff"],
    // Vibrants / Base
    ["0xffcc0000", "0xffff5f00", "0xffff9900", "0xffffbd59", "0xff00bf63", "0xff00b4d8", "0xff5170ff", "0xff8b5cf6", "0xffd203a4"],
    // Pastels / Soft tones
    ["0xffffe6e6", "0xffffebd9", "0xfffff4e6", "0xfffff9e6", "0xffe6ffe6", "0xffe6faff", "0xffe6f2ff", "0xfff3e8ff", "0xfffce7f3"],
    // Medium pastels
    ["0xfffca5a5", "0xfffdba74", "0xfffed7aa", "0xfffef08a", "0xff86efac", "0xff7dd3fc", "0xff93c5fd", "0xffc4b5fd", "0xfff472b6"],
    // Rich tones
    ["0xffef4444", "0xfff97316", "0xfff59e0b", "0xffeab308", "0xff22c55e", "0xff06b6d4", "0xff3b82f6", "0xffa855f7", "0xffec4899"],
    // Deep shades
    ["0xff991b1b", "0xff9a3412", "0xffb45309", "0xff854d0e", "0xff166534", "0xff155e75", "0xff1e40af", "0xff581c87", "0xff831843"],
  ];

  static Future<String?> abrir({
    required BuildContext context,
    required String? corAtual,
    String titulo = "Selecionar Cor",
    String? corPadraoTexto,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SeletorCoresModal(
        corSelecionada: corAtual,
        titulo: titulo,
        corPadraoTexto: corPadraoTexto,
        onCorSelecionada: (cor) {
          Navigator.pop(ctx, cor);
        },
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      String clean = hex.replaceAll('#', '').replaceAll('0x', '').replaceAll('0X', '');
      if (clean.length == 6) clean = 'FF$clean';
      return Color(int.parse(clean, radix: 16));
    } catch (_) {
      return Colors.blue;
    }
  }

  bool _isMesmaCor(String a, String? b) {
    if (b == null) return false;
    String cleanA = a.toLowerCase().replaceAll('#', '').replaceAll('0x', '');
    String cleanB = b.toLowerCase().replaceAll('#', '').replaceAll('0x', '');
    if (cleanA.length == 8 && cleanA.startsWith('ff')) cleanA = cleanA.substring(2);
    if (cleanB.length == 8 && cleanB.startsWith('ff')) cleanB = cleanB.substring(2);
    return cleanA == cleanB;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color modalBg = isDark ? const Color(0xff1e1e1e) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black87;

    return Container(
      decoration: BoxDecoration(
        color: modalBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, -4))],
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                titulo,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: textColor,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          if (corPadraoTexto != null) ...[
            const SizedBox(height: 4),
            Text(
              corPadraoTexto!,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Color grid
          SingleChildScrollView(
            child: Column(
              children: docsColorGrid.map((row) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: row.map((hex) {
                      final Color col = _parseColor(hex);
                      final bool isSel = _isMesmaCor(hex, corSelecionada);
                      final bool isLight = col.computeLuminance() > 0.6;

                      return GestureDetector(
                        onTap: () => onCorSelecionada(hex),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: col,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSel
                                  ? (isDark ? Colors.white : Colors.black)
                                  : (isLight ? Colors.grey.shade400 : Colors.transparent),
                              width: isSel ? 2.5 : 1,
                            ),
                            boxShadow: [
                              if (isSel)
                                BoxShadow(
                                  color: col.withValues(alpha: 0.6),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                            ],
                          ),
                          child: isSel
                              ? Icon(
                                  Icons.check,
                                  size: 18,
                                  color: isLight ? Colors.black87 : Colors.white,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
