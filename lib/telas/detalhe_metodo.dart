import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sectio_aurea/dados/dados_metodos.dart';

class MetodoDetalheScreen extends StatelessWidget {
  final Map<String, dynamic> u;
  final MetodoEstudo metodo;
  final InteligenicaInfo inteligencia;

  const MetodoDetalheScreen({
    super.key,
    required this.u,
    required this.metodo,
    required this.inteligencia,
  });

  void _executarAcao(BuildContext context) {
    switch (metodo.tipoAcao) {
      case TipoAcao.irParaPomodoro:
        final Map<String, dynamic> params = {
          "user": u,
          "materia": null,
        };
        context.push('/timers/pomodoro', extra: params);
        break;

      case TipoAcao.irParaRevisao:
        context.push('/flashcards-revisao', extra: u);
        break;

      case TipoAcao.irParaCornell:
        context.push('/create/cornell', extra: u);
        break;

      case TipoAcao.irParaPodcast:
        final Map<String, dynamic> params = {
          "user": u,
          "title": "Gravação de Podcast",
          "color": inteligencia.cor,
        };
        context.push('/feynman-podcast', extra: params);
        break;

      case TipoAcao.irParaFeynman:
        final Map<String, dynamic> params = {
          "user": u,
          "title": "Técnica Feynman",
          "color": inteligencia.cor,
        };
        context.push('/feynman-podcast', extra: params);
        break;

      case TipoAcao.irParaGrupos:
        context.push('/grupos-estudo-hub', extra: u);
        break;

      case TipoAcao.irParaSavoring:
        context.push('/leitura-savoring', extra: u);
        break;

      case TipoAcao.irParaVideos:
        context.push('/video-library', extra: u);
        break;

      case TipoAcao.irParaMapaMental:
        context.push('/mapa-mental', extra: u);
        break;

      case TipoAcao.irParaDiagramaFluxo:
        context.push('/diagrama-fluxo', extra: u);
        break;

      case TipoAcao.irParaSimulado:
        context.push('/simulado-config', extra: u);
        break;

      case TipoAcao.apenasInstrucoes:
      default:
        Navigator.pop(context);
        break;
    }
  }

  String _getBotaoTexto() {
    switch (metodo.tipoAcao) {
      case TipoAcao.irParaPomodoro:
        return 'Usar Pomodoro';
      case TipoAcao.irParaRevisao:
        return 'Ir para Flashcards / Revisão';
      case TipoAcao.irParaCornell:
        return 'Usar Cornell com Notas';
      case TipoAcao.irParaPodcast:
        return 'Gravar Podcast';
      case TipoAcao.irParaFeynman:
        return 'Gravar Explicação';
      case TipoAcao.irParaGrupos:
        return 'Abrir Grupos de Estudo';
      case TipoAcao.irParaSavoring:
        return 'Iniciar Leitura Savoring';
      case TipoAcao.irParaVideos:
        return 'Minha Biblioteca de Vídeos';
      case TipoAcao.irParaMapaMental:
        return 'Criar Mapa Mental';
      case TipoAcao.irParaDiagramaFluxo:
        return 'Criar Diagrama de Fluxo';
      case TipoAcao.irParaSimulado:
        return 'Ir para Simulado';
      case TipoAcao.apenasInstrucoes:
      default:
        return 'Entendi';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color headerBg = inteligencia.cor;
    final Color textColor = getTextColorForBackground(headerBg);
    final Color pageBg = isDark ? const Color(0xff121212) : const Color(0xfff4f1eb);
    final Color cardBg = isDark ? const Color(0xff1e1e1e) : Colors.white;
    final Color bodyTextColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: headerBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          metodo.titulo,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: textColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Colorido do Método
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                color: headerBg,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: textColor == Colors.white
                              ? Colors.white.withValues(alpha: 0.2)
                              : Colors.black.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(metodo.icone, color: textColor, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              metodo.titulo,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                // Badge Tempo
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.access_time, size: 12, color: textColor),
                                      const SizedBox(width: 4),
                                      Text(
                                        metodo.tempo,
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Badge Dificuldade
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: getDificuldadeColor(metodo.dificuldade, isBackground: true),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    metodo.dificuldade,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: getDificuldadeColor(metodo.dificuldade, isBackground: false),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Descrição
                  Text(
                    "O que é este método?",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: bodyTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                    ),
                    child: Text(
                      metodo.descricao,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        height: 1.5,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Passo a Passo
                  Text(
                    "Passo a Passo",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: bodyTextColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    children: List.generate(metodo.passos.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: headerBg,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    "${index + 1}",
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 3.0),
                                  child: Text(
                                    metodo.passos[index],
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 13,
                                      height: 1.4,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 16),

                  // Benefícios
                  if (metodo.beneficios.isNotEmpty) ...[
                    Text(
                      "Benefícios",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: bodyTextColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xff143522) : const Color(0xFFf0fdf4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.green.withValues(alpha: 0.3) : const Color(0xFFbbf7d0),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: metodo.beneficios.map((b) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3.0),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle, size: 16, color: Color(0xFF16a34a)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    b,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? Colors.greenAccent : const Color(0xFF166534),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],

                  // Dica Amarela se o método tiver ação
                  if (metodo.tipoAcao != TipoAcao.apenasInstrucoes) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xff3d3215) : const Color(0xFFfffbe6),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? Colors.amber.withValues(alpha: 0.3) : const Color(0xFFffe58f),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: isDark ? Colors.amberAccent : const Color(0xFFd48806),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Toque no botão abaixo para ser direcionado à tela dessa ferramenta no aplicativo!",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: isDark ? Colors.amberAccent : const Color(0xFFd48806),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),

      // Botão Fixo no Rodapé
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () => _executarAcao(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: headerBg,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
            child: Text(
              _getBotaoTexto(),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
