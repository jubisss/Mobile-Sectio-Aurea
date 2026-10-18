import 'package:flutter/material.dart';
import 'package:sectio_aurea/services/banco_dados.dart';

void mostrarDialogoPlanos(
  BuildContext context,
  Map<String, dynamic> user, {
  Function(Map<String, dynamic>)? onPlanUpdated,
}) {
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          String currentPlan = user['plano'] ?? 'Gratuito';
          final bool isDark = Theme.of(context).brightness == Brightness.dark;

          void onPlanSelected(String name) {
            if (currentPlan.toLowerCase() == name.toLowerCase()) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  content: Text("Você já possui o plano $name ativo.", style: const TextStyle(fontFamily: 'Poppins')),
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

            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                title: const Text("Confirmar Assinatura", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                content: Text("Deseja mesmo assinar o plano $name?", style: const TextStyle(fontFamily: 'Poppins')),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text("Não", style: TextStyle(color: isDark ? Colors.white60 : Colors.black54)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.tealAccent : const Color(0xff00bf63),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      Navigator.pop(ctx);

                      final updated = Map<String, dynamic>.from(user);
                      updated["plano"] = name;

                      bool ok = await DatabaseService().updateUser(updated);
                      if (ok) {
                        user["plano"] = name;
                        if (onPlanUpdated != null) {
                          onPlanUpdated(updated);
                        }
                        setDialogState(() {
                          currentPlan = name;
                        });
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Plano atualizado para $name com sucesso!")),
                          );
                        }
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Falha ao atualizar plano. Tente novamente.")),
                          );
                        }
                      }
                    },
                    child: Text("Sim, Assinar", style: TextStyle(color: isDark ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          }

          Widget buildCard(String name, String price, List<String> features, bool isCurrent) {
            final Color cardBgColor = isCurrent
                ? const Color(0xff00bf63).withValues(alpha: 0.1)
                : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.02));

            return GestureDetector(
              onTap: () => onPlanSelected(name),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isCurrent ? const Color(0xff00bf63) : (isDark ? Colors.white12 : Colors.black12),
                    width: isCurrent ? 2 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          name.toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        if (isCurrent)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xff00bf63),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              "ATUAL",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      price,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xff00bf63),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...features.map((f) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            children: [
                              const Icon(Icons.check, size: 14, color: Color(0xff00bf63)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  f,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 11,
                                    color: isDark ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            );
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Text("Planos de Assinatura", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 18)),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildCard(
                      "Gratuito",
                      "R\$ 0",
                      ["Revisão de conteúdos e flashcards", "Temporizador simples"],
                      currentPlan.toLowerCase() == 'gratuito',
                    ),
                    buildCard(
                      "Básico",
                      "R\$ 19/mês",
                      [
                        "Revisão de conteúdos",
                        "Personalização no guia de estudos",
                        "Edição do tempo pomodoro",
                        "Cronograma inteligente",
                        "Estatísticas mensais e semanais",
                      ],
                      currentPlan.toLowerCase() == 'básico' || currentPlan.toLowerCase() == 'basico',
                    ),
                    buildCard(
                      "Pro",
                      "R\$ 39/mês",
                      [
                        "Todos os benefícios do Básico",
                        "Ferramentas avançadas liberadas",
                        "Simulados ilimitados",
                        "Anotações Cornell e Diagramas ilimitados",
                        "Suporte prioritário",
                      ],
                      currentPlan.toLowerCase() == 'pro',
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Fechar", style: TextStyle(color: isDark ? Colors.tealAccent : Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      );
    },
  );
}
