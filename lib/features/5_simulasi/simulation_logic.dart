// lib/features/simulasi/simulation_logic.dart

import 'package:project_volt/data/SQF/models/simulation_models.dart';

// Fungsi Helper untuk Default Input
Map<String, bool> getDefaultInputs(String type) {
  switch (type) {
    case 'AND':
    case 'OR':
    case 'NAND':
    case 'NOR':
    case 'Ex-OR':
    case 'Ex-NOR':
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

// FUNGSI SIMULASI YANG BERJALAN DI BACKGROUND THREAD
SimulationProject runSimulationInBackground(SimulationPayload payload) {
  // Ambil data (ini adalah SALINAN, aman untuk dimodifikasi)
  final project = payload.project;
  final components = project.components;
  final wires = project.wires;

  // ⭐️ OPTIMASI KUNCI: Buat Map untuk pencarian cepat
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

      switch (component.type) {
        case 'INPUT':
          newOutput = component.outputValue;
          break;
        case 'AND':
          newOutput = a && b;
          break;
        case 'OR':
          newOutput = a || b;
          break;
        case 'NOT':
          newOutput = !a;
          break;
        case 'NAND':
          newOutput = !(a && b);
          break;
        case 'NOR':
          newOutput = !(a || b);
          break;
        case 'Ex-OR':
          newOutput = a ^ b; // XOR
          break;
        case 'Ex-NOR':
          newOutput = !(a ^ b); // XNOR
          break;
        case 'OUTPUT':
          component.outputValue = a;
          newOutput = a;
          break;
      }
      component.outputValue = newOutput;
    }
  }

  // 3. Kembalikan data proyek yang sudah di-update
  return project;
}
