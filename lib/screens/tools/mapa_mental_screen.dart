import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sectio_aurea/services/tool_storage_service.dart';

class MindMapNode {
  String id;
  String title;
  String notes;
  Offset position;
  Color color;
  bool isCentral;

  MindMapNode({
    required this.id,
    required this.title,
    this.notes = '',
    required this.position,
    required this.color,
    this.isCentral = false,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "notes": notes,
        "dx": position.dx,
        "dy": position.dy,
        "color": color.value,
        "isCentral": isCentral,
      };

  factory MindMapNode.fromJson(Map<String, dynamic> json) => MindMapNode(
        id: json["id"] ?? "",
        title: json["title"] ?? "",
        notes: json["notes"] ?? "",
        position: Offset((json["dx"] as num?)?.toDouble() ?? 100.0, (json["dy"] as num?)?.toDouble() ?? 100.0),
        color: Color(json["color"] ?? 0xFFffbd59),
        isCentral: json["isCentral"] ?? false,
      );
}

class MapaMentalScreen extends StatefulWidget {
  final Map<String, dynamic> u;

  const MapaMentalScreen({super.key, required this.u});

  @override
  State<MapaMentalScreen> createState() => _MapaMentalScreenState();
}

class _MapaMentalScreenState extends State<MapaMentalScreen> {
  final TextEditingController _mapNameController = TextEditingController(text: "Meu Mapa Mental");
  final List<MindMapNode> _nodes = [];
  List<Map<String, dynamic>> _savedMaps = [];

  final List<Color> _palette = const [
    Color(0xFFffbd59),
    Color(0xFF3b82f6),
    Color(0xFF10b981),
    Color(0xFFef4444),
    Color(0xFF8b5cf6),
    Color(0xFFec4899),
  ];

  @override
  void initState() {
    super.initState();
    _initDefaultMap();
    _loadSavedMaps();
  }

  @override
  void dispose() {
    _mapNameController.dispose();
    super.dispose();
  }

  Color _getPrimaryColor() {
    String? hex = widget.u["clas_inteli"];
    if (hex != null && hex.isNotEmpty) {
      try {
        String clean = hex.replaceAll('#', '').replaceAll('0x', '');
        if (clean.length == 6) clean = 'FF$clean';
        return Color(int.parse(clean, radix: 16));
      } catch (_) {}
    }
    return const Color(0xFFffbd59);
  }

  void _initDefaultMap() {
    _nodes.clear();
    _nodes.add(MindMapNode(
      id: 'central',
      title: 'Tema Central',
      notes: 'Clique duas vezes ou no lápis ✏️ para editar',
      position: const Offset(120, 220),
      color: _getPrimaryColor(),
      isCentral: true,
    ));
  }

  String _getStorageKey() {
    int userId = widget.u["id_usuario"] ?? 1;
    return "PI_MapaMental_User_$userId";
  }

  Future<void> _loadSavedMaps() async {
    String? raw = await ToolStorageService.getString(_getStorageKey());
    if (raw != null && raw.isNotEmpty) {
      try {
        List<dynamic> list = jsonDecode(raw);
        if (mounted) {
          setState(() {
            _savedMaps = list.cast<Map<String, dynamic>>();
          });
        }
      } catch (_) {}
    }
  }

  void _saveCurrentMap() async {
    String title = _mapNameController.text.trim();
    if (title.isEmpty) title = "Meu Mapa Mental";

    List<Map<String, dynamic>> nodesJson = _nodes.map((n) => n.toJson()).toList();
    Map<String, dynamic> mapObj = {
      "id": DateTime.now().millisecondsSinceEpoch.toString(),
      "title": title,
      "date": "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
      "nodes": nodesJson,
    };

    List<Map<String, dynamic>> maps = List.from(_savedMaps);
    int existingIdx = maps.indexWhere((m) => m["title"] == title);
    if (existingIdx != -1) {
      maps[existingIdx] = mapObj;
    } else {
      maps.add(mapObj);
    }

    await ToolStorageService.setString(_getStorageKey(), jsonEncode(maps));
    if (mounted) {
      setState(() {
        _savedMaps = maps;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Mapa Mental \"$title\" salvo com sucesso!"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _deleteMap(String id) async {
    List<Map<String, dynamic>> maps = List.from(_savedMaps);
    maps.removeWhere((m) => m["id"] == id);
    await ToolStorageService.setString(_getStorageKey(), jsonEncode(maps));
    if (mounted) {
      setState(() {
        _savedMaps = maps;
      });
    }
  }

  void _loadMapIntoCanvas(Map<String, dynamic> mapObj) {
    try {
      List<dynamic> nodesList = mapObj["nodes"] ?? [];
      setState(() {
        _mapNameController.text = mapObj["title"] ?? "Mapa Mental";
        _nodes.clear();
        for (var item in nodesList) {
          _nodes.add(MindMapNode.fromJson(item));
        }
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Mapa \"${mapObj['title']}\" carregado!"), backgroundColor: Colors.blue),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao carregar mapa mental."), backgroundColor: Colors.red),
      );
    }
  }

  void _showSavedMapsListModal() {
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("📁 Meus Mapas Mentais Salvos", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 12),
              _savedMaps.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Center(
                        child: Text(
                          "Nenhum mapa salvo ainda.\nCrie um mapa e clique no ícone de Salvar 💾 no topo!",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: 'Poppins', color: Colors.grey),
                        ),
                      ),
                    )
                  : SizedBox(
                      height: 260,
                      child: ListView.builder(
                        itemCount: _savedMaps.length,
                        itemBuilder: (context, idx) {
                          final m = _savedMaps[idx];
                          return Card(
                            color: cardBg,
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getPrimaryColor(),
                                child: const Icon(Icons.hub, color: Colors.white, size: 20),
                              ),
                              title: Text(m["title"] ?? "Mapa Mental", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 13, color: textColor)),
                              subtitle: Text("Salvo em ${m['date'] ?? ''}", style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.grey)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.download, color: Colors.blueAccent),
                                    onPressed: () => _loadMapIntoCanvas(m),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                    onPressed: () => _deleteMap(m["id"]),
                                  ),
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

  void _addTopicNode() {
    setState(() {
      String id = DateTime.now().millisecondsSinceEpoch.toString();
      _nodes.add(MindMapNode(
        id: id,
        title: 'Tópico ${_nodes.length}',
        notes: '',
        position: Offset(100.0 + (_nodes.length * 20), 100.0 + (_nodes.length * 25)),
        color: _palette[_nodes.length % _palette.length],
      ));
    });
  }

  void _editNodeModal(MindMapNode node, [VoidCallback? onSaveCallback]) {
    final titleCtrl = TextEditingController(text: node.title);
    final notesCtrl = TextEditingController(text: node.notes);
    Color selectedColor = node.color;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final bool isDark = Theme.of(context).brightness == Brightness.dark;
          final Color dialogBg = isDark ? const Color(0xff1e1e1e) : Colors.white;
          final Color textColor = isDark ? Colors.white : Colors.black87;
          final Color labelColor = isDark ? Colors.white70 : Colors.black87;

          return AlertDialog(
            backgroundColor: dialogBg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Icon(Icons.edit, color: _getPrimaryColor()),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    node.isCentral ? "Editar Tema Central" : "Editar Tópico",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 320,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Título:",
                      style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 12, color: labelColor),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: titleCtrl,
                      decoration: InputDecoration(
                        hintText: "Ex: Fotossíntese, Leis da Física...",
                        hintStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: textColor),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Anotações / Descrição:",
                      style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 12, color: labelColor),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: notesCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Adicione notas explicativas para este tópico...",
                        hintStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: textColor),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Cor da Caixinha:",
                      style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 12, color: labelColor),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _palette.map((c) {
                        bool isSel = c.value == selectedColor.value;
                        return GestureDetector(
                          onTap: () => setDialogState(() => selectedColor = c),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: isSel
                                  ? Border.all(color: isDark ? Colors.white : Colors.black, width: 3)
                                  : Border.all(color: Colors.black12, width: 1),
                              boxShadow: isSel
                                  ? [
                                      BoxShadow(
                                        color: c.withValues(alpha: 0.4),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              if (!node.isCentral)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _nodes.removeWhere((n) => n.id == node.id);
                    });
                    if (onSaveCallback != null) onSaveCallback();
                    Navigator.pop(context);
                  },
                  child: const Text("Excluir Tópico", style: TextStyle(fontFamily: 'Poppins', color: Colors.redAccent)),
                ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancelar", style: TextStyle(fontFamily: 'Poppins', color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getPrimaryColor(),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  setState(() {
                    node.title = titleCtrl.text.trim();
                    node.notes = notesCtrl.text.trim();
                    node.color = selectedColor;
                  });
                  if (onSaveCallback != null) onSaveCallback();
                  Navigator.pop(context);
                },
                child: const Text("Salvar", style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
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

    MindMapNode central = _nodes.firstWhere((n) => n.isCentral, orElse: () => _nodes.first);

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
          "Mapa Mental",
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
            tooltip: "Salvar Mapa Mental",
            onPressed: _saveCurrentMap,
          ),
          IconButton(
            icon: const Icon(Icons.folder_open, color: Colors.white),
            tooltip: "Meus Mapas Salvos",
            onPressed: _showSavedMapsListModal,
          ),
        ],
      ),
      body: Column(
        children: [
          // Top Header Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: cardBg,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _mapNameController,
                    decoration: InputDecoration(
                      labelText: "Título do Mapa Mental",
                      labelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: primaryColor),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                    style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 13, color: textColor),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _addTopicNode,
                  icon: const Icon(Icons.add, size: 16, color: Colors.white),
                  label: const Text("+ Tópico", style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                  tooltip: "Limpar Tópicos",
                  onPressed: () {
                    setState(() {
                      _nodes.removeWhere((n) => !n.isCentral);
                    });
                  },
                ),
              ],
            ),
          ),

          // Zero-Flicker Canvas isolated with StatefulBuilder and RepaintBoundary
          Expanded(
            child: StatefulBuilder(
              builder: (context, setCanvasState) {
                return Container(
                  color: pageBg,
                  width: double.infinity,
                  height: double.infinity,
                  child: RepaintBoundary(
                    child: Stack(
                      children: [
                        CustomPaint(
                          size: Size.infinite,
                          painter: MindMapLinePainter(nodes: _nodes, centralNode: central),
                        ),

                        // Nodes rendering with isolated drag and double-click/edit state
                        ..._nodes.map((node) {
                          return Positioned(
                            left: node.position.dx,
                            top: node.position.dy,
                            child: _MindMapNodeWidget(
                              node: node,
                              onEdit: () => _editNodeModal(node, () => setCanvasState(() {})),
                              onDrag: (delta) {
                                setCanvasState(() {
                                  node.position += delta;
                                });
                              },
                            ),
                          );
                        }),
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
  }
}

class _MindMapNodeWidget extends StatefulWidget {
  final MindMapNode node;
  final VoidCallback onEdit;
  final Function(Offset) onDrag;

  const _MindMapNodeWidget({
    required this.node,
    required this.onEdit,
    required this.onDrag,
  });

  @override
  State<_MindMapNodeWidget> createState() => _MindMapNodeWidgetState();
}

class _MindMapNodeWidgetState extends State<_MindMapNodeWidget> {
  double _dragDistance = 0.0;
  DateTime _lastTapTime = DateTime(0);

  @override
  Widget build(BuildContext context) {
    final node = widget.node;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (_) {
        _dragDistance = 0.0;
      },
      onPanUpdate: (details) {
        _dragDistance += details.delta.distance;
        widget.onDrag(details.delta);
      },
      onPanEnd: (_) {
        // Se o movimento foi mínimo, foi um toque (clique) e não arrasto
        if (_dragDistance < 8.0) {
          final now = DateTime.now();
          if (now.difference(_lastTapTime).inMilliseconds < 450) {
            // Duplo clique detectado com sucesso!
            widget.onEdit();
            _lastTapTime = DateTime(0);
          } else {
            _lastTapTime = now;
          }
        }
      },
      onLongPress: widget.onEdit,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: const BoxConstraints(minWidth: 120, maxWidth: 190),
        decoration: BoxDecoration(
          color: node.color,
          borderRadius: BorderRadius.circular(node.isCentral ? 18 : 12),
          border: node.isCentral ? Border.all(color: Colors.white, width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: node.color.withValues(alpha: 0.35),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    node.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: node.isCentral ? 13 : 12,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: widget.onEdit,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.edit, size: 14, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            if (node.notes.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                node.notes,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  color: Colors.white70,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class MindMapLinePainter extends CustomPainter {
  final List<MindMapNode> nodes;
  final MindMapNode centralNode;

  MindMapLinePainter({required this.nodes, required this.centralNode});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.5)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final Offset centerOffset = centralNode.position + const Offset(60, 25);

    for (var node in nodes) {
      if (!node.isCentral) {
        final Offset nodeOffset = node.position + const Offset(60, 25);
        canvas.drawLine(centerOffset, nodeOffset, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
