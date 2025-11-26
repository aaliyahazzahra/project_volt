// File: lib/data/simulation_models.dart (KOREKSI LENGKAP)

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

  //   TAMBAH: fromMap
  factory SimulationComponent.fromMap(Map<String, dynamic> map) {
    final List<dynamic> posList = map['position'] ?? [0.0, 0.0];
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

  //   TAMBAH: toMap
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
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

  //   TAMBAH: fromMap
  factory WireConnection.fromMap(Map<String, dynamic> map) {
    return WireConnection(
      fromComponentId: map['fromComponentId'] ?? '',
      fromNodeId: map['fromNodeId'] ?? '',
      toComponentId: map['toComponentId'] ?? '',
      toNodeId: map['toNodeId'] ?? '',
    );
  }

  //   TAMBAH: toMap
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

  //   TAMBAH: fromMap
  factory SimulationProject.fromMap(Map<String, dynamic> map) {
    return SimulationProject(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Project Baru',
      components:
          (map['components'] as List<dynamic>?)
              ?.map(
                (c) => SimulationComponent.fromMap(c as Map<String, dynamic>),
              )
              .toList() ??
          [],
      wires:
          (map['wires'] as List<dynamic>?)
              ?.map((w) => WireConnection.fromMap(w as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  //   TAMBAH: toMap
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'components': components.map((c) => c.toMap()).toList(),
      'wires': wires.map((w) => w.toMap()).toList(),
    };
  }

  SimulationProject copyWith({
    String? id,
    String? name,
    List<SimulationComponent>? components,
    List<WireConnection>? wires,
  }) {
    return SimulationProject(
      id: id ?? this.id,
      name: name ?? this.name,
      components:
          components ?? this.components.map((c) => c.copyWith()).toList(),
      wires: wires ?? this.wires.map((w) => w.copyWith()).toList(),
    );
  }
}

// ========================================================================
// 4. SimulationPayload (HARUS ADA DI simulation_models.dart)
// ========================================================================
class SimulationPayload {
  final SimulationProject project;

  // Konstruktor menerima objek SimulationProject yang akan dikerjakan di background
  SimulationPayload(this.project);
}
