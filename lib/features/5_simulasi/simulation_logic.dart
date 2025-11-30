// lib/features/5_simulasi/simulation_logic.dart

import 'package:project_volt/data/simulation_models.dart';
import 'package:project_volt/features/5_simulasi/gate_logic_helpers.dart'; // Import gate logic helper

// Helper function to set default inputs based on GateType
Map<String, bool> getDefaultInputs(GateType type) {
  switch (type) {
    case GateType.AND:
    case GateType.OR:
    case GateType.NAND:
    case GateType.NOR:
    case GateType.ExOR:
    case GateType.ExNOR:
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

// Helper function for a single signal propagation iteration
void _propagateSignal(
  List<SimulationComponent> components,
  List<WireConnection> wires,
  Map<String, SimulationComponent> componentMap,
) {
  for (final component in components) {
    // 1. Update component inputs based on connected wires
    for (final wire in wires) {
      if (wire.toComponentId == component.id) {
        final sourceComponent = componentMap[wire.fromComponentId];

        if (sourceComponent != null) {
          // Input value comes from the source component's output
          component.inputs[wire.toNodeId] = sourceComponent.outputValue;
        }
      }
    }

    // 2. Calculate new component output (Gate Logic)
    bool newOutput = false;
    bool a = component.inputs['input_a'] ?? false;
    bool b = component.inputs['input_b'] ?? false;

    // Handle special component logic (INPUT and OUTPUT)
    if (component.type == GateType.INPUT) {
      // INPUT retains its switch value
      newOutput = component.outputValue;
    } else if (component.type == GateType.OUTPUT) {
      // OUTPUT takes the value of input A, but its outputValue is the display value
      component.outputValue = a;
      newOutput = a;
    } else {
      // Other logic gates call the isolated helper function
      newOutput = calculateGateOutput(type: component.type, a: a, b: b);
    }

    // Update the component's output
    component.outputValue = newOutput;
  }
}

// MAIN SIMULATION FUNCTION RUNNING IN THE BACKGROUND THREAD
SimulationProject runSimulationInBackground(SimulationPayload payload) {
  final project = payload.project;
  final components = project.components;
  final wires = project.wires;

  // KEY OPTIMIZATION: Create Map for fast O(1) component lookup
  final componentMap = <String, SimulationComponent>{};
  for (final c in components) {
    componentMap[c.id] = c;
  }

  // Run 10 iterations to stabilize the signal propagation
  for (int i = 0; i < 10; i++) {
    _propagateSignal(components, wires, componentMap);
  }

  // Return the updated project data
  return project;
}