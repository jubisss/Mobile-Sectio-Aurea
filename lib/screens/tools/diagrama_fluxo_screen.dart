import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sectio_aurea/services/tool_storage_service.dart';

enum FlowNodeType { inicio, processo, decisao, fim }

class FlowNode {
  String id;
  String title;
  FlowNodeType type;
  Offset position;

  FlowNode({
    required this.id,
    required this.title,
    required this.type,
    required this.position,
  });

  Color get color {
    switch (type) {
      case FlowNodeType.inicio:
        return const Color(0xFF22c55e); // Verde
      case FlowNodeType.processo:
        return const Color(0xFF3b82f6); // Azul
      case FlowNodeType.decisao:
        return const Color(0xFFeab308); // Amarelo
      case FlowNodeType.fim:
        return const Color(0xFFef4444); // Vermelho
    }
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "type": type.name,
        "dx": position.dx,
        "dy": position.dy,
      };

  factory FlowNode.fromJson(Map<String, dynamic> json) => FlowNode(
        id: json["id"] ?? "",
        title: json["title"] ?? "",
        type: FlowNodeType.values.firstWhere(
          (t) => t.name == json["type"],
          orElse: () => FlowNodeType.processo,
        ),
        position: Offset((json["dx"] as num?)?.toDouble() ?? 100.0, (json["dy"] as num?)?.toDouble() ?? 100.0),
      );
}

class FlowConnection {
  String fromId;
  String toId;
  String label;

  FlowConnection({required this.fromId, required this.toId, this.label = ''});

  Map<String, dynamic> toJson() => {
        "fromId": fromId,
        "toId": toId,
        "label": label,
      };

  factory FlowConnection.fromJson(Map<String, dynamic> json) => FlowConnection(
        fromId: json["fromId"] ?? "",
        toId: json["toId"] ?? "",
        label: json["label"] ?? "",
      );
}

class DiagramaFluxoScreen extends StatefulWidget {
  final Map<String, dynamic> u;

  const DiagramaFluxoScreen({super.key, required this.u});

  @override
  State<DiagramaFluxoScreen> createState() => _DiagramaFluxoScreenState();
}

class _DiagramaFluxoScreenState extends State<DiagramaFluxoScreen> {
  final TextEditingController _diagramNameController = TextEditingController(text: "Novo Diagrama de Fluxo");
  final List<FlowNode> _nodes = [];
  final List<FlowConnection> _connections = [];

  List<Map<String, dynamic>> _savedDiagrams = [];
  FlowNode? _selectedForConnection;

  @override
  void initState() {
    super.initState();
    _loadSavedDiagrams();
  }

  @override
  void dispose() {
    _diagramNameController.dispose();
    super.dispose();
  }

  Color _getPrimaryColor() {
    String? hex = widget.u["clas_inteli"];
    if (hex != null && hex.isNotEmpty) {
      try {
        return Color(int.parse(hex));
      } catch (_) {}
    }
    return const Color(0xFFffbd59);
  }

  String _getStorageKey() {
    int userId = widget.u["id_usuario"] ?? 1;
    return "PI_DiagramaFluxo_User_$userId";
  }

  Future<void> _loadSavedDiagrams() async {
    String? raw = await ToolStorageService.getString(_getStorageKey());
    if (raw != null && raw.isNotEmpty) {
      try {
        List<dynamic> list = jsonDecode(raw);
        if (mounted) {
          setState(() {
            _savedDiagrams = list.cast<Map<String, dynamic>>();
          });
        }
      } catch (_) {}
    }
  }

  void _saveCurrentDiagram() async {
    String title = _diagramNameController.text.trim();
    if (title.isEmpty) title = "Meu Diagrama de Fluxo";

    List<Map<String, dynamic>> nodesJson = _nodes.map((n) => n.toJson()).toList();
    List<Map<String, dynamic>> connsJson = _connections.map((c) => c.toJson()).toList();

    Map<String, dynamic> diagObj = {
      "id": DateTime.now().millisecondsSinceEpoch.toString(),
      "title": title,
      "date": "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
      "nodes": nodesJson,
      "conns": connsJson,
    };

    List<Map<String, dynamic>> diagrams = List.from(_savedDiagrams);
    int existingIdx = diagrams.indexWhere((d) => d["title"] == title);
    if (existingIdx != -1) {
      diagrams[existingIdx] = diagObj;
    } else {
      diagrams.add(diagObj);
    }

    await ToolStorageService.setString(_getStorageKey(), jsonEncode(diagrams));
    if (mounted) {
      setState(() {
        _savedDiagrams = diagrams;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Diagrama salvo no repositório de diagramas!")));
    }
  }

  void _deleteDiagram(String id) async {
    List<Map<String, dynamic>> diagrams = List.from(_savedDiagrams);
    diagrams.removeWhere((d) => d["id"] == id);
    await ToolStorageService.setString(_getStorageKey(), jsonEncode(diagrams));
    if (mounted) {
      setState(() {
        _savedDiagrams = diagrams;
      });
    }
  }

  void _loadDiagramIntoCanvas(Map<String, dynamic> diagObj) {
    try {
      List<dynamic> nodesList = diagObj["nodes"] ?? [];
      List<dynamic> connsList = diagObj["conns"] ?? [];

      setState(() {
        _diagramNameController.text = diagObj["title"] ?? "Diagrama de Fluxo";
        _nodes.clear();
        _connections.clear();
        for (var item in nodesList) {
          _nodes.add(FlowNode.fromJson(item));
        }
        for (var item in connsList) {
          _connections.add(FlowConnection.fromJson(item));
        }
      });
      Navigator.pop(context);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao carregar diagrama de fluxo.")));
    }
  }

  void _showSavedDiagramsModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        final Color cardBg = isDark ? const Color(0xff1e1e1e) : Colors.white;
        final Color textColor = isDark ? Colors.white : Colors.black87;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Meus Diagramas de Fluxo Salvos", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
              const SizedBox(height: 12),
              _savedDiagrams.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: Text("Nenhum diagrama salvo ainda.", style: TextStyle(fontFamily: 'Poppins', color: Colors.grey))),
                    )
                  : SizedBox(
                      height: 250,
                      child: ListView.builder(
                        itemCount: _savedDiagrams.length,
                        itemBuilder: (context, idx) {
                          final d = _savedDiagrams[idx];
                          return Card(
                            color: cardBg,
                            child: ListTile(
                              leading: Icon(Icons.schema, color: _getPrimaryColor()),
                              title: Text(d["title"] ?? "Diagrama", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 13, color: textColor)),
                              subtitle: Text("Salvo em ${d['date'] ?? ''}", style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.grey)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(icon: const Icon(Icons.download, color: Colors.blueAccent), onPressed: () => _loadDiagramIntoCanvas(d)),
                                  IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: () => _deleteDiagram(d["id"])),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }

  void _addNode(FlowNodeType type) {
    setState(() {
      String id = DateTime.now().millisecondsSinceEpoch.toString();
      _nodes.add(FlowNode(
        id: id,
        title: type == FlowNodeType.inicio
            ? 'Início'
            : type == FlowNodeType.processo
                ? 'Processo'
                : type == FlowNodeType.decisao
                    ? 'Decisão'
                    : 'Fim',
        type: type,
        position: Offset(100.0 + (_nodes.length * 20), 120.0 + (_nodes.length * 30)),
      ));
    });
  }

  void _editNodeModal(FlowNode node) {
    final titleCtrl = TextEditingController(text: node.title);
    FlowNodeType selectedType = node.type;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Editar Processo", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Título:", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 4),
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
              ),
              const SizedBox(height: 10),
              const Text("Tipo:", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 4),
              DropdownButton<FlowNodeType>(
                value: selectedType,
                isExpanded: true,
                items: [
                  const DropdownMenuItem(value: FlowNodeType.inicio, child: Text("🟢 Início")),
                  const DropdownMenuItem(value: FlowNodeType.processo, child: Text("🔵 Processo")),
                  const DropdownMenuItem(value: FlowNodeType.decisao, child: Text("🟡 Decisão")),
                  const DropdownMenuItem(value: FlowNodeType.fim, child: Text("🔴 Fim")),
                ],
                onChanged: (v) {
                  if (v != null) setDialogState(() => selectedType = v);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _getPrimaryColor()),
              onPressed: () {
                setState(() {
                  node.title = titleCtrl.text.trim();
                  node.type = selectedType;
                });
                Navigator.pop(context);
              },
              child: const Text("Salvar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showArrowLabelModal(FlowNode from, FlowNode to) {
    final labelCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Label da seta", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("De \"${from.title}\" para \"${to.title}\"", style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 10),
            TextField(
              controller: labelCtrl,
              decoration: InputDecoration(
                hintText: "Ex: Sim, Não, Próximo passo...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _getPrimaryColor()),
            onPressed: () {
              setState(() {
                _connections.add(FlowConnection(fromId: from.id, toId: to.id, label: labelCtrl.text.trim()));
                _selectedForConnection = null;
              });
              Navigator.pop(context);
            },
            child: const Text("Conectar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          "Diagrama de Fluxos",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: _saveCurrentDiagram,
          ),
          IconButton(
            icon: const Icon(Icons.folder_open, color: Colors.white),
            onPressed: _showSavedDiagramsModal,
          ),
        ],
      ),
      body: Column(
        children: [
          // Title Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: cardBg,
            child: TextField(
              controller: _diagramNameController,
              decoration: InputDecoration(
                labelText: "Título do Diagrama de Fluxos",
                labelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: primaryColor),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              ),
              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 13, color: textColor),
            ),
          ),

          // Top Buttons bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: cardBg,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () => _addNode(FlowNodeType.inicio),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22c55e)),
                    child: const Text("🟢 Início", style: TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 6),
                  ElevatedButton(
                    onPressed: () => _addNode(FlowNodeType.processo),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3b82f6)),
                    child: const Text("🔵 Processo", style: TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 6),
                  ElevatedButton(
                    onPressed: () => _addNode(FlowNodeType.decisao),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFeab308)),
                    child: const Text("🟡 Decisão", style: TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 6),
                  ElevatedButton(
                    onPressed: () => _addNode(FlowNodeType.fim),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFef4444)),
                    child: const Text("🔴 Fim", style: TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                    onPressed: () {
                      setState(() {
                        _nodes.clear();
                        _connections.clear();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          // Canvas
          Expanded(
            child: Container(
              color: pageBg,
              width: double.infinity,
              height: double.infinity,
              child: _nodes.isEmpty
                  ? Center(
                      child: Text(
                        "Diagrama vazio.\nToque nos botões acima para adicionar processos!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                    )
                  : RepaintBoundary(
                      child: Stack(
                        children: [
                          CustomPaint(
                            size: Size.infinite,
                            painter: FlowLinePainter(
                              nodes: _nodes,
                              connections: _connections,
                            ),
                          ),

                          // Nodes
                          ..._nodes.map((node) {
                            bool isSel = _selectedForConnection?.id == node.id;
                            bool isDiamond = node.type == FlowNodeType.decisao;

                            return Positioned(
                              left: node.position.dx,
                              top: node.position.dy,
                              child: GestureDetector(
                                onPanUpdate: (details) {
                                  setState(() {
                                    node.position += details.delta;
                                  });
                                },
                                onTap: () {
                                  if (_selectedForConnection == null) {
                                    setState(() => _selectedForConnection = node);
                                  } else if (_selectedForConnection!.id != node.id) {
                                    _showArrowLabelModal(_selectedForConnection!, node);
                                  } else {
                                    setState(() => _selectedForConnection = null);
                                  }
                                },
                                child: isDiamond
                                    ? ClipPath(
                                        clipper: DiamondClipper(),
                                        child: Container(
                                          width: 110,
                                          height: 70,
                                          color: node.color,
                                          child: Stack(
                                            children: [
                                              Center(
                                                child: Text(
                                                  node.title,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 11,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                right: 15,
                                                top: 20,
                                                child: InkWell(
                                                  onTap: () => _editNodeModal(node),
                                                  child: Container(
                                                    padding: const EdgeInsets.all(2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.black26,
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: const Icon(Icons.edit, size: 12, color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: node.color,
                                          borderRadius: BorderRadius.circular(
                                            node.type == FlowNodeType.inicio || node.type == FlowNodeType.fim ? 24 : 10,
                                          ),
                                          border: isSel ? Border.all(color: textColor, width: 2.5) : null,
                                          boxShadow: [
                                            BoxShadow(
                                              color: node.color.withValues(alpha: 0.3),
                                              blurRadius: 6,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              node.title,
                                              style: const TextStyle(
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            InkWell(
                                              onTap: () => _editNodeModal(node),
                                              child: Container(
                                                padding: const EdgeInsets.all(2),
                                                decoration: BoxDecoration(
                                                  color: Colors.black26,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: const Icon(Icons.edit, size: 14, color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class DiamondClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width / 2, 0); // Top
    path.lineTo(size.width, size.height / 2); // Right
    path.lineTo(size.width / 2, size.height); // Bottom
    path.lineTo(0, size.height / 2); // Left
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class FlowLinePainter extends CustomPainter {
  final List<FlowNode> nodes;
  final List<FlowConnection> connections;

  FlowLinePainter({required this.nodes, required this.connections});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (var conn in connections) {
      final fromNode = nodes.firstWhere((n) => n.id == conn.fromId, orElse: () => nodes.first);
      final toNode = nodes.firstWhere((n) => n.id == conn.toId, orElse: () => nodes.first);

      final p1 = fromNode.position + const Offset(40, 18);
      final p2 = toNode.position + const Offset(40, 18);

      canvas.drawLine(p1, p2, paint);

      if (conn.label.isNotEmpty) {
        final mid = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
        TextPainter tp = TextPainter(
          text: TextSpan(text: conn.label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 10, color: Colors.black87, backgroundColor: Colors.white70)),
          textDirection: TextDirection.ltr,
        );
        tp.layout();
        tp.paint(canvas, mid - Offset(tp.width / 2, tp.height / 2));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
