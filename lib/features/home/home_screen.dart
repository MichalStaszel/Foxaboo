import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import '../../content/content_repository.dart';
import '../../content/models.dart';
import '../../data/app_store.dart';
import '../../game/round_engine.dart';
import '../../l10n/strings.dart';
import '../../narrator/narrator.dart';
import '../../widgets/common.dart';
import '../../widgets/fox.dart';
import '../../widgets/sticker.dart';
import '../parent/gate_screen.dart';

const roomIcons = {
  'kitchen': Icons.kitchen,
  'living': Icons.weekend,
  'bedroom': Icons.bed,
  'house': Icons.home,
};

/// Start screen: who plays, what to hunt, album, and the parent lock.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _mode = colorsMode;

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final data = ref.watch(appStoreProvider);
    final pack = ref.watch(contentPackProvider);
    final narrator = ref.watch(narratorProvider);
    final settings = data.settings;
    final profile = data.activeProfile;
    final found = data.activeProgress.finds.keys
        .where(pack.targetIds.contains)
        .length;
    final total = pack.items.length + pack.colors.length;

    final modes = [
      (
        id: colorsMode,
        words: {
          settings.nativeLang: s.t('colors'),
          settings.learnLang: Strings(settings.learnLang).t('colors'),
        },
      ),
      for (final r in pack.rooms) (id: r.id, words: r.words),
    ];

    void select(String id, Map<String, String> words) {
      setState(() => _mode = id);
      narrator.say([
        (text: words[settings.nativeLang] ?? id, lang: settings.nativeLang),
        (text: words[settings.learnLang] ?? id, lang: settings.learnLang),
        if (!data.isModeUnlocked(id))
          (text: s.t('lockedRoom'), lang: settings.nativeLang),
      ]);
    }

    final unlocked = data.isModeUnlocked(_mode);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            children: [
              Row(
                children: [
                  _ProfileChip(
                    name: profile?.name ?? s.t('player'),
                    colorIndex: profile?.colorIndex ?? 0,
                    onTap: data.profiles.length > 1
                        ? () => _pickProfile(context)
                        : null,
                  ),
                  const Spacer(),
                  RoundIconButton(
                    icon: Icons.lock_rounded,
                    tooltip: s.t('parentZone'),
                    size: 44,
                    background: Colors.white,
                    color: FoxColors.muted,
                    onPressed: () async {
                      if (await requireParent(context) && context.mounted) {
                        context.push('/parent');
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Fox(size: 92),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.t('huntQuestion'), style: display(32)),
                        const SizedBox(height: 6),
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: FoxColors.jungle,
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: () => narrator.say([
                            (
                              text: s.t('huntQuestion'),
                              lang: settings.nativeLang,
                            ),
                          ]),
                          icon: const Icon(Icons.volume_up_rounded),
                          label: Text(s.t('listen'), style: body(16)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.45,
                  children: [
                    for (final m in modes)
                      _ModeCard(
                        label: m.words[settings.nativeLang] ?? m.id,
                        selected: _mode == m.id,
                        locked: !data.isModeUnlocked(m.id),
                        onTap: () => select(m.id, m.words),
                        child: m.id == colorsMode
                            ? const _ColorDots()
                            : Icon(
                                roomIcons[m.id] ?? Icons.home,
                                size: 40,
                                color: FoxColors.jungle,
                              ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _AlbumRow(
                label: s.t('album'),
                count: '$found / $total',
                onTap: () => context.push('/album'),
              ),
              const SizedBox(height: 16),
              BigButton(
                label: s.t('letsHunt'),
                icon: unlocked
                    ? Icons.photo_camera_rounded
                    : Icons.lock_rounded,
                onPressed: unlocked
                    ? () => context.push('/round/$_mode')
                    : () => narrator.say([
                        (text: s.t('lockedRoom'), lang: settings.nativeLang),
                      ]),
                color: unlocked ? FoxColors.jungle : FoxColors.muted,
                shadow: unlocked ? FoxColors.jungleDark : FoxColors.ink,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pickProfile(BuildContext context) {
    final s = ref.read(stringsProvider);
    final data = ref.read(appStoreProvider);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(s.t('whoPlays'), style: display(26)),
            const SizedBox(height: 8),
            for (final p in data.profiles)
              ListTile(
                leading: _Avatar(name: p.name, colorIndex: p.colorIndex),
                title: Text(p.name, style: body(20)),
                trailing: p.id == data.activeProfile?.id
                    ? const Icon(Icons.check_circle, color: FoxColors.jungle)
                    : null,
                onTap: () {
                  ref.read(appStoreProvider.notifier).selectProfile(p.id);
                  Navigator.pop(context);
                },
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, required this.colorIndex, this.size = 40});
  final String name;
  final int colorIndex;
  final double size;

  @override
  Widget build(BuildContext context) => CircleAvatar(
    radius: size / 2,
    backgroundColor: FoxColors.stickers[colorIndex % FoxColors.stickers.length],
    child: Text(
      name.isEmpty ? '?' : name.characters.first.toUpperCase(),
      style: display(size * 0.5, color: Colors.white),
    ),
  );
}

class _ProfileChip extends StatelessWidget {
  const _ProfileChip({
    required this.name,
    required this.colorIndex,
    required this.onTap,
  });

  final String name;
  final int colorIndex;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(999),
    child: InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 16, 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Avatar(name: name, colorIndex: colorIndex, size: 36),
            const SizedBox(width: 10),
            Text(name, style: body(18, weight: FontWeight.w800)),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              const Icon(Icons.expand_more, color: FoxColors.muted),
            ],
          ],
        ),
      ),
    ),
  );
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.label,
    required this.selected,
    required this.locked,
    required this.onTap,
    required this.child,
  });

  final String label;
  final bool selected;
  final bool locked;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: selected ? FoxColors.jungle : FoxColors.line,
          width: selected ? 4 : 2,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Stack(
        children: [
          Center(
            child: Opacity(
              opacity: locked ? 0.45 : 1,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  child,
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      style: display(22),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (locked)
            const Positioned(
              top: 0,
              right: 0,
              child: Icon(Icons.lock_rounded, color: FoxColors.muted),
            ),
        ],
      ),
    ),
  );
}

class _ColorDots extends StatelessWidget {
  const _ColorDots();

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 4,
    runSpacing: 4,
    alignment: WrapAlignment.center,
    children: [
      for (final c in huntColorValues.values.take(4))
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(color: c, shape: BoxShape.circle),
        ),
    ],
  );
}

class _AlbumRow extends StatelessWidget {
  const _AlbumRow({
    required this.label,
    required this.count,
    required this.onTap,
  });

  final String label;
  final String count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(
              Icons.collections_bookmark_rounded,
              color: FoxColors.coral,
              size: 30,
            ),
            const SizedBox(width: 12),
            Text(label, style: display(22)),
            const Spacer(),
            Text(count, style: body(18, color: FoxColors.muted)),
            const Icon(Icons.chevron_right, color: FoxColors.muted),
          ],
        ),
      ),
    ),
  );
}
