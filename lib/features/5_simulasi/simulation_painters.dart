// lib/features/simulasi/simulation_painters.dart

import 'package:flutter/material.dart';
import 'package:project_volt/data/SQF/models/simulation_models.dart';

// PAINTER UNTUK KABEL YANG TERSIMPAN
class WirePainter extends CustomPainter {
  final List<SimulationComponent> components;
  final List<WireConnection> wires;
  final Function(String, String) getNodePosition;

  WirePainter({
    required this.components,
    required this.wires,
    required this.getNodePosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final wire in wires) {
      try {
        final startPoint = getNodePosition(
          wire.fromComponentId,
          wire.fromNodeId,
        );
        final endPoint = getNodePosition(wire.toComponentId, wire.toNodeId);

        final sourceComponent = components.firstWhere(
          (c) => c.id == wire.fromComponentId,
        );
        final bool value = sourceComponent.outputValue;

        final paint = Paint()
          ..color = value ? Colors.orange : Colors.black87
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;

        // Gambar kurva cubicTo
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
        // Komponen mungkin sedang dihapus
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// PAINTER UNTUK KABEL SEMENTARA (SAAT DRAG)
class TemporaryWirePainter extends CustomPainter {
  final Offset startOffset;
  final Offset endOffset;

  TemporaryWirePainter({required this.startOffset, required this.endOffset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.7)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
