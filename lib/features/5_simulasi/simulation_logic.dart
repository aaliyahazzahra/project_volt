// lib/features/5_simulasi/simulation_logic.dart

import 'package:project_volt/data/simulation_models.dart';
import 'package:project_volt/features/5_simulasi/gate_logic_helpers.dart'; // Import helper baru

// Fungsi Helper untuk Default Input (Menggunakan Enum)
Map<String, bool> getDefaultInputs(GateType type) {
  // GANTI parameter
  switch (type) {
    case GateType.AND:
    case GateType.OR:
    case GateType.NAND:
    case GateType.NOR:
    case GateType.ExOR: // GANTI
    case GateType.ExNOR: // GANTI
      return {'input_a': false, 'input_b': false};
    case GateType.NOT:
      return {'input_a': false};
    case GateType.INPUT:
    case GateType.unknown:
      return {};
    case GateType.OUTPUT:
      return {'input_a': false};
  }
}

// Fungsi helper untuk perambatan sinyal satu kali
void _propagateSignal(
  List<SimulationComponent> components,
  List<WireConnection> wires,
  Map<String, SimulationComponent> componentMap,
) {
  for (final component in components) {
    // 1. Update input komponen berdasarkan kabel
    for (final wire in wires) {
      if (wire.toComponentId == component.id) {
        final sourceComponent = componentMap[wire.fromComponentId];

        if (sourceComponent != null) {
          component.inputs[wire.toNodeId] = sourceComponent.outputValue;
        }
      }
    }

    // 2. Hitung output baru komponen (Logika Gerbang)
    bool newOutput = false;
    bool a = component.inputs['input_a'] ?? false;
    bool b = component.inputs['input_b'] ?? false;

    // Gerbang INPUT dan OUTPUT memiliki logika khusus di sini
    if (component.type == GateType.INPUT) {
      // INPUT mempertahankan nilai switch-nya
      newOutput = component.outputValue;
    } else if (component.type == GateType.OUTPUT) {
      // OUTPUT mengambil nilai input A, tetapi outputValue-nya adalah nilai tampilan
      component.outputValue = a;
      newOutput = a;
    } else {
      // Gerbang logika lainnya memanggil helper yang diisolasi
      newOutput = calculateGateOutput(type: component.type, a: a, b: b);
    }

    // Update output
    component.outputValue = newOutput;
  }
}

// FUNGSI SIMULASI UTAMA YANG BERJALAN DI BACKGROUND THREAD
SimulationProject runSimulationInBackground(SimulationPayload payload) {
  final project = payload.project;
  final components = project.components;
  final wires = project.wires;

  // OPTIMASI KUNCI: Buat Map untuk pencarian cepat O(1)
  final componentMap = <String, SimulationComponent>{};
  for (final c in components) {
    componentMap[c.id] = c;
  }

  // Jalankan 10 kali untuk menstabilkan sinyal (propagate)
  for (int i = 0; i < 10; i++) {
    _propagateSignal(components, wires, componentMap);
  }

  // Kembalikan data proyek yang sudah di-update
  return project;
}
