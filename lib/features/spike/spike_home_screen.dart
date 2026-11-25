import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import '../../content/content_repository.dart';
import '../../content/models.dart';
import '../../recognition/recognition_result.dart';
import 'spike_results.dart';

/// Lists every colour and item. Photograph each one at home; the summary shows
/// whether recognition is good enough (the gate is 80% found within 2 photos).
class SpikeHomeScreen extends ConsumerWidget {
  const SpikeHomeScreen({super.key});

  static const gate = 0.80;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pack = ref.watch(basePackProvider);
    final results = ref.watch(spikeResultsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Foxaboo: test rozpoznawania'),
        backgroundColor: FoxColors.ground,
        actions: [
          IconButton(
            tooltip: 'Wyczyść wyniki',
            icon: const Icon(Icons.restart_alt),
            onPressed: () => ref.read(spikeResultsProvider.notifier).reset(),
          ),
        ],
      ),
      body: pack.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Nie udało się wczytać treści: $e')),
        data: (pack) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _Summary(results: results),
            const SizedBox(height: 20),
            _SectionTitle('Kolory'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in pack.colors)
                  _TargetChip(
                    label: '${c.words['pl']} · ${c.words['en']}',
                    verdict: results.best('color/${c.id}'),
                    onTap: () => context.go('/hunt/color/${c.id}'),
                  ),
              ],
            ),
            for (final room in pack.rooms) ...[
              const SizedBox(height: 20),
              _SectionTitle(room.words['pl'] ?? room.id),
              for (final item in pack.itemsIn(room.id))
                _ItemTile(
                  item: item,
                  verdict: results.best('item/${item.id}'),
                  attempts: results.attempts['item/${item.id}']?.length ?? 0,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.results});
  final SpikeResults results;

  @override
  Widget build(BuildContext context) {
    final rate = results.hitRate;
    final passing = results.tested > 0 && rate >= SpikeHomeScreen.gate;
    return Card(
      color: Colors.white,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              results.tested == 0
                  ? 'Zrób zdjęcie każdej rzeczy z listy'
                  : '${(rate * 100).round()}% znalezionych w 2 zdjęciach',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: results.tested == 0
                        ? FoxColors.ink
                        : passing
                            ? FoxColors.jungleDark
                            : FoxColors.coral,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Przetestowane: ${results.tested} · znalezione: ${results.found} · '
              'średni czas: ${results.averageTime.inMilliseconds} ms · '
              'próg: ${(SpikeHomeScreen.gate * 100).round()}%',
              style: const TextStyle(color: FoxColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      );
}

class _TargetChip extends StatelessWidget {
  const _TargetChip({
    required this.label,
    required this.verdict,
    required this.onTap,
  });
  final String label;
  final Verdict? verdict;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ActionChip(
        avatar: _VerdictIcon(verdict),
        label: Text(label),
        onPressed: onTap,
      );
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({
    required this.item,
    required this.verdict,
    required this.attempts,
  });
  final Item item;
  final Verdict? verdict;
  final int attempts;

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: _VerdictIcon(verdict),
        title: Text('${item.words['pl']} · ${item.words['en']}'),
        subtitle: Text(
          [
            item.labels.join(', '),
            if (attempts > 0) 'zdjęcia: $attempts',
          ].join(' · '),
        ),
        trailing: const Icon(Icons.photo_camera_outlined),
        onTap: () => context.go('/hunt/item/${item.id}'),
      );
}

class _VerdictIcon extends StatelessWidget {
  const _VerdictIcon(this.verdict);
  final Verdict? verdict;

  @override
  Widget build(BuildContext context) => switch (verdict) {
        null => const Icon(Icons.circle_outlined, color: FoxColors.line),
        Verdict.hit => const Icon(Icons.check_circle, color: FoxColors.jungle),
        Verdict.almost => const Icon(Icons.adjust, color: FoxColors.sunDark),
        Verdict.miss => const Icon(Icons.cancel, color: FoxColors.coral),
      };
}
