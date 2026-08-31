import 'dart:math';
import 'package:flutter/material.dart';

class GruposEstudoHubScreen extends StatefulWidget {
  final Map<String, dynamic> u;

  const GruposEstudoHubScreen({super.key, required this.u});

  @override
  State<GruposEstudoHubScreen> createState() => _GruposEstudoHubScreenState();
}

class _GruposEstudoHubScreenState extends State<GruposEstudoHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  Map<String, dynamic>? _activeGroup;
  List<String> _membros = [];
  List<Map<String, String>> _temas = [];
  List<Map<String, String>> _duvidas = [];
  final TextEditingController _notasController = TextEditingController();
  List<Map<String, String>> _reunioes = [];
  List<Map<String, String>> _groupFlashcards = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  Color _getPrimaryColor() {
    String? hex = widget.u["clas_inteli"];
    if (hex != null && hex.isNotEmpty) {
      try {
        return Color(int.parse(hex));
      } catch (_) {}
    }
    return const Color(0xFFff5f00);
  }

  String _generateGroupCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  void _showCriarGrupoDialog() {
    final nameController = TextEditingController();
    final subjectController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Criar Grupo de Estudo", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: "Nome do grupo",
                hintStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: subjectController,
              decoration: InputDecoration(
                hintText: "Matéria principal (opcional)",
                hintStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _getPrimaryColor()),
            onPressed: () {
              String name = nameController.text.trim();
              if (name.isEmpty) name = "Meu Grupo";

              String code = _generateGroupCode();
              Navigator.pop(context);
              _showGrupoCriadoSuccessModal(name, code);
            },
            child: const Text("Criar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showGrupoCriadoSuccessModal(String name, String code) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundColor: Color(0xFFdcfce7),
              child: Icon(Icons.check, color: Color(0xFF16a34a), size: 36),
            ),
            const SizedBox(height: 14),
            const Text(
              "Grupo criado!",
              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              "Código do grupo: $code",
              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 15, color: _getPrimaryColor()),
            ),
            const SizedBox(height: 4),
            const Text(
              "Compartilhe este código com seus amigos!",
              style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Código $code copiado!")),
                );
              },
              icon: const Icon(Icons.copy, color: Colors.white, size: 16),
              label: const Text("Copiar Código", style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getPrimaryColor(),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _activeGroup = {
                      "name": name,
                      "code": code,
                    };
                    _membros = [widget.u["nome"] ?? "Você (Criador)"];
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getPrimaryColor(),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("OK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEntrarComCodigoDialog() {
    final codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Entrar no Grupo", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16)),
        content: TextField(
          controller: codeController,
          decoration: InputDecoration(
            hintText: "Digite o código do grupo",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _getPrimaryColor()),
            onPressed: () {
              String code = codeController.text.trim().toUpperCase();
              if (code.isNotEmpty) {
                Navigator.pop(context);
                setState(() {
                  _activeGroup = {
                    "name": "Grupo $code",
                    "code": code,
                  };
                  _membros = [widget.u["nome"] ?? "Você"];
                });
              }
            },
            child: const Text("Entrar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showChamadaVideoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Chamada de Vídeo", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16)),
        content: const Text("Deseja abrir o Google Meet?", style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22c55e)),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Abrindo Google Meet...")));
            },
            child: const Text("Abrir Meet", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Local creation modals
  void _showAdicionarMembroDialog() {
    final memberController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Adicionar Membro", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16)),
        content: TextField(
          controller: memberController,
          decoration: InputDecoration(hintText: "Nome do membro", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _getPrimaryColor()),
            onPressed: () {
              String name = memberController.text.trim();
              if (name.isNotEmpty) {
                setState(() => _membros.add(name));
                Navigator.pop(context);
              }
            },
            child: const Text("Adicionar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCriarTemaDialog() {
    final topicCtrl = TextEditingController();
    final respCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Adicionar Tema", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: topicCtrl,
              decoration: InputDecoration(hintText: "Tema (ex: Citologia)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: respCtrl,
              decoration: InputDecoration(hintText: "Responsável (nome)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _getPrimaryColor()),
            onPressed: () {
              String topic = topicCtrl.text.trim();
              String resp = respCtrl.text.trim();
              if (topic.isNotEmpty) {
                setState(() => _temas.add({"topic": topic, "resp": resp.isEmpty ? "Todos" : resp}));
                Navigator.pop(context);
              }
            },
            child: const Text("Adicionar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCriarDuvidaDialog() {
    final textCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Nova Dúvida", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16)),
        content: TextField(
          controller: textCtrl,
          decoration: InputDecoration(hintText: "Digite sua dúvida...", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _getPrimaryColor()),
            onPressed: () {
              String q = textCtrl.text.trim();
              if (q.isNotEmpty) {
                setState(() => _duvidas.add({"question": q, "author": widget.u["nome"] ?? "Você"}));
                Navigator.pop(context);
              }
            },
            child: const Text("Perguntar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAgendarReuniaoDialog() {
    final titleCtrl = TextEditingController();
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Agendar Reunião", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(hintText: "Título da reunião", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (d != null) {
                          setDialogState(() => selectedDate = d);
                        }
                      },
                      icon: const Icon(Icons.calendar_today, size: 14, color: Colors.white),
                      label: Text(
                        selectedDate == null ? "Data" : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'Poppins'),
                      ),
                      style: ElevatedButton.styleFrom(backgroundColor: _getPrimaryColor()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final t = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (t != null) {
                          setDialogState(() => selectedTime = t);
                        }
                      },
                      icon: const Icon(Icons.access_time, size: 14, color: Colors.white),
                      label: Text(
                        selectedTime == null ? "Hora" : selectedTime!.format(context),
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'Poppins'),
                      ),
                      style: ElevatedButton.styleFrom(backgroundColor: _getPrimaryColor()),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _getPrimaryColor()),
              onPressed: () {
                String title = titleCtrl.text.trim();
                if (title.isNotEmpty) {
                  String dateStr = selectedDate != null
                      ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year} ${selectedTime != null ? selectedTime!.format(context) : ''}"
                      : "Em breve";
                  setState(() => _reunioes.add({"title": title, "date": dateStr}));
                  Navigator.pop(context);
                }
              },
              child: const Text("Agendar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showCriarFlashcardGrupoDialog() {
    final qCtrl = TextEditingController();
    final aCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Criar Flashcard do Grupo", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qCtrl,
              decoration: InputDecoration(hintText: "Pergunta", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: aCtrl,
              decoration: InputDecoration(hintText: "Resposta", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _getPrimaryColor()),
            onPressed: () {
              String q = qCtrl.text.trim();
              String a = aCtrl.text.trim();
              if (q.isNotEmpty && a.isNotEmpty) {
                setState(() => _groupFlashcards.add({"question": q, "answer": a}));
                Navigator.pop(context);
              }
            },
            child: const Text("Salvar Flashcard", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = _getPrimaryColor();
    final Color pageBg = isDark ? const Color(0xff121212) : const Color(0xfff4f1eb);
    final Color cardBg = isDark ? const Color(0xff1e1e1e) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: primaryColor,
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
      body: _activeGroup == null
          ? _buildNoGroupView(primaryColor, cardBg, textColor, isDark)
          : _buildGroupDashboardView(primaryColor, cardBg, textColor, isDark),
    );
  }

  Widget _buildNoGroupView(Color primaryColor, Color cardBg, Color textColor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.groups_outlined, size: 70, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            "Nenhum grupo criado",
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 18, color: textColor),
          ),
          const SizedBox(height: 6),
          const Text(
            "Crie um grupo ou entre com um código de convite",
            style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton.icon(
                onPressed: _showCriarGrupoDialog,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text("Criar Grupo", style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showEntrarComCodigoDialog,
                icon: const Icon(Icons.login, color: Colors.white),
                label: const Text("Entrar com Código", style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3b82f6),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGroupDashboardView(Color primaryColor, Color cardBg, Color textColor, bool isDark) {
    return Column(
      children: [
        // Group Header Info
        Container(
          padding: const EdgeInsets.all(16),
          color: cardBg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _activeGroup!["name"],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 18, color: textColor),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _showChamadaVideoDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22c55e),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Chamada de Vídeo", style: TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              Text(
                "Código: ${_activeGroup!["code"]}",
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),

        // Abas
        TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: primaryColor,
          unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
          indicatorColor: primaryColor,
          tabs: [
            Tab(text: "Membros (${_membros.length})"),
            Tab(text: "Temas (${_temas.length})"),
            Tab(text: "Dúvidas (${_duvidas.length})"),
            const Tab(text: "Notas"),
            Tab(text: "Reuniões (${_reunioes.length})"),
            Tab(text: "Flashcards (${_groupFlashcards.length})"),
          ],
        ),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Aba 1: Membros
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Membros do Grupo", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 14)),
                        ElevatedButton(
                          onPressed: _showAdicionarMembroDialog,
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22c55e)),
                          child: const Text("Adicionar", style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Poppins')),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _membros.length,
                        itemBuilder: (context, idx) {
                          return Card(
                            color: cardBg,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: primaryColor,
                                child: Text(_membros[idx][0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                              title: Text(_membros[idx], style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 13, color: textColor)),
                              subtitle: Text(idx == 0 ? "Líder / Criador" : "Membro", style: const TextStyle(fontFamily: 'Poppins', fontSize: 11)),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Aba 2: Temas
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Temas do Grupo", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 14)),
                        ElevatedButton(
                          onPressed: _showCriarTemaDialog,
                          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                          child: const Text("Criar Tema", style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Poppins')),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: _temas.isEmpty
                          ? const Center(child: Text("Nenhum tema criado ainda.", style: TextStyle(fontFamily: 'Poppins', color: Colors.grey)))
                          : ListView.builder(
                              itemCount: _temas.length,
                              itemBuilder: (context, idx) {
                                final t = _temas[idx];
                                return Card(
                                  color: cardBg,
                                  child: ListTile(
                                    title: Text(t["topic"]!, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 13, color: textColor)),
                                    subtitle: Text("Responsável: ${t["resp"]}", style: const TextStyle(fontFamily: 'Poppins', fontSize: 11)),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),

              // Aba 3: Dúvidas
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Quadro de Dúvidas", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 14)),
                        ElevatedButton(
                          onPressed: _showCriarDuvidaDialog,
                          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                          child: const Text("Nova Dúvida", style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Poppins')),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: _duvidas.isEmpty
                          ? const Center(child: Text("Quadro de dúvidas vazio.", style: TextStyle(fontFamily: 'Poppins', color: Colors.grey)))
                          : ListView.builder(
                              itemCount: _duvidas.length,
                              itemBuilder: (context, idx) {
                                final d = _duvidas[idx];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xff3d3215) : const Color(0xFFfffbe6),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(d["question"]!, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFd48806))),
                                      Text("Por: ${d["author"]}", style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.grey)),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),

              // Aba 4: Notas do Grupo
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    TextField(
                      controller: _notasController,
                      maxLines: 8,
                      decoration: InputDecoration(
                        hintText: "Escreva as anotações do grupo...",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: cardBg,
                      ),
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: textColor),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22c55e)),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Notas salvas no grupo!")));
                      },
                      child: const Text("Salvar Notas", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),

              // Aba 5: Reuniões
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Reuniões Agendadas", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 14)),
                        ElevatedButton(
                          onPressed: _showAgendarReuniaoDialog,
                          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                          child: const Text("Agendar", style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Poppins')),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: _reunioes.isEmpty
                          ? const Center(child: Text("Nenhuma reunião agendada.", style: TextStyle(fontFamily: 'Poppins', color: Colors.grey)))
                          : ListView.builder(
                              itemCount: _reunioes.length,
                              itemBuilder: (context, idx) {
                                final r = _reunioes[idx];
                                return Card(
                                  color: cardBg,
                                  child: ListTile(
                                    title: Text(r["title"]!, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 13, color: textColor)),
                                    subtitle: Text("Data: ${r["date"]}", style: const TextStyle(fontFamily: 'Poppins', fontSize: 11)),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),

              // Aba 6: Flashcards do Grupo
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Flashcards do Grupo", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 14)),
                        ElevatedButton(
                          onPressed: _showCriarFlashcardGrupoDialog,
                          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                          child: const Text("Criar Flashcard", style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Poppins')),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: _groupFlashcards.isEmpty
                          ? const Center(child: Text("Nenhum flashcard compartilhado neste grupo.", style: TextStyle(fontFamily: 'Poppins', color: Colors.grey)))
                          : ListView.builder(
                              itemCount: _groupFlashcards.length,
                              itemBuilder: (context, idx) {
                                final f = _groupFlashcards[idx];
                                return Card(
                                  color: cardBg,
                                  child: ListTile(
                                    title: Text(f["question"]!, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 13, color: textColor)),
                                    subtitle: Text("Resposta: ${f["answer"]}", style: const TextStyle(fontFamily: 'Poppins', fontSize: 11)),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
