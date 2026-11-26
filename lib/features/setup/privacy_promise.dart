import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import '../../l10n/strings.dart';
import '../../widgets/common.dart';
import '../../widgets/fox.dart';

/// First thing a parent sees: an infographic that nothing leaves the phone.
/// Also opened from the parent zone ("Privacy").
class PrivacyPromise extends StatelessWidget {
  const PrivacyPromise({
    super.key,
    required this.strings,
    required this.onDone,
    this.buttonLabel,
    this.footer,
  });

  final Strings strings;
  final VoidCallback onDone;
  final String? buttonLabel;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final s = strings;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      children: [
        const _PhoneNotCloud(),
        const SizedBox(height: 16),
        Text(s.t('promiseTitle'),
            style: display(32), textAlign: TextAlign.center),
        const SizedBox(height: 6),
        Text(
          s.t('promiseSub'),
          style: body(17, color: FoxColors.muted, weight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        _Promise(
          icon: Icons.photo_camera_rounded,
          color: FoxColors.coral,
          text: s.t('promisePhoto'),
        ),
        _Promise(
          icon: Icons.wifi_off_rounded,
          color: FoxColors.sky,
          text: s.t('promiseOffline'),
        ),
        _Promise(
          icon: Icons.no_accounts_rounded,
          color: const Color(0xFF8E5BD6),
          text: s.t('promiseAccount'),
        ),
        _Promise(
          icon: Icons.block_rounded,
          color: FoxColors.jungle,
          text: s.t('promiseAds'),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3CF),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              const Icon(Icons.airplanemode_active_rounded,
                  color: FoxColors.sunDark, size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Text(s.t('promiseAirplane'), style: body(15)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        BigButton(
          label: buttonLabel ?? s.t('promiseOk'),
          icon: Icons.arrow_forward_rounded,
          onPressed: onDone,
        ),
        if (footer != null) ...[const SizedBox(height: 24), footer!],
      ],
    );
  }
}

class _Promise extends StatelessWidget {
  const _Promise({required this.icon, required this.color, required this.text});

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(text, style: body(16, weight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      );
}

/// The picture: the fox safe inside a phone with a green shield, and a
/// crossed-out cloud the phone never talks to.
class _PhoneNotCloud extends StatelessWidget {
  const _PhoneNotCloud();

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 200,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 112,
                  height: 190,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: FoxColors.ink, width: 6),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Fox(size: 74),
                      const SizedBox(height: 8),
                      Container(
                        width: 44,
                        height: 6,
                        decoration: BoxDecoration(
                          color: FoxColors.line,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: -22,
                  bottom: 6,
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: FoxColors.jungle,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: const Icon(Icons.verified_user_rounded,
                        color: Colors.white, size: 30),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 30),
            // A broken link to the cloud.
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < 3; i++)
                      Container(
                        width: 8,
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        color: FoxColors.muted,
                      ),
                    const Icon(Icons.close_rounded,
                        color: FoxColors.coral, size: 28),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 6),
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                color: Color(0xFFE4E9E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_off_rounded,
                  color: FoxColors.muted, size: 48),
            ),
          ],
        ),
      );
}

/// The same promise, opened from the parent zone, with the full privacy
/// text under it.
class PrivacyScreen extends ConsumerWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    return Scaffold(
      appBar: AppBar(backgroundColor: FoxColors.ground),
      body: PrivacyPromise(
        strings: s,
        buttonLabel: s.t('close'),
        onDone: () => context.pop(),
        footer: Text(s.t('privacyBody'),
            style: body(15, color: FoxColors.muted, weight: FontWeight.w600)),
      ),
    );
  }
}
