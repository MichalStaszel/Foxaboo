import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import '../../content/content_repository.dart';
import '../../content/models.dart';
import '../../data/app_data.dart';
import '../../data/app_store.dart';
import '../../l10n/strings.dart';
import '../../purchase/purchase_service.dart';
import '../setup/setup_screen.dart';

/// Behind the parent gate: progress, settings, children, the one purchase,
/// privacy, and the recognition test.
class ParentScreen extends ConsumerWidget {
  const ParentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final data = ref.watch(appStoreProvider);
    final pack = ref.watch(contentPackProvider);
    final store = ref.read(appStoreProvider.notifier);
    final settings = data.settings;
    final progress = data.activeProgress;
    final profile = data.activeProfile;
    final now = ref.watch(clockProvider)();
    final avg = progress.averageSeconds;

    final targets = <String, Target>{
      for (final c in pack.colors) c.id: ColorTarget(c),
      for (final i in pack.items) i.id: ItemTarget(i),
    };
    final recent = [
      for (final f in progress.recent.take(10))
        if (targets[f.targetId] != null) targets[f.targetId]!,
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: FoxColors.ground,
        title: Text(s.t('parentZone'), style: display(26)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          // Children
          _Card(
            child: Column(
              children: [
                for (final p in data.profiles)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: FoxColors.stickers[
                          p.colorIndex % FoxColors.stickers.length],
                      child: Text(
                        p.name.characters.first.toUpperCase(),
                        style: display(20, color: Colors.white),
                      ),
                    ),
                    title: Text(p.name, style: display(22)),
                    subtitle: p.age == null
                        ? null
                        : Text(s.t('age', {'age': p.age!}),
                            style: body(15, color: FoxColors.muted)),
                    selected: p.id == profile?.id,
                    onTap: () => store.selectProfile(p.id),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (p.id == profile?.id)
                          const Icon(Icons.check_circle,
                              color: FoxColors.jungle),
                        PopupMenuButton<String>(
                          onSelected: (action) async {
                            if (action == 'delete') {
                              store.removeProfile(p.id);
                              return;
                            }
                            final edited = await showProfileDialog(
                                context, s,
                                name: p.name, age: p.age);
                            if (edited != null) {
                              store.updateProfile(Profile(
                                id: p.id,
                                name: edited.$1,
                                age: edited.$2,
                                colorIndex: p.colorIndex,
                              ));
                            }
                          },
                          itemBuilder: (_) => [
                            PopupMenuItem(
                                value: 'edit', child: Text(s.t('change'))),
                            if (data.profiles.length > 1)
                              PopupMenuItem(
                                  value: 'delete', child: Text(s.t('delete'))),
                          ],
                        ),
                      ],
                    ),
                  ),
                if (data.profiles.length < AppData.maxProfiles)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () async {
                        final added = await showProfileDialog(context, s);
                        if (added != null) store.addProfile(added.$1, added.$2);
                      },
                      icon: const Icon(Icons.person_add_alt_1_rounded),
                      label: Text(s.t('addChild'), style: body(16)),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Stats for the selected child
          Row(
            children: [
              _Stat(
                value: '${progress.finds.length}',
                label: s.t('statWords'),
              ),
              const SizedBox(width: 10),
              _Stat(
                value:
                    '${progress.roundsSince(now.subtract(const Duration(days: 7)))}',
                label: s.t('statRounds'),
              ),
              const SizedBox(width: 10),
              _Stat(
                value: avg == null ? '–' : s.t('seconds', {'s': avg.round()}),
                label: s.t('statAvg'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.t('recentWords'), style: display(20)),
                const SizedBox(height: 8),
                if (recent.isEmpty)
                  Text(s.t('noWordsYet'),
                      style: body(15, color: FoxColors.muted))
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final t in recent)
                        Chip(
                          backgroundColor: FoxColors.ground,
                          side: BorderSide.none,
                          shape: const StadiumBorder(),
                          label: Text(
                            '${t.words[settings.learnLang]} · ${t.words[settings.nativeLang]}',
                            style: body(14),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Settings
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.t('settings'), style: display(20)),
                const SizedBox(height: 12),
                Text(s.t('timePerItem'),
                    style: body(14,
                        color: FoxColors.muted, weight: FontWeight.w800)),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<int>(
                    showSelectedIcon: false,
                    segments: [
                      for (final sec in GameSettings.secondsOptions)
                        ButtonSegment(
                          value: sec,
                          label: Text(s.t('seconds', {'s': sec}),
                              style: body(16)),
                        ),
                    ],
                    selected: {settings.roundSeconds},
                    onSelectionChanged: (v) => store.updateSettings(
                        settings.copyWith(roundSeconds: v.first)),
                  ),
                ),
                const SizedBox(height: 16),
                LanguagePairPicker(
                  strings: s,
                  native: settings.nativeLang,
                  learn: settings.learnLang,
                  onChanged: (n, l) => store.updateSettings(
                      settings.copyWith(nativeLang: n, learnLang: l)),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(s.t('narrator'), style: body(17)),
                  value: settings.narrator,
                  onChanged: (v) =>
                      store.updateSettings(settings.copyWith(narrator: v)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _UnlockCard(strings: s, unlocked: data.fullUnlock),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.shield_rounded, color: FoxColors.jungle),
              const SizedBox(width: 8),
              Expanded(
                child: Text(s.t('privacyNote'),
                    style: body(14,
                        color: FoxColors.muted, weight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              TextButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(s.t('privacy'), style: display(24)),
                    content: SingleChildScrollView(
                      child: Text(s.t('privacyBody'), style: body(15)),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(s.t('close')),
                      ),
                    ],
                  ),
                ),
                child: Text(s.t('privacy')),
              ),
              TextButton(
                onPressed: () => context.push('/spike'),
                child: Text(s.t('recognitionTest')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: display(30, color: FoxColors.jungle)),
              Text(label,
                  style: body(13,
                      color: FoxColors.muted, weight: FontWeight.w600)),
            ],
          ),
        ),
      );
}

class _UnlockCard extends ConsumerWidget {
  const _UnlockCard({required this.strings, required this.unlocked});
  final Strings strings;
  final bool unlocked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = strings;
    final purchase = ref.watch(purchaseProvider);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FoxColors.ink,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.t('unlockTitle'), style: display(24, color: Colors.white)),
          const SizedBox(height: 4),
          Text(
            unlocked ? s.t('unlocked') : s.t('unlockBody'),
            style: body(15, color: const Color(0xFFB9C7BC)),
          ),
          if (!unlocked) ...[
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: FoxColors.sun,
                foregroundColor: FoxColors.ink,
                disabledBackgroundColor: const Color(0x33FFFFFF),
                disabledForegroundColor: const Color(0xFFB9C7BC),
                minimumSize: const Size.fromHeight(56),
              ),
              onPressed: purchase.available && !purchase.busy
                  ? () => ref.read(purchaseProvider.notifier).buy()
                  : null,
              child: Text(
                purchase.available
                    ? s.t('unlockButton', {'price': purchase.price ?? ''})
                    : s.t('storeUnavailable'),
                style: body(18, weight: FontWeight.w800),
              ),
            ),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () =>
                      ref.read(purchaseProvider.notifier).restore(),
                  child: Text(s.t('restore'),
                      style: body(14, color: Colors.white)),
                ),
                // Debug builds (the test APK) can unlock without the store.
                if (kDebugMode)
                  TextButton(
                    onPressed: () => ref
                        .read(appStoreProvider.notifier)
                        .setFullUnlock(true),
                    child: Text(s.t('testUnlock'),
                        style: body(14, color: FoxColors.sun)),
                  ),
              ],
            ),
          ] else if (kDebugMode)
            TextButton(
              onPressed: () =>
                  ref.read(appStoreProvider.notifier).setFullUnlock(false),
              child: Text('Lock again (debug)',
                  style: body(14, color: FoxColors.sun)),
            ),
        ],
      ),
    );
  }
}
