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
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      children: [
        const _PhoneNotCloud(),
        const SizedBox(height: 12),
        Text(
          s.t('promiseTitle'),
          style: display(28),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          s.t('promiseSub'),
          style: body(15, color: FoxColors.muted, weight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
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
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3CF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.airplanemode_active_rounded,
                color: FoxColors.sunDark,
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  s.t('promiseAirplane'),
                  style: body(13, weight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: body(14, weight: FontWeight.w700).copyWith(height: 1.3),
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
    height: 156,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 92,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: FoxColors.ink, width: 5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Fox(size: 60),
                  const SizedBox(height: 6),
                  Container(
                    width: 36,
                    height: 5,
                    decoration: BoxDecoration(
                      color: FoxColors.line,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: -18,
              bottom: 4,
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: FoxColors.jungle,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 26),
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
                const Icon(
                  Icons.close_rounded,
                  color: FoxColors.coral,
                  size: 24,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(width: 6),
        Container(
          width: 68,
          height: 68,
          decoration: const BoxDecoration(
            color: Color(0xFFE4E9E2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.cloud_off_rounded,
            color: FoxColors.muted,
            size: 38,
          ),
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
        footer: Text(
          s.t('privacyBody'),
          style: body(15, color: FoxColors.muted, weight: FontWeight.w600),
        ),
      ),
    );
  }
}
