// lib/features/simulasi/simulation_models.dart

import 'package:flutter/material.dart';

// Model untuk merepresentasikan sebuah komponen (Gerbang, Input, Output)
class SimulationComponent {
  final String id;
  final String type;
  Offset position;
  Map<String, bool> inputs;
  bool outputValue; // 'true' = 1 (Nyala), 'false' = 0 (Mati)

  SimulationComponent({
    required this.id,
    required this.type,
    required this.position,
    required this.inputs,
    this.outputValue = false,
  });

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

// Model untuk merepresentasikan kabel koneksi
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

  WireConnection copyWith() {
    return WireConnection(
      fromComponentId: fromComponentId,
      fromNodeId: fromNodeId,
      toComponentId: toComponentId,
      toNodeId: toNodeId,
    );
  }
}

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

  SimulationProject copyWith() {
    return SimulationProject(
      id: id,
      name: name,
      components: components.map((c) => c.copyWith()).toList(),
      wires: wires.map((w) => w.copyWith()).toList(),
    );
  }
}

// Payload untuk dikirim ke background (letakan di sini agar dekat dengan Model)
class SimulationPayload {
  final SimulationProject project;
  SimulationPayload(this.project);
}
