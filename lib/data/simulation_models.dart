import 'package:flutter/material.dart';

// ========================================================================
// 0. ENUM GATE TYPE
// ========================================================================
enum GateType { AND, OR, NOT, NAND, NOR, ExOR, ExNOR, INPUT, OUTPUT, unknown }

// ========================================================================
// 1. SimulationComponent
// ========================================================================
class SimulationComponent {
  final String id;
  final GateType type;
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

  factory SimulationComponent.fromMap(Map<String, dynamic> map) {
    final List<dynamic> posList = map['position'] ?? [0.0, 0.0];
    final Map<String, bool> inputsMap =
        (map['inputs'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, value as bool),
        ) ??
        {};

    // PERBAIKAN NULL SAFETY
    final typeString = map['type'] as String?;
    final searchType = typeString?.toLowerCase() ?? '';

    return SimulationComponent(
      id: map['id'] ?? '',
      // KONVERSI STRING KE ENUM DENGAN NULL SAFETY
      type: GateType.values.firstWhere(
        (e) => e.name.toLowerCase() == searchType,
        orElse: () => GateType.unknown,
      ),
      position: Offset(posList[0] as double, posList[1] as double),
      inputs: inputsMap,
      outputValue: map['outputValue'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      // KONVERSI ENUM KE STRING
      'type': type.name,
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
    final newInputs = inputs ?? Map<String, bool>.from(this.inputs);
    return SimulationComponent(
      id: id,
      type: type,
      position: position ?? this.position,
      inputs: newInputs,
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

  factory WireConnection.fromMap(Map<String, dynamic> map) {
    return WireConnection(
      fromComponentId: map['fromComponentId'] ?? '',
      fromNodeId: map['fromNodeId'] ?? '',
      toComponentId: map['toComponentId'] ?? '',
      toNodeId: map['toNodeId'] ?? '',
    );
  }

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
// 4. SimulationPayload
// ========================================================================
class SimulationPayload {
  final SimulationProject project;
  SimulationPayload(this.project);
}
