// lib/features/5_simulasi/gate_logic_helpers.dart

import 'package:project_volt/data/simulation_models.dart';

/// Fungsi murni untuk menghitung output gerbang logika tunggal.
bool calculateGateOutput({
  required GateType type, // Menggunakan Enum baru
  required bool a,
  required bool b,
}) {
  switch (type) {
    case GateType.AND:
      return a && b;
    case GateType.OR:
      return a || b;
    case GateType.NOT:
      return !a;
    case GateType.NAND:
      return !(a && b);
    case GateType.NOR:
      return !(a || b);
    case GateType.ExOR:
      return a ^ b; // XOR
    case GateType.ExNOR:
      return !(a ^ b); // XNOR

    // INPUT dan OUTPUT harus ditangani di logika utama
    case GateType.INPUT:
    case GateType.OUTPUT:
    case GateType.unknown:
    default:
      // Default: Jika tipe tidak dikenali, output sama dengan input A
      return a;
  }
}
