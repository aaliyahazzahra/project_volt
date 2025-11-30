// lib/features/5_simulasi/simulation_painters.dart

import 'package:flutter/material.dart';
import 'package:project_volt/data/simulation_models.dart';

// PAINTER FOR SAVED WIRES (SIMULATION SIGNAL PATH)
class WirePainter extends CustomPainter {
  final List<SimulationComponent> components;
  final List<WireConnection> wires;
  final Function(String, String) getNodePosition;

  // Optimization: Map for O(1) access during paint
  final Map<String, SimulationComponent> componentMap;

  WirePainter({
    required this.components,
    required this.wires,
    required this.getNodePosition,
  }) : componentMap = {for (var c in components) c.id: c};

  @override
  void paint(Canvas canvas, Size size) {
    for (final wire in wires) {
      try {
        final startPoint = getNodePosition(
          wire.fromComponentId,
          wire.fromNodeId,
        );
        final endPoint = getNodePosition(wire.toComponentId, wire.toNodeId);

        // Optimization: Access component O(1)
        final sourceComponent = componentMap[wire.fromComponentId];

        if (sourceComponent == null) continue; // Guard against missing component

        final bool value = sourceComponent.outputValue;

        // Dynamic wire color based on simulation value (Orange for High/True)
        final paint = Paint()
          ..color = value ? Colors.orange : Colors.black87
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;

        // Draw cubic Bézier curve for smooth connections
        final path = Path();
        path.moveTo(startPoint.dx, startPoint.dy);
        final controlPoint1 = Offset(
          startPoint.dx + (endPoint.dx - startPoint.dx).abs() * 0.5,
          startPoint.dy,
        );
        final controlPoint2 = Offset(
          endPoint.dx - (endPoint.dx - startPoint.dx).abs() * 0.5,
          endPoint.dy,
        );
        path.cubicTo(
          controlPoint1.dx,
          controlPoint1.dy,
          controlPoint2.dx,
          controlPoint2.dy,
          endPoint.dx,
          endPoint.dy,
        );

        canvas.drawPath(path, paint);
      } catch (e) {
        // Handle cases where a component might be in the process of being deleted
      }
    }
  }

  @override
  bool shouldRepaint(covariant WirePainter oldDelegate) {
    // CRITICAL: Only repaint if data changes (wires added/removed or component outputs change)
    if (oldDelegate.wires.length != wires.length) return true;
    if (oldDelegate.components.length != components.length) return true;

    // Check for output value changes (triggers repaint to update wire color)
    // Assumes component order in the list is stable
    for (int i = 0; i < components.length; i++) {
      if (oldDelegate.components[i].id == components[i].id &&
          oldDelegate.components[i].outputValue != components[i].outputValue) {
        return true;
      }
    }
    return false;
  }
}

// PAINTER FOR TEMPORARY WIRE (DURING DRAG ACTION)
class TemporaryWirePainter extends CustomPainter {
  final Offset startOffset;
  final Offset endOffset;

  TemporaryWirePainter({required this.startOffset, required this.endOffset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.7) // Neutral color for temporary drag
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Draw cubic Bézier curve
    final path = Path();
    path.moveTo(startOffset.dx, startOffset.dy);
    final controlPoint1 = Offset(
      startOffset.dx + (endOffset.dx - startOffset.dx).abs() * 0.5,
      startOffset.dy,
    );
    final controlPoint2 = Offset(
      endOffset.dx - (endOffset.dx - startOffset.dx).abs() * 0.5,
      endOffset.dy,
    );
    path.cubicTo(
      controlPoint1.dx,
      controlPoint1.dy,
      controlPoint2.dx,
      controlPoint2.dy,
      endOffset.dx,
      endOffset.dy,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant TemporaryWirePainter oldDelegate) {
    // CRITICAL: Only repaint if the wire position changes
    return oldDelegate.startOffset != startOffset ||
        oldDelegate.endOffset != endOffset;
  }
}