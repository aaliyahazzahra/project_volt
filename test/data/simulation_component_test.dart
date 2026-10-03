import 'package:flutter_test/flutter_test.dart';
import 'package:project_volt/data/simulation_models.dart';

void main() {
  group('SimulationComponent.fromMap', () {
    test('parses type, position and inputs', () {
      final component = SimulationComponent.fromMap({
        'id': 'g1',
        'type': 'AND',
        'position': [10.0, 20.5],
        'inputs': {'a': true, 'b': false},
        'outputValue': true,
      });

      expect(component.id, 'g1');
      expect(component.type, GateType.AND);
      expect(component.position, const Offset(10.0, 20.5));
      expect(component.inputs, {'a': true, 'b': false});
      expect(component.outputValue, isTrue);
    });

    test('matches type names case-insensitively', () {
      final component = SimulationComponent.fromMap({
        'id': 'g2',
        'type': 'nor',
        'position': [0.0, 0.0],
      });

      expect(component.type, GateType.NOR);
    });

    test('falls back to GateType.unknown for unknown or missing type', () {
      final unknown = SimulationComponent.fromMap({
        'id': 'g3',
        'type': 'XYZ',
        'position': [0.0, 0.0],
      });
      final missing = SimulationComponent.fromMap({
        'id': 'g4',
        'position': [0.0, 0.0],
      });

      expect(unknown.type, GateType.unknown);
      expect(missing.type, GateType.unknown);
    });

    test('uses defaults when optional fields are missing', () {
      final component = SimulationComponent.fromMap({
        'type': 'INPUT',
        'position': [1.0, 2.0],
      });

      expect(component.id, '');
      expect(component.inputs, isEmpty);
      expect(component.outputValue, isFalse);
    });
  });

  group('SimulationComponent.toMap', () {
    test('round-trips through fromMap', () {
      final original = SimulationComponent(
        id: 'g5',
        type: GateType.OR,
        position: const Offset(3.0, 4.0),
        inputs: {'a': true},
        outputValue: true,
      );

      final restored = SimulationComponent.fromMap(original.toMap());

      expect(restored.id, original.id);
      expect(restored.type, original.type);
      expect(restored.position, original.position);
      expect(restored.inputs, original.inputs);
      expect(restored.outputValue, original.outputValue);
    });
  });

  group('SimulationComponent.copyWith', () {
    test('keeps id and type, replaces only given fields', () {
      final original = SimulationComponent(
        id: 'g6',
        type: GateType.NOT,
        position: const Offset(0, 0),
        inputs: {'a': false},
      );

      final copy = original.copyWith(outputValue: true);

      expect(copy.id, 'g6');
      expect(copy.type, GateType.NOT);
      expect(copy.position, original.position);
      expect(copy.outputValue, isTrue);
    });

    test('does not mutate the original inputs map', () {
      final original = SimulationComponent(
        id: 'g7',
        type: GateType.AND,
        position: const Offset(0, 0),
        inputs: {'a': false},
      );

      final copy = original.copyWith();
      copy.inputs['a'] = true;

      expect(original.inputs['a'], isFalse);
    });
  });
}
