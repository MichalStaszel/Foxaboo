import 'package:material_ui/material_ui.dart';

import '../app/theme.dart';

enum FoxMood { happy, wink, sad }

/// The Foxaboo mascot, drawn from the design's 120×120 vector.
class Fox extends StatelessWidget {
  const Fox({super.key, this.size = 96, this.mood = FoxMood.happy});

  final double size;
  final FoxMood mood;

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: _FoxPainter(mood)),
      );
}

class _FoxPainter extends CustomPainter {
  _FoxPainter(this.mood);
  final FoxMood mood;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 120);
    Paint fill(Color c) => Paint()..color = c;
    Path poly(List<double> xy) {
      final path = Path()..moveTo(xy[0], xy[1]);
      for (var i = 2; i < xy.length; i += 2) {
        path.lineTo(xy[i], xy[i + 1]);
      }
      return path..close();
    }

    // Ears, then their dark insides.
    canvas
      ..drawPath(poly([20, 52, 30, 8, 56, 38]), fill(FoxColors.foxDark))
      ..drawPath(poly([100, 52, 90, 8, 64, 38]), fill(FoxColors.foxDark))
      ..drawPath(poly([27, 44, 32, 18, 47, 37]), fill(FoxColors.ink))
      ..drawPath(poly([93, 44, 88, 18, 73, 37]), fill(FoxColors.ink));

    // Head and white cheeks.
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(60, 68), width: 88, height: 80),
      fill(FoxColors.fox),
    );
    for (final x in [44.0, 76.0]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, 84), width: 44, height: 36),
        fill(Colors.white),
      );
    }

    // Eyes: the right one closes for a wink.
    final eye = fill(FoxColors.ink);
    final shine = fill(Colors.white);
    canvas
      ..drawCircle(const Offset(45, 62), 6, eye)
      ..drawCircle(const Offset(47, 60), 2, shine);
    if (mood == FoxMood.wink) {
      canvas.drawPath(
        Path()
          ..moveTo(69, 63)
          ..quadraticBezierTo(75, 57, 81, 63),
        Paint()
          ..color = FoxColors.ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5
          ..strokeCap = StrokeCap.round,
      );
    } else {
      canvas
        ..drawCircle(const Offset(75, 62), 6, eye)
        ..drawCircle(const Offset(77, 60), 2, shine);
    }

    // Nose and mouth.
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(60, 80), width: 14, height: 10),
      eye,
    );
    final smile = mood == FoxMood.sad
        ? (Path()
          ..moveTo(53, 94)
          ..quadraticBezierTo(60, 89, 67, 94))
        : (Path()
          ..moveTo(52, 89)
          ..quadraticBezierTo(60, 97, 68, 89));
    canvas.drawPath(
      smile,
      Paint()
        ..color = FoxColors.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_FoxPainter old) => old.mood != mood;
}
