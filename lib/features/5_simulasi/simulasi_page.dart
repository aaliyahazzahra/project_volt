import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart'; // Ganti dengan path AppColor Anda
import 'package:uuid/uuid.dart';

// --- 1. MODEL DATA UNTUK KOMPONEN ---
class SimulationComponent {
  final String id;
  final String type;
  Offset position;
  Map<String, bool> inputs;
  bool outputValue; // 'true' = 1, 'false' = 0

  SimulationComponent({
    required this.id,
    required this.type,
    required this.position,
    required this.inputs,
    this.outputValue = false,
  });
}

// --- 2. MODEL DATA UNTUK KABEL ---
class WireConnection {
  final String fromComponentId;
  final String fromNodeId;
  final String toComponentId;
  final String toNodeId;

  WireConnection({
    required this.fromComponentId,
    required this.fromNodeId,
    required this.toComponentId,
    required this.toNodeId,
  });
}

// --- 3. FUNGSI HELPER UNTUK DEFAULT INPUT ---
Map<String, bool> getDefaultInputs(String type) {
  switch (type) {
    case 'AND':
    case 'OR':
    case 'NAND':
    case 'NOR':
      return {'input_a': false, 'input_b': false};
    case 'NOT':
      return {'input_a': false};
    case 'INPUT':
      return {};
    case 'OUTPUT':
      return {'input_a': false};
    default:
      return {};
  }
}

// --- 1. Letakkan ini di LUAR SEMUA CLASS ---

// Ini adalah data "payload" yang akan kita kirim ke background
class SimulationPayload {
  final List<SimulationComponent> components;
  final List<WireConnection> wires;
  SimulationPayload(this.components, this.wires);
}

// Ini adalah FUNGSI YANG BERJALAN DI BACKGROUND
List<SimulationComponent> _runSimulationInBackground(
  SimulationPayload payload,
) {
  // Ambil data (ini adalah SALINAN, aman untuk dimodifikasi)
  final components = payload.components;
  final wires = payload.wires;

  // ⭐️ OPTIMASI KUNCI: Buat Map untuk pencarian cepat
  // Ini mengubah pencarian O(n) -> O(1)
  final componentMap = <String, SimulationComponent>{};
  for (final c in components) {
    componentMap[c.id] = c;
  }

  // Jalankan beberapa kali untuk menstabilkan sinyal
  for (int i = 0; i < 10; i++) {
    for (final component in components) {
      // 1. Update input komponen berdasarkan kabel
      for (final wire in wires) {
        if (wire.toComponentId == component.id) {
          // ⭐️ JAUH LEBIH CEPAT: Langsung ambil dari Map
          final sourceComponent = componentMap[wire.fromComponentId];

          if (sourceComponent != null) {
            component.inputs[wire.toNodeId] = sourceComponent.outputValue;
          }
        }
      }

      // 2. Hitung output baru komponen (Logika switch-case Anda)
      bool newOutput = false;
      switch (component.type) {
        case 'INPUT':
          newOutput = component.outputValue;
          break;
        case 'AND':
          newOutput =
              component.inputs['input_a']! && component.inputs['input_b']!;
          break;
        case 'OR':
          newOutput =
              component.inputs['input_a']! || component.inputs['input_b']!;
          break;
        case 'NOT':
          newOutput = !component.inputs['input_a']!;
          break;
        case 'NAND':
          newOutput =
              !(component.inputs['input_a']! && component.inputs['input_b']!);
          break;
        case 'NOR':
          newOutput =
              !(component.inputs['input_a']! || component.inputs['input_b']!);
          break;
        case 'OUTPUT':
          component.outputValue = component.inputs['input_a']!;
          newOutput = component.outputValue;
          break;
      }
      component.outputValue = newOutput;
    }
  }

  // 3. Kembalikan data yang sudah di-update
  return components;
}

// --- 4. HALAMAN UTAMA SIMULASI ---
class SimulationPage extends StatefulWidget {
  const SimulationPage({super.key});

  @override
  State<SimulationPage> createState() => _SimulationPageState();
}

class _SimulationPageState extends State<SimulationPage> {
  final Uuid _uuid = Uuid();
  final GlobalKey _canvasKey = GlobalKey();

  final List<SimulationComponent> _componentsOnCanvas = [];
  final List<WireConnection> _wires = [];

  // State untuk melacak kabel yang sedang ditarik
  String? _draggingFromComponentId;
  String? _draggingFromNodeId;
  Offset? _draggingOffset;

  // State untuk melacak komponen yang sedang digeser
  String? _draggingComponentId;
  Offset? _dragStartOffset;

  // -- FUNGSI HELPER ---

  void _resetDragging() {
    setState(() {
      _draggingFromComponentId = null;
      _draggingFromNodeId = null;
      _draggingOffset = null;
      _draggingComponentId = null;
      _dragStartOffset = null;
    });
  }

  Offset _convertGlobalToLocal(Offset globalPosition) {
    final RenderBox? canvasBox =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (canvasBox == null) return Offset.zero;
    return canvasBox.globalToLocal(globalPosition);
  }

  Offset getNodePosition(String componentId, String nodeId) {
    try {
      final component = _componentsOnCanvas.firstWhere(
        (c) => c.id == componentId,
      );
      final componentPosition = component.position;
      final type = component.type;

      double inputAY = (type == 'NOT' || type == 'OUTPUT') ? 30 : 18;
      double inputBY = 42;

      if (nodeId == 'input_a') {
        return Offset(componentPosition.dx, componentPosition.dy + inputAY);
      }
      if (nodeId == 'input_b') {
        return Offset(componentPosition.dx, componentPosition.dy + inputBY);
      }
      if (nodeId == 'output') {
        return Offset(componentPosition.dx + 80, componentPosition.dy + 30);
      }
      return Offset(componentPosition.dx + 40, componentPosition.dy + 30);
    } catch (e) {
      // Komponen mungkin baru saja dihapus
      return Offset.zero;
    }
  }

  ({String componentId, String nodeId})? _findNodeAt(Offset localPosition) {
    for (final component in _componentsOnCanvas) {
      if (component.type == 'INPUT') continue;

      if (component.inputs.containsKey('input_a')) {
        final nodePos = getNodePosition(component.id, 'input_a');
        if ((localPosition - nodePos).distance < 15) {
          return (componentId: component.id, nodeId: 'input_a');
        }
      }
      if (component.inputs.containsKey('input_b')) {
        final nodePos = getNodePosition(component.id, 'input_b');
        if ((localPosition - nodePos).distance < 15) {
          return (componentId: component.id, nodeId: 'input_b');
        }
      }
    }
    return null;
  }

  // --- ⭐️⭐️⭐️ LOGIC ENGINE ⭐️⭐️⭐️ ---

  void _runSimulation() {
    // Jalankan beberapa kali untuk menstabilkan sinyal (penting untuk loop)
    for (int i = 0; i < 10; i++) {
      for (final component in _componentsOnCanvas) {
        // 1. Update input komponen berdasarkan kabel
        for (final wire in _wires) {
          if (wire.toComponentId == component.id) {
            // Kabel ini terhubung KE komponen ini
            try {
              final sourceComponent = _componentsOnCanvas.firstWhere(
                (c) => c.id == wire.fromComponentId,
              );
              // Set nilai inputnya
              component.inputs[wire.toNodeId] = sourceComponent.outputValue;
            } catch (e) {
              // Source komponen tidak ditemukan
            }
          }
        }

        // 2. Hitung output baru komponen
        bool newOutput = false;
        switch (component.type) {
          case 'INPUT':
            // Outputnya dikontrol manual (sudah di-set saat di-tap)
            newOutput = component.outputValue;
            break;
          case 'AND':
            newOutput =
                component.inputs['input_a']! && component.inputs['input_b']!;
            break;
          case 'OR':
            newOutput =
                component.inputs['input_a']! || component.inputs['input_b']!;
            break;
          case 'NOT':
            newOutput = !component.inputs['input_a']!;
            break;
          case 'NAND':
            newOutput =
                !(component.inputs['input_a']! && component.inputs['input_b']!);
            break;
          case 'NOR':
            newOutput =
                !(component.inputs['input_a']! || component.inputs['input_b']!);
            break;
          case 'OUTPUT':
            // Output (LED) tidak punya output, tapi kita set nilainya
            // agar visualnya berubah
            component.outputValue = component.inputs['input_a']!;
            newOutput = component.outputValue;
            break;
        }
        component.outputValue = newOutput;
      }
    }

    // Panggil setState HANYA SEKALI di akhir untuk update UI
    setState(() {});
  }
  // --- ⭐️⭐️⭐️ AKHIR LOGIC ENGINE ⭐️⭐️⭐️ ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.kBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Simulation",
          style: TextStyle(
            color: AppColor.kTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColor.kBackgroundColor,
        elevation: 0,
        shape: Border(
          bottom: BorderSide(color: AppColor.kDividerColor, width: 1.5),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColor.kTextColor),
            tooltip: "Reset Canvas",
            onPressed: () {
              setState(() {
                _componentsOnCanvas.clear();
                _wires.clear();
                _resetDragging();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: DragTarget<String>(
              onAcceptWithDetails: (details) {
                final Offset localOffset = _convertGlobalToLocal(
                  details.offset,
                );
                final newComponent = SimulationComponent(
                  id: _uuid.v4(),
                  type: details.data,
                  position: Offset(localOffset.dx - 40, localOffset.dy - 30),
                  inputs: getDefaultInputs(details.data),
                );
                setState(() {
                  _componentsOnCanvas.add(newComponent);
                });
                _runSimulation(); // Jalankan simulasi
              },
              builder: (context, candidateData, rejectedData) {
                return Stack(
                  key: _canvasKey,
                  children: [
                    // 1. Gambar kabel
                    CustomPaint(
                      painter: WirePainter(
                        components: _componentsOnCanvas,
                        wires: _wires,
                        getNodePosition: getNodePosition,
                      ),
                      size: Size.infinite,
                    ),

                    // 2. Gambar kabel sementara
                    if (_draggingFromComponentId != null &&
                        _draggingOffset != null)
                      CustomPaint(
                        painter: TemporaryWirePainter(
                          startOffset: getNodePosition(
                            _draggingFromComponentId!,
                            _draggingFromNodeId!,
                          ),
                          endOffset: _draggingOffset!,
                        ),
                        size: Size.infinite,
                      ),

                    // 3. Gambar komponen
                    ..._componentsOnCanvas.map((component) {
                      return Positioned(
                        left: component.position.dx,
                        top: component.position.dy,
                        // --- ⭐️ TAMBAHAN: GESTURE DETECTOR UNTUK GESER KOMPONEN ⭐️ ---
                        child: GestureDetector(
                          onPanStart: (details) {
                            setState(() {
                              _draggingComponentId = component.id;
                              _dragStartOffset = details.localPosition;
                            });
                          },
                          onPanUpdate: (details) {
                            if (_draggingComponentId == component.id) {
                              setState(() {
                                component.position += details.delta;
                              });
                            }
                          },
                          onPanEnd: (_) => _resetDragging(),
                          child: _buildComponentWidget(component: component),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
          _buildToolbox(),
        ],
      ),
    );
  }

  Widget _buildToolbox() {
    return Container(
      height: 100,
      width: double.infinity,
      color: AppColor.kWarningColor.withOpacity(0.5),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            _buildDraggableComponent("INPUT"),
            SizedBox(width: 16),
            _buildDraggableComponent("OUTPUT"),
            SizedBox(width: 16),
            _buildDraggableComponent("AND"),
            SizedBox(width: 16),
            _buildDraggableComponent("OR"),
            SizedBox(width: 16),
            _buildDraggableComponent("NOT"),
            SizedBox(width: 16),
            _buildDraggableComponent("NAND"),
            SizedBox(width: 16),
            _buildDraggableComponent("NOR"),
          ],
        ),
      ),
    );
  }

  Widget _buildDraggableComponent(String type) {
    return Draggable<String>(
      data: type,
      feedback: _buildComponentVisual(type, isDragging: true, value: false),
      child: _buildComponentVisual(type, value: false),
    );
  }

  // Widget INTERAKTIF di canvas
  Widget _buildComponentWidget({required SimulationComponent component}) {
    // --- ⭐️ PERUBAHAN: BUAT INPUT BISA DI-TAP ⭐️ ---
    if (component.type == 'INPUT') {
      return GestureDetector(
        onTap: () {
          setState(() {
            // Balik nilainya (0 jadi 1, 1 jadi 0)
            component.outputValue = !component.outputValue;
          });
          _runSimulation(); // Jalankan ulang simulasi
        },
        child: _buildComponentVisual(
          component.type,
          value: component.outputValue, // Kirim state 'value'
        ),
      );
    }

    // Tampilan visual untuk gerbang lain
    final visualWidget = _buildComponentVisual(
      component.type,
      value: component.outputValue, // Kirim state 'value'
    );
    // ---------------------------------------------

    final type = component.type;
    final bool showInputA = type != 'INPUT';
    final bool showInputB =
        type == 'AND' || type == 'OR' || type == 'NAND' || type == 'NOR';
    final bool showOutput = type != 'OUTPUT';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        visualWidget,
        if (showInputA)
          Positioned(
            left: -8,
            top: (showInputB) ? 10 : (60 / 2) - 8,
            child: _buildDraggableConnectionNode(
              componentId: component.id,
              nodeId: 'input_a',
              isInputNode: true,
            ),
          ),
        if (showInputB)
          Positioned(
            left: -8,
            bottom: 10,
            child: _buildDraggableConnectionNode(
              componentId: component.id,
              nodeId: 'input_b',
              isInputNode: true,
            ),
          ),
        if (showOutput)
          Positioned(
            right: -8,
            top: (60 / 2) - 8,
            child: _buildDraggableConnectionNode(
              componentId: component.id,
              nodeId: 'output',
              isInputNode: false,
            ),
          ),
      ],
    );
  }

  // Widget HANYA VISUAL (kotak, LED, saklar)
  Widget _buildComponentVisual(
    String type, {
    bool isDragging = false,
    required bool value,
  }) {
    // --- ⭐️ PERUBAHAN: WIDGET KHUSUS INPUT/OUTPUT ⭐️ ---

    // 1. WIDGET UNTUK INPUT (SAKLAR)
    if (type == 'INPUT') {
      return Container(
        height: 60,
        width: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColor.kPrimaryColor, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "INPUT",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: AppColor.kPrimaryColor,
              ),
            ),
            Switch(
              value: value,
              onChanged:
                  null, // Dibuat null agar hanya bisa dikontrol oleh GestureDetector
              activeThumbColor: AppColor.kPrimaryColor,
            ),
          ],
        ),
      );
    }

    // 2. WIDGET UNTUK OUTPUT (LED)
    if (type == 'OUTPUT') {
      return Container(
        height: 60,
        width: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black54, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lightbulb,
              size: 30,
              // LED menyala (kuning) jika 'value' true, mati (abu-abu) jika false
              color: value ? Colors.yellow[600] : Colors.grey,
            ),
            SizedBox(height: 4),
            Text(
              "OUTPUT",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      );
    }
    // --------------------------------------------------

    // 3. WIDGET UNTUK GERBANG LOGIKA (AND, OR, dll)
    return Material(
      color: Colors.transparent,
      child: Container(
        height: 60,
        width: 80,
        decoration: BoxDecoration(
          color: isDragging ? Colors.blueAccent.withOpacity(0.5) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColor.kPrimaryColor, width: 2),
          boxShadow: isDragging ? [/* ...boxShadow... */] : null,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Center(
              child: Text(
                type,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColor.kPrimaryColor,
                ),
              ),
            ),
            // Node visual (tampilan di toolbox)
            if (isDragging) ...[
              if (type != 'INPUT')
                Positioned(
                  left: -8,
                  top:
                      (type == 'AND' ||
                          type == 'OR' ||
                          type == 'NAND' ||
                          type == 'NOR')
                      ? 10
                      : (60 / 2) - 8,
                  child: _buildConnectionNode(isInput: true, value: false),
                ),
              if (type == 'AND' ||
                  type == 'OR' ||
                  type == 'NAND' ||
                  type == 'NOR')
                Positioned(
                  left: -8,
                  bottom: 10,
                  child: _buildConnectionNode(isInput: true, value: false),
                ),
              if (type != 'OUTPUT')
                Positioned(
                  right: -8,
                  top: (60 / 2) - 8,
                  child: _buildConnectionNode(isInput: false, value: false),
                ),
            ],
          ],
        ),
      ),
    );
  }

  // Node yang BISA DI-DRAG
  Widget _buildDraggableConnectionNode({
    required String componentId,
    required String nodeId,
    required bool isInputNode,
  }) {
    // Cari tahu value dari node ini untuk visualisasi
    bool nodeValue = false;
    try {
      final component = _componentsOnCanvas.firstWhere(
        (c) => c.id == componentId,
      );
      if (isInputNode) {
        nodeValue = component.inputs[nodeId] ?? false;
      } else {
        nodeValue = component.outputValue;
      }
    } catch (e) {}

    return GestureDetector(
      onPanStart: (details) {
        if (isInputNode) return; // Hanya drag dari OUTPUT

        final Offset localPosition = _convertGlobalToLocal(
          details.globalPosition,
        );
        setState(() {
          _draggingFromComponentId = componentId;
          _draggingFromNodeId = nodeId;
          _draggingOffset = localPosition;
        });
      },
      onPanUpdate: (details) {
        if (_draggingFromComponentId == null) return;
        final Offset localPosition = _convertGlobalToLocal(
          details.globalPosition,
        );
        setState(() {
          _draggingOffset = localPosition;
        });
      },
      onPanEnd: (details) {
        if (_draggingFromComponentId == null) {
          _resetDragging();
          return;
        }

        final targetNode = _findNodeAt(_draggingOffset!);
        if (targetNode != null) {
          // Cek agar tidak menyambung ke diri sendiri
          if (targetNode.componentId != _draggingFromComponentId) {
            setState(() {
              // Hapus kabel lama (jika ada) di node input yang sama
              _wires.removeWhere(
                (wire) =>
                    wire.toComponentId == targetNode.componentId &&
                    wire.toNodeId == targetNode.nodeId,
              );

              // Tambah kabel baru
              _wires.add(
                WireConnection(
                  fromComponentId: _draggingFromComponentId!,
                  fromNodeId: _draggingFromNodeId!,
                  toComponentId: targetNode.componentId,
                  toNodeId: targetNode.nodeId,
                ),
              );
            });
            _runSimulation(); // Jalankan simulasi
          }
        }
        _resetDragging();
      },
      child: _buildConnectionNode(isInput: isInputNode, value: nodeValue),
    );
  }

  // Tampilan visual node (bulatan)
  Widget _buildConnectionNode({required bool isInput, required bool value}) {
    Color color;
    if (isInput) {
      color = value ? Colors.cyan[200]! : Colors.blue; // Input (0=biru, 1=cyan)
    } else {
      color = value
          ? Colors.orange[200]!
          : Colors.red; // Output (0=merah, 1=orange)
    }

    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4),
        ],
      ),
    );
  }
}

// --- 5. PAINTER UNTUK KABEL YANG TERSIMPAN ---
class WirePainter extends CustomPainter {
  final List<SimulationComponent> components;
  final List<WireConnection> wires;
  final Function(String, String) getNodePosition;

  WirePainter({
    required this.components,
    required this.wires,
    required this.getNodePosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final wire in wires) {
      try {
        final startPoint = getNodePosition(
          wire.fromComponentId,
          wire.fromNodeId,
        );
        final endPoint = getNodePosition(wire.toComponentId, wire.toNodeId);

        // Cek nilai sinyal
        final sourceComponent = components.firstWhere(
          (c) => c.id == wire.fromComponentId,
        );
        final bool value = sourceComponent.outputValue;

        final paint = Paint()
          ..color = value
              ? Colors.orange
              : Colors
                    .black87 // Kabel menyala jika 'value' true
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;

        final path = Path();
        path.moveTo(startPoint.dx, startPoint.dy);
        final controlPoint1 = Offset(
          startPoint.dx + (endPoint.dx - startPoint.dx).abs() * 0.5,
          startPoint.dy,
        );
        final controlPoint2 = Offset(
          endPoint.dx - (endPoint.dx - startPoint.dx).abs() * 0.5,
          endPoint.dy,
        );
        path.cubicTo(
          controlPoint1.dx,
          controlPoint1.dy,
          controlPoint2.dx,
          controlPoint2.dy,
          endPoint.dx,
          endPoint.dy,
        );

        canvas.drawPath(path, paint);
      } catch (e) {
        print("Error drawing wire: $e");
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// --- 6. PAINTER UNTUK KABEL SEMENTARA (SAAT DRAG) ---
class TemporaryWirePainter extends CustomPainter {
  final Offset startOffset;
  final Offset endOffset;

  TemporaryWirePainter({required this.startOffset, required this.endOffset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.7)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(startOffset.dx, startOffset.dy);
    final controlPoint1 = Offset(
      startOffset.dx + (endOffset.dx - startOffset.dx).abs() * 0.5,
      startOffset.dy,
    );
    final controlPoint2 = Offset(
      endOffset.dx - (endOffset.dx - startOffset.dx).abs() * 0.5,
      endOffset.dy,
    );
    path.cubicTo(
      controlPoint1.dx,
      controlPoint1.dy,
      controlPoint2.dx,
      controlPoint2.dy,
      endOffset.dx,
      endOffset.dy,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
