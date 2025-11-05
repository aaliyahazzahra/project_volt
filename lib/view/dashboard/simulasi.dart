import 'package:flutter/material.dart';
import 'package:project_volt/constant/app_color.dart';

// 1. Definisikan tipe data untuk gerbang di canvas
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
  // 2. State untuk menyimpan semua gerbang yang ada di canvas
  final List<GateOnCanvas> _gatesOnCanvas = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.kBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Simulasi Logic Gate",
          style: TextStyle(
            color: AppColor.kPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColor.kBackgroundColor,
        elevation: 0,
        actions: [
          // Tombol Reset
          IconButton(
            icon: Icon(Icons.refresh),
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
          // 3. CANVAS AREA (Expanded agar mengisi sisa ruang)
          Expanded(
            // DragTarget adalah area yang "mendengarkan" Draggable
            child: DragTarget<String>(
              // Fungsi yang berjalan saat Draggable dijatuhkan
              onAcceptWithDetails: (details) {
                // 'details.data' berisi tipe gerbang ('AND', 'OR')
                // 'details.offset' berisi posisi di layar (global)

                // Kita butuh posisi lokal di dalam canvas
                // Kita gunakan RenderBox untuk konversi
                final RenderBox renderBox =
                    context.findRenderObject() as RenderBox;
                final Offset localOffset = renderBox.globalToLocal(
                  details.offset,
                );

                setState(() {
                  _gatesOnCanvas.add(
                    GateOnCanvas(
                      type: details.data,
                      // Kita kurangi sedikit agar pas di jari
                      position: Offset(
                        localOffset.dx - 40,
                        localOffset.dy - 100,
                      ),
                    ),
                  );
                });
              },
              // Tampilan canvas saat Draggable di atasnya
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

          // 4. TOOLBOX AREA
          _buildToolbox(),
        ],
      ),
    );
  }

  // Widget untuk Toolbox di bagian bawah
  Widget _buildToolbox() {
    return Container(
      height: 100,
      width: double.infinity,
      color: AppColor.kWhiteColor.withOpacity(0.5),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildDraggableGate("AND"),
          _buildDraggableGate("OR"),
          _buildDraggableGate("NOT"),
          // TODO: Tambahkan gerbang lain (XOR, NAND, dll)
        ],
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
