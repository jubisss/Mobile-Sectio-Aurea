import 'package:flutter/material.dart';
import 'package:sectio_aurea/services/database_service.dart';
import 'package:sectio_aurea/widgets/botao.dart';
import 'package:sectio_aurea/widgets/campo_texto.dart';

class GruposEstudoScreen extends StatefulWidget {
  final Map<String, dynamic> u;

  const GruposEstudoScreen({super.key, required this.u});

  @override
  State<GruposEstudoScreen> createState() => _GruposEstudoScreenState();
}

class _GruposEstudoScreenState extends State<GruposEstudoScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _membersController = TextEditingController();
  final TextEditingController _topicsController = TextEditingController();
  final TextEditingController _meetingDateController = TextEditingController();

  bool _isSaving = false;

  void _salvarGrupoComoNota() async {
    String nomeGrupo = _groupNameController.text.trim();
    String membros = _membersController.text.trim();
    String topicos = _topicsController.text.trim();
    String reuniao = _meetingDateController.text.trim();

    if (nomeGrupo.isEmpty) {
      nomeGrupo = "Grupo de Estudos";
    }

    String conteudoNota = "👥 GRUPO DE ESTUDOS: $nomeGrupo\n\n"
        "📌 Integrantes:\n${membros.isEmpty ? 'Não especificado' : membros}\n\n"
        "🎯 Tópicos/Tarefas de cada membro:\n${topicos.isEmpty ? 'Não especificado' : topicos}\n\n"
        "📅 Próximo Encontro:\n${reuniao.isEmpty ? 'A definir' : reuniao}";

    setState(() {
      _isSaving = true;
    });

    int userId = widget.u["id_usuario"] ?? 1;
    int noteId = await DatabaseService().createNote(
      conteudoNota,
      "0xffff5f00", // Cor Laranja Interpessoal
      userId,
    );

    setState(() {
      _isSaving = false;
    });

    if (noteId > 0 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Grupo salvo como anotação no seu perfil!")),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao salvar informações do grupo.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    const Color headerBg = Color(0xFFff5f00); // Cor da Inteligência Interpessoal
    final Color pageBg = isDark ? const Color(0xff121212) : const Color(0xfff4f1eb);
    final Color cardBg = isDark ? const Color(0xff1e1e1e) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: headerBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Grupos de Estudo",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: headerBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.groups, color: Colors.white, size: 40),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Aprendizado Colaborativo",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Reúna colegas para discutir matérias, tirar dúvidas e ensinar uns aos outros.",
                          style: TextStyle(
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

            // Dicas de Otimização do Grupo
            Text(
              "Boas Práticas para Grupos Eficientes:",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: textColor,
              ),
            ),
            const SizedBox(height: 10),

            _buildTipRow(
              icon: Icons.person_add_alt_1,
              title: "Tamanho Ideal",
              desc: "Mantenha o grupo pequeno (3 a 5 participantes) para garantir engajamento de todos.",
              isDark: isDark,
              cardBg: cardBg,
              textColor: textColor,
            ),
            _buildTipRow(
              icon: Icons.view_kanban,
              title: "Divisão de Tarefas",
              desc: "Cada participante prepara um tópico específico da matéria e explica aos demais.",
              isDark: isDark,
              cardBg: cardBg,
              textColor: textColor,
            ),
            _buildTipRow(
              icon: Icons.forum,
              title: "Ferramentas Úteis",
              desc: "Utilizem o Discord, Google Meet ou WhatsApp para chamadas e troca de arquivos.",
              isDark: isDark,
              cardBg: cardBg,
              textColor: textColor,
            ),

            const SizedBox(height: 24),

            // Formulário de Registro do Grupo
            Text(
              "Organizar Meu Grupo de Estudos:",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
              ),
              child: Column(
                children: [
                  CampoTexto(
                    labelText: "Nome do Grupo / Matéria",
                    controller: _groupNameController,
                    obscureText: false,
                    prefixIcon: Icons.group_work_outlined,
                  ),
                  const SizedBox(height: 12),
                  CampoTexto(
                    labelText: "Integrantes (nomes/e-mails)",
                    controller: _membersController,
                    obscureText: false,
                    prefixIcon: Icons.people_outline,
                  ),
                  const SizedBox(height: 12),
                  CampoTexto(
                    labelText: "Divisão de Tópicos",
                    controller: _topicsController,
                    obscureText: false,
                    prefixIcon: Icons.assignment_outlined,
                    helperText: "Ex: Ana (Cap 1), Bruno (Cap 2)",
                  ),
                  const SizedBox(height: 12),
                  CampoTexto(
                    labelText: "Data / Horário do Encontro",
                    controller: _meetingDateController,
                    obscureText: false,
                    prefixIcon: Icons.calendar_today_outlined,
                  ),
                  const SizedBox(height: 20),

                  Botao(
                    texto: _isSaving ? "Salvando..." : "Salvar Grupo no Perfil",
                    funcao: _isSaving ? () {} : _salvarGrupoComoNota,
                    cor: headerBg,
                    corTexto: Colors.white,
                    width: double.infinity,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTipRow({
    required IconData icon,
    required String title,
    required String desc,
    required bool isDark,
    required Color cardBg,
    required Color textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFff5f00).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFFff5f00), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
