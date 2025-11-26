// lib/features/simulasi/simulation_models.dart (MODIFIED)

import 'package:flutter/material.dart';

// ========================================================================
// 1. SimulationComponent
// ========================================================================
class SimulationComponent {
  final String id;
  final String type;
  Offset position;
  Map<String, bool> inputs;
  bool outputValue;

  SimulationComponent({
    required this.id,
    required this.type,
    required this.position,
    required this.inputs,
    this.outputValue = false,
  });

  // Konversi dari Map (untuk parsing JSON/Firebase)
  factory SimulationComponent.fromMap(Map<String, dynamic> map) {
    // Posisi disimpan sebagai List [x, y] di Firebase
    final List<dynamic> posList = map['position'] ?? [0.0, 0.0];

    // Inputs harus di-cast ke Map<String, bool>
    final Map<String, bool> inputsMap =
        (map['inputs'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, value as bool),
        ) ??
        {};

    return SimulationComponent(
      id: map['id'] ?? '',
      type: map['type'] ?? 'unknown',
      position: Offset(posList[0] as double, posList[1] as double),
      inputs: inputsMap,
      outputValue: map['outputValue'] ?? false,
    );
  }

  // Konversi ke Map (untuk penyimpanan JSON/Firebase)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      // Simpan Offset sebagai List agar mudah disimpan di Firestore
      'position': [position.dx, position.dy],
      'inputs': inputs,
      'outputValue': outputValue,
    };
  }

  SimulationComponent copyWith({
    Offset? position,
    Map<String, bool>? inputs,
    bool? outputValue,
  }) {
    return SimulationComponent(
      id: id,
      type: type,
      position: position ?? this.position,
      inputs: inputs ?? Map<String, bool>.from(this.inputs),
      outputValue: outputValue ?? this.outputValue,
    );
  }
}

// ========================================================================
// 2. WireConnection
// ========================================================================
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

  // Konversi dari Map
  factory WireConnection.fromMap(Map<String, dynamic> map) {
    return WireConnection(
      fromComponentId: map['fromComponentId'] ?? '',
      fromNodeId: map['fromNodeId'] ?? '',
      toComponentId: map['toComponentId'] ?? '',
      toNodeId: map['toNodeId'] ?? '',
    );
  }

  // Konversi ke Map
  Map<String, dynamic> toMap() {
    return {
      'fromComponentId': fromComponentId,
      'fromNodeId': fromNodeId,
      'toComponentId': toComponentId,
      'toNodeId': toNodeId,
    };
  }

  WireConnection copyWith() {
    return WireConnection(
      fromComponentId: fromComponentId,
      fromNodeId: fromNodeId,
      toComponentId: toComponentId,
      toNodeId: toNodeId,
    );
  }
}

// ========================================================================
// 3. SimulationProject
// ========================================================================

// Model BARU: Merepresentasikan satu proyek/canvas lengkap
class SimulationProject {
  final String id;
  String name;
  List<SimulationComponent> components;
  List<WireConnection> wires;

  SimulationProject({
    required this.id,
    required this.name,
    required this.components,
    required this.wires,
  });

  //  KOREKSI DI SINI: Tambahkan parameter opsional
  SimulationProject copyWith({
    String? id,
    String? name,
    List<SimulationComponent>? components,
    List<WireConnection>? wires,
  }) {
    return SimulationProject(
      id: id ?? this.id, // Gunakan ID baru jika ada
      name: name ?? this.name, // Gunakan nama baru jika ada
      // Pastikan List di-clone jika parameter components/wires tidak disediakan
      components:
          components ?? this.components.map((c) => c.copyWith()).toList(),
      wires: wires ?? this.wires.map((w) => w.copyWith()).toList(),
    );
  }
}

// ========================================================================
// 4. SimulationPayload (Payload tetap OK)
// ========================================================================
class SimulationPayload {
  final SimulationProject project;
  SimulationPayload(this.project);
}
