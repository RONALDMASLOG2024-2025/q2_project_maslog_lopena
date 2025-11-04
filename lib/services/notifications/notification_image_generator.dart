import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/models/eco_tip.dart';

/// Generates visually appealing notification images for eco tips
class NotificationImageGenerator {
  /// Generate a beautiful notification image with the tip text
  static Future<String?> generateTipImage(EcoTip tip) async {
    try {
      // Create a custom painter widget
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(1200, 600); // Standard notification image size

      // Get gradient colors based on category
      final gradientColors = _getCategoryGradient(tip.category);

      // Draw gradient background
      final backgroundPaint = Paint()
        ..shader = LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        backgroundPaint,
      );

      // Draw decorative circles (subtle background pattern)
      final circlePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.1)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(const Offset(150, 100), 120, circlePaint);
      canvas.drawCircle(const Offset(1050, 500), 150, circlePaint);
      canvas.drawCircle(const Offset(600, 50), 80, circlePaint);

      // Draw eco icon
      _drawEcoIcon(canvas, const Offset(100, 80));

      // Draw GreenWise branding
      final brandPainter = TextPainter(
        text: const TextSpan(
          text: 'GreenWise',
          style: TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      
      brandPainter.paint(canvas, const Offset(100, 160));

      // Draw category badge
      final categoryLabel = _getCategoryLabel(tip.category);
      final categoryBadgePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;
      
      final categoryRect = RRect.fromRectAndRadius(
        const Rect.fromLTWH(100, 220, 200, 50),
        const Radius.circular(25),
      );
      canvas.drawRRect(categoryRect, categoryBadgePaint);

      final categoryPainter = TextPainter(
        text: TextSpan(
          text: categoryLabel,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      
      categoryPainter.paint(canvas, const Offset(120, 235));

      // Draw tip text (main content)
      final tipPainter = TextPainter(
        text: TextSpan(
          text: tip.text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 42,
            fontWeight: FontWeight.w700,
            height: 1.4,
            letterSpacing: 0.5,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 4,
        textAlign: TextAlign.left,
      )..layout(maxWidth: size.width - 240);
      
      tipPainter.paint(canvas, const Offset(100, 310));

      // Draw decorative line
      final linePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;
      
      canvas.drawLine(
        const Offset(100, 280),
        const Offset(400, 280),
        linePaint,
      );

      // Convert to image
      final picture = recorder.endRecording();
      final img = await picture.toImage(size.width.toInt(), size.height.toInt());
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) return null;

      // Save to temp directory
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/tip_notification_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(imagePath);
      await file.writeAsBytes(byteData.buffer.asUint8List());

      return imagePath;
    } catch (e) {
      return null;
    }
  }

  static void _drawEcoIcon(Canvas canvas, Offset position) {
    // Draw eco leaf icon
    final iconPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Simple leaf shape using path
    final path = Path();
    path.moveTo(position.dx, position.dy);
    path.quadraticBezierTo(
      position.dx - 20, position.dy + 20,
      position.dx - 10, position.dy + 40,
    );
    path.quadraticBezierTo(
      position.dx, position.dy + 50,
      position.dx + 10, position.dy + 40,
    );
    path.quadraticBezierTo(
      position.dx + 20, position.dy + 20,
      position.dx, position.dy,
    );
    
    canvas.drawPath(path, iconPaint);
    
    // Draw stem
    final stemPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    canvas.drawLine(
      position,
      Offset(position.dx, position.dy + 30),
      stemPaint,
    );
  }

  static List<Color> _getCategoryGradient(EcoTipCategory category) {
    switch (category) {
      case EcoTipCategory.energySaving:
        return [
          const Color(0xFF4CAF50), // Green
          const Color(0xFF66BB6A),
          const Color(0xFF81C784),
        ];
      case EcoTipCategory.deviceCare:
        return [
          const Color(0xFF2196F3), // Blue
          const Color(0xFF42A5F5),
          const Color(0xFF64B5F6),
        ];
      case EcoTipCategory.disposal:
        return [
          const Color(0xFFFF6F00), // Orange
          const Color(0xFFFF8F00),
          const Color(0xFFFFA726),
        ];
      case EcoTipCategory.ecoBuying:
        return [
          const Color(0xFF9C27B0), // Purple
          const Color(0xFFAB47BC),
          const Color(0xFFBA68C8),
        ];
    }
  }

  static String _getCategoryLabel(EcoTipCategory category) {
    switch (category) {
      case EcoTipCategory.energySaving:
        return 'Energy Saving';
      case EcoTipCategory.deviceCare:
        return 'Device Care';
      case EcoTipCategory.disposal:
        return 'Disposal';
      case EcoTipCategory.ecoBuying:
        return 'Eco Buying';
    }
  }

  /// Clean up old notification images to save space
  static Future<void> cleanupOldImages() async {
    try {
      final directory = await getTemporaryDirectory();
      final files = directory.listSync();
      
      for (final file in files) {
        if (file.path.contains('tip_notification_') && file is File) {
          // Delete images older than 7 days
          final stat = await file.stat();
          final age = DateTime.now().difference(stat.modified);
          if (age.inDays > 7) {
            await file.delete();
          }
        }
      }
    } catch (_) {
      // Ignore cleanup errors
    }
  }
}
