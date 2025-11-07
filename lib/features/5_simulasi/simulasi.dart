import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';

class GateOnCanvas {
  final String type; // 'AND', 'OR', 'NOT'
  final Offset position;

  GateOnCanvas({required this.type, required this.position});
}

class Simulasi extends StatefulWidget {
  const Simulasi({super.key});

  @override
  State<Simulasi> createState() => _SimulasiState();
}

class _SimulasiState extends State<Simulasi> {
  final List<GateOnCanvas> _gatesOnCanvas = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.kBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Simulasi",
          style: TextStyle(
            color: AppColor.kTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColor.kAppBar,
        elevation: 0,
        actions: [
          // Tombol Reset
          IconButton(
            icon: Icon(Icons.refresh, color: AppColor.kTextColor),
            tooltip: "Reset Canvas",
            onPressed: () {
              setState(() {
                _gatesOnCanvas.clear();
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
                // 'details.offset' berisi posisi di layar (global)

                // RenderBox untuk konversi
                final RenderBox renderBox =
                    context.findRenderObject() as RenderBox;
                final Offset localOffset = renderBox.globalToLocal(
                  details.offset,
                );

                setState(() {
                  _gatesOnCanvas.add(
                    GateOnCanvas(
                      type: details.data,
                      position: Offset(
                        localOffset.dx - 40,
                        localOffset.dy - 30,
                      ),
                    ),
                  );
                });
              },
              builder: (context, candidateData, rejectedData) {
                return Stack(
                  children: [
                    // TODO: Gambar grid di sini menggunakan CustomPaint

                    // Tampilkan semua gerbang yang sudah ada di canvas
                    ..._gatesOnCanvas.map((gate) {
                      return Positioned(
                        left: gate.position.dx,
                        top: gate.position.dy,
                        child: _buildGateWidget(gate.type),
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

  // Widget untuk Toolbox
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
            _buildDraggableGate("AND"),
            SizedBox(width: 12),
            _buildDraggableGate("OR"),
            SizedBox(width: 12),
            _buildDraggableGate("AND"),
            SizedBox(width: 12),
            _buildDraggableGate("NAND"),
            SizedBox(width: 12),
            _buildDraggableGate("NOR"),
          ],
        ),
      ),
    );
  }

  // Widget untuk gerbang yang bisa di-drag
  Widget _buildDraggableGate(String type) {
    return Draggable<String>(
      // Data yang dikirim saat di-drag
      data: type,
      // Tampilan "hantu" saat di-drag
      feedback: _buildGateWidget(type, isDragging: true),
      // Tampilan asli di toolbox
      child: _buildGateWidget(type),
    );
  }

  // Widget visual untuk satu gerbang logika (bisa dipakai ulang)
  Widget _buildGateWidget(String type, {bool isDragging = false}) {
    return Material(
      color: Colors.transparent,
      child: Container(
        height: 60,
        width: 80,
        decoration: BoxDecoration(
          color: isDragging ? Colors.blueAccent.withOpacity(0.5) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColor.kPrimaryColor, width: 2),
          boxShadow: isDragging
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            type,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColor.kPrimaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
