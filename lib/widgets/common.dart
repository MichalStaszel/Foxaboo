import 'dart:math';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../app/theme.dart';

/// The big chunky button from the design: solid colour with a darker
/// "ledge" under it.
class BigButton extends StatelessWidget {
  const BigButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = FoxColors.jungle,
    this.shadow = FoxColors.jungleDark,
    this.textColor = Colors.white,
    this.height = 76,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final Color shadow;
  final Color textColor;
  final double height;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          onTap: onPressed == null
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  onPressed!();
                },
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: onPressed == null ? FoxColors.line : color,
              borderRadius: BorderRadius.circular(height / 2),
              boxShadow: [BoxShadow(color: shadow, offset: const Offset(0, 6))],
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: textColor, size: height * 0.38),
                  const SizedBox(width: 10),
                ],
                Flexible(
                  child: Text(
                    label,
                    style: display(height * 0.36, color: textColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

/// Round yellow speaker button that replays a word.
class SpeakerButton extends StatelessWidget {
  const SpeakerButton({
    super.key,
    required this.onPressed,
    this.size = 56,
    this.color = FoxColors.sun,
    this.iconColor = FoxColors.ink,
  });

  final VoidCallback onPressed;
  final double size;
  final Color color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) => Material(
        color: color,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox.square(
            dimension: size,
            child: Icon(Icons.volume_up_rounded,
                color: iconColor, size: size * 0.5),
          ),
        ),
      );
}

/// Round icon button with a soft background (close, pause, lock).
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.size = 48,
    this.background = const Color(0x26FFFFFF),
    this.color = Colors.white,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final double size;
  final Color background;
  final Color color;

  @override
  Widget build(BuildContext context) => Tooltip(
        message: tooltip,
        child: Material(
          color: background,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: SizedBox.square(
              dimension: size,
              child: Icon(icon, color: color, size: size * 0.5),
            ),
          ),
        ),
      );
}

/// Corner brackets that show where to aim.
class CameraFrame extends StatelessWidget {
  const CameraFrame({super.key, this.widthFactor = 0.62});
  final double widthFactor;

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: Center(
          child: FractionallySizedBox(
            widthFactor: widthFactor,
            child: AspectRatio(
              aspectRatio: 1,
              child: CustomPaint(painter: _FramePainter()),
            ),
          ),
        ),
      );
}

class _FramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final l = size.width * 0.18;
    final w = size.width, h = size.height;
    for (final (start, a, b) in [
      (Offset.zero, Offset(l, 0), Offset(0, l)),
      (Offset(w, 0), Offset(w - l, 0), Offset(w, l)),
      (Offset(0, h), Offset(l, h), Offset(0, h - l)),
      (Offset(w, h), Offset(w - l, h), Offset(w, h - l)),
    ]) {
      canvas.drawPath(
        Path()
          ..moveTo(a.dx, a.dy)
          ..lineTo(start.dx, start.dy)
          ..lineTo(b.dx, b.dy),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Ring around the shutter that empties as time runs out.
class TimerRing extends StatelessWidget {
  const TimerRing({
    super.key,
    required this.fraction,
    required this.child,
    this.size = 132,
  });

  final double fraction;
  final Widget child;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _RingPainter(fraction.clamp(0, 1)),
          child: Center(child: child),
        ),
      );
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.fraction);
  final double fraction;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 10.0;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    canvas.drawArc(
      rect,
      0,
      2 * pi,
      false,
      Paint()
        ..color = FoxColors.line
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
    final color = fraction > 0.33
        ? FoxColors.sun
        : Color.lerp(FoxColors.coral, FoxColors.sun, fraction / 0.33)!;
    canvas.drawArc(
      rect,
      -pi / 2,
      2 * pi * fraction,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.fraction != fraction;
}

/// Scattered confetti for the reward screen. Seeded, so it does not jump
/// around between frames.
class Confetti extends StatelessWidget {
  const Confetti({super.key, this.seed = 7});
  final int seed;

  @override
  Widget build(BuildContext context) =>
      IgnorePointer(child: CustomPaint(painter: _ConfettiPainter(seed)));
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.seed);
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(seed);
    const colors = [
      FoxColors.coral,
      FoxColors.jungle,
      FoxColors.sky,
      Color(0xFF8E5BD6),
      Colors.white,
    ];
    for (var i = 0; i < 46; i++) {
      final p = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height * 0.55,
      );
      canvas
        ..save()
        ..translate(p.dx, p.dy)
        ..rotate(random.nextDouble() * pi)
        ..drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: 12, height: 6),
            const Radius.circular(2),
          ),
          Paint()..color = colors[i % colors.length],
        )
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.seed != seed;
}

/// Rounded pill label.
class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
  });

  final Widget child;
  final Color color;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(999),
        ),
        child: child,
      );
}
