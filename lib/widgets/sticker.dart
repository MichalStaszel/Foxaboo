import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import '../app/theme.dart';
import '../content/models.dart';

/// Real colours for colour targets.
const huntColorValues = {
  'red': Color(0xFFE53935),
  'orange': Color(0xFFFB8C00),
  'yellow': Color(0xFFFDD835),
  'green': Color(0xFF43A047),
  'blue': Color(0xFF1E88E5),
  'purple': Color(0xFF8E24AA),
  'pink': Color(0xFFF06292),
  'brown': Color(0xFF795548),
};

Color stickerColor(Target target) => switch (target) {
  ColorTarget(:final color) => huntColorValues[color.id] ?? FoxColors.muted,
  ItemTarget() =>
    FoxColors.stickers[target.id.codeUnits.fold(0, (a, b) => a + b) %
        FoxColors.stickers.length],
};

/// A round sticker for a target. [found] false shows the "?" tile.
class Sticker extends StatelessWidget {
  const Sticker({
    super.key,
    required this.target,
    required this.learnLang,
    this.size = 72,
    this.found = true,
  });

  final Target target;
  final String learnLang;
  final double size;
  final bool found;

  @override
  Widget build(BuildContext context) {
    if (!found) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: FoxColors.line,
          border: Border.all(color: Colors.white, width: size * 0.05),
        ),
        alignment: Alignment.center,
        child: Text('?', style: display(size * 0.45, color: FoxColors.muted)),
      );
    }
    final color = stickerColor(target);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: target is ColorTarget ? color : Colors.white,
        border: Border.all(color: color, width: size * 0.06),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(size * 0.1),
      child: target is ItemTarget ? Illustration(target: target) : null,
    );
  }
}

/// The picture of exactly what to photograph (a laptop, a toy car), or a
/// big blob of the colour. Pictures live in assets/illustrations and are
/// drawn by tool/illustrations/make_illustrations.py.
class Illustration extends StatelessWidget {
  const Illustration({super.key, required this.target, this.size});

  final Target target;
  final double? size;

  @override
  Widget build(BuildContext context) => switch (target) {
    ItemTarget(:final item) => SvgPicture.asset(
      'assets/illustrations/${item.id}.svg',
      width: size,
      height: size,
      semanticsLabel: item.id,
    ),
    ColorTarget() => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: stickerColor(target),
        shape: BoxShape.circle,
        border: Border.all(color: FoxColors.ink, width: 5),
      ),
    ),
  };
}
