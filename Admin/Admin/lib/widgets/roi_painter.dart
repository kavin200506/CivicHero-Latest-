import 'package:flutter/material.dart';
import '../models/camera_model.dart';

class RoiPainter extends CustomPainter {
  final List<RegionOfInterest> regions;
  final List<Point> currentPoints;
  final String currentType;

  RoiPainter({
    required this.regions,
    required this.currentPoints,
    required this.currentType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final fillPaint = Paint()
      ..style = PaintingStyle.fill;

    // Draw existing regions
    for (final region in regions) {
      final path = Path();
      if (region.points.isEmpty) continue;

      final color = _getColorForType(region.type);
      paint.color = color;
      fillPaint.color = color.withOpacity(0.2);

      final first = region.points.first;
      path.moveTo(first.x * size.width, first.y * size.height);

      for (int i = 1; i < region.points.length; i++) {
        final p = region.points[i];
        path.lineTo(p.x * size.width, p.y * size.height);
      }
      path.close();

      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, paint);
      
      // Draw label center
      // (Optional: TextPainter to show label)
    }

    // Draw current drawing
    if (currentPoints.isNotEmpty) {
      final color = _getColorForType(currentType);
      paint.color = color;
      paint.style = PaintingStyle.stroke;
      
      final path = Path();
      final first = currentPoints.first;
      path.moveTo(first.x * size.width, first.y * size.height);

      for (int i = 1; i < currentPoints.length; i++) {
        final p = currentPoints[i];
        path.lineTo(p.x * size.width, p.y * size.height);
      }
      
      canvas.drawPath(path, paint);

      // Draw points
      paint.style = PaintingStyle.fill;
      for (final p in currentPoints) {
        canvas.drawCircle(Offset(p.x * size.width, p.y * size.height), 4, paint);
      }
    }
  }

  Color _getColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'road':
        return Colors.blue;
      case 'garbage':
        return Colors.green;
      case 'streetlight':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  @override
  bool shouldRepaint(covariant RoiPainter oldDelegate) {
    return true; // Simple invalidation
  }
}
