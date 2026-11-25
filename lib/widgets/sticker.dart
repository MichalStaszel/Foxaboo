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

/// Placeholder pictures until the illustrated sticker set exists. Items
/// without a fitting icon show the first letter of the learned word.
const _icons = <String, IconData>{
  'cup': Icons.coffee,
  'cutlery': Icons.restaurant,
  'pot': Icons.soup_kitchen,
  'plate': Icons.dinner_dining,
  'sink': Icons.wash,
  'vegetable': Icons.eco,
  'bread': Icons.bakery_dining,
  'cake': Icons.cake,
  'cookie': Icons.cookie,
  'juice': Icons.local_drink,
  'drawer': Icons.inventory_2,
  'couch': Icons.weekend,
  'television': Icons.tv,
  'computer': Icons.computer,
  'phone': Icons.smartphone,
  'curtain': Icons.curtains,
  'plant': Icons.grass,
  'flower': Icons.local_florist,
  'lamp': Icons.emoji_objects,
  'piano': Icons.piano,
  'desk': Icons.desk,
  'chair': Icons.chair,
  'clock': Icons.schedule,
  'lego': Icons.extension,
  'toy': Icons.toys,
  'teddy': Icons.cruelty_free,
  'pillow': Icons.bed,
  'jacket': Icons.checkroom,
  'bag': Icons.shopping_bag,
  'necklace': Icons.diamond,
  'balloon': Icons.celebration,
  'newspaper': Icons.newspaper,
  'poster': Icons.image,
  'umbrella': Icons.beach_access,
  'helmet': Icons.sports_motorsports,
  'bicycle': Icons.pedal_bike,
  'car': Icons.directions_car,
  'stairs': Icons.stairs,
  'dog': Icons.pets,
  'money': Icons.payments,
  'aquarium': Icons.set_meal,
  'skateboard': Icons.skateboarding,
};

Color stickerColor(Target target) => switch (target) {
      ColorTarget(:final color) => huntColorValues[color.id] ?? FoxColors.muted,
      ItemTarget() => FoxColors
          .stickers[target.id.codeUnits.fold(0, (a, b) => a + b) %
              FoxColors.stickers.length],
    };

/// Drops a leading article ("la taza" → "taza", "l'évier" → "évier").
String bareWord(String word) {
  final w = word.trim();
  final apostrophe = RegExp(r"^[lL]['’]");
  if (apostrophe.hasMatch(w)) return w.substring(2);
  final space = w.indexOf(' ');
  const articles = {
    'der', 'die', 'das', 'el', 'la', 'los', 'las', 'le', 'les', 'the', 'a',
  };
  if (space > 0 && articles.contains(w.substring(0, space).toLowerCase())) {
    return w.substring(space + 1);
  }
  return w;
}

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
    final icon = _icons[target.id];
    final letter = bareWord(target.words[learnLang] ?? target.id)
        .characters
        .first
        .toUpperCase();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: Colors.white, width: size * 0.06),
        boxShadow: const [
          BoxShadow(color: Color(0x33000000), blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      alignment: Alignment.center,
      child: switch (target) {
        ColorTarget() => null,
        ItemTarget() => icon != null
            ? Icon(icon, color: Colors.white, size: size * 0.5)
            : Text(letter, style: display(size * 0.48, color: Colors.white)),
      },
    );
  }
}
