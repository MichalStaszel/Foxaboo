import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import '../../content/content_repository.dart';
import '../../data/app_store.dart';
import '../../game/round_engine.dart';
import '../../l10n/strings.dart';
import '../../narrator/narrator.dart';
import '../../widgets/common.dart';
import '../../widgets/sticker.dart';

/// Stickers the child has collected, by room. Pictures only, never photos.
class AlbumScreen extends ConsumerStatefulWidget {
  const AlbumScreen({super.key});

  @override
  ConsumerState<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends ConsumerState<AlbumScreen> {
  String _tab = colorsMode;

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final data = ref.watch(appStoreProvider);
    final pack = ref.watch(contentPackProvider);
    final narrator = ref.watch(narratorProvider);
    final native = data.settings.nativeLang, learn = data.settings.learnLang;
    final finds = data.activeProgress.finds;
    final total = pack.items.length + pack.colors.length;
    final targets = targetsFor(pack, _tab);

    final tabs = [
      (id: colorsMode, label: s.t('colors')),
      for (final r in pack.rooms) (id: r.id, label: r.words[native] ?? r.id),
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  RoundIconButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: s.t('close'),
                    background: Colors.white,
                    color: FoxColors.ink,
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      s.t('albumOf', {
                        'name': data.activeProfile?.name ?? s.t('player'),
                      }),
                      style: display(30),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Pill(
                    color: FoxColors.sun,
                    child: Text('${finds.length} / $total', style: body(16)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final t in tabs)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(t.label, style: body(16)),
                          selected: _tab == t.id,
                          showCheckmark: false,
                          selectedColor: FoxColors.jungle,
                          labelStyle: TextStyle(
                            color: _tab == t.id ? Colors.white : FoxColors.ink,
                          ),
                          backgroundColor: Colors.white,
                          shape: const StadiumBorder(),
                          onSelected: (_) => setState(() => _tab = t.id),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(s.t('albumHint'),
                  style: body(15,
                      color: FoxColors.muted, weight: FontWeight.w600)),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.7,
                  children: [
                    for (final t in targets)
                      _AlbumTile(
                        found: finds.containsKey(t.id),
                        sticker: Sticker(
                          target: t,
                          learnLang: learn,
                          size: 68,
                          found: finds.containsKey(t.id),
                        ),
                        native: t.words[native] ?? '',
                        learn: t.words[learn] ?? '',
                        onTap: finds.containsKey(t.id)
                            ? () => narrator.say([
                                  (text: t.words[native] ?? '', lang: native),
                                  (text: t.words[learn] ?? '', lang: learn),
                                ])
                            : null,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlbumTile extends StatelessWidget {
  const _AlbumTile({
    required this.found,
    required this.sticker,
    required this.native,
    required this.learn,
    required this.onTap,
  });

  final bool found;
  final Widget sticker;
  final String native;
  final String learn;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: found ? Colors.white : const Color(0x80FFFFFF),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                sticker,
                const SizedBox(height: 8),
                if (found) ...[
                  Text(native,
                      style: body(15, weight: FontWeight.w800),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(learn,
                      style: body(13, color: FoxColors.muted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
        ),
      );
}
