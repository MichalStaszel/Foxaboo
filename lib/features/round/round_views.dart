import 'package:camera/camera.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import '../../content/models.dart';
import '../../game/round_engine.dart';
import '../../l10n/strings.dart';
import '../../widgets/common.dart';
import '../../widgets/fox.dart';
import '../../widgets/sticker.dart';

/// The screens of a round, as in the design: task card, camera hunt (with
/// the "almost" sheet), reward, time up and summary. They hold no state;
/// `RoundScreen` drives them.

class _LangTag extends StatelessWidget {
  const _LangTag(this.lang);
  final String lang;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: FoxColors.ground,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      lang.toUpperCase(),
      style: body(14, color: FoxColors.muted, weight: FontWeight.w800),
    ),
  );
}

/// "PL kubek 🔊" row on the reward and time-up screens.
class WordRow extends StatelessWidget {
  const WordRow({
    super.key,
    required this.lang,
    required this.word,
    required this.onSpeak,
    this.primary = false,
  });

  final String lang;
  final String word;
  final VoidCallback onSpeak;

  /// The language being learned: bigger, so it stands out.
  final bool primary;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.fromLTRB(16, primary ? 12 : 6, 8, primary ? 12 : 6),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        _LangTag(lang),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            word,
            style: primary ? display(42) : display(22, color: FoxColors.muted),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SpeakerButton(onPressed: onSpeak, size: primary ? 60 : 44),
      ],
    ),
  );
}

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.index, required this.total});
  final int index;
  final int total;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 0; i < total; i++)
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: i == index ? 26 : 12,
          height: 12,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: i <= index ? FoxColors.sun : const Color(0x55FFFFFF),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
    ],
  );
}

// ---- Task card --------------------------------------------------------------

class TaskView extends StatelessWidget {
  const TaskView({
    super.key,
    required this.target,
    required this.strings,
    required this.nativeLang,
    required this.learnLang,
    required this.index,
    required this.total,
    required this.seconds,
    required this.onClose,
    required this.onSpeak,
    required this.onStart,
    required this.onSwap,
  });

  final Target target;
  final Strings strings;
  final String nativeLang;
  final String learnLang;
  final int index;
  final int total;
  final int seconds;
  final VoidCallback onClose;
  final VoidCallback onSpeak;
  final VoidCallback onStart;
  final VoidCallback onSwap;

  @override
  Widget build(BuildContext context) {
    final s = strings;
    return Scaffold(
      backgroundColor: FoxColors.jungle,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            children: [
              Row(
                children: [
                  RoundIconButton(
                    icon: Icons.close_rounded,
                    tooltip: s.t('close'),
                    onPressed: onClose,
                  ),
                  const Spacer(),
                  _ProgressDots(index: index, total: total),
                  const Spacer(),
                  Pill(
                    color: const Color(0x33FFFFFF),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          s.t('seconds', {'s': seconds}),
                          style: body(16, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        s.t('find').toUpperCase(),
                        style: body(
                          18,
                          color: FoxColors.muted,
                          weight: FontWeight.w800,
                        ).copyWith(letterSpacing: 2),
                      ),
                      const SizedBox(height: 8),
                      Expanded(child: Illustration(target: target)),
                      const SizedBox(height: 8),
                      FittedBox(
                        child: Text(
                          target.words[learnLang] ?? '',
                          key: const Key('task-word'),
                          style: display(56),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _LangTag(nativeLang),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              target.words[nativeLang] ?? '',
                              style: body(20, color: FoxColors.muted),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SpeakerButton(onPressed: onSpeak, size: 72),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              BigButton(
                label: s.t('imLooking'),
                icon: Icons.search_rounded,
                color: FoxColors.sun,
                shadow: FoxColors.sunDark,
                textColor: FoxColors.ink,
                onPressed: onStart,
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: onSwap,
                icon: const Icon(Icons.casino_rounded, color: Colors.white),
                label: Text(
                  s.t('somethingElse'),
                  style: body(17, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---- Camera hunt -----------------------------------------------------------

enum HuntSheet { almost, miss }

class HuntView extends StatelessWidget {
  const HuntView({
    super.key,
    required this.camera,
    required this.cameraError,
    required this.target,
    required this.strings,
    required this.nativeLang,
    required this.learnLang,
    required this.fractionLeft,
    required this.checking,
    required this.paused,
    required this.sheet,
    required this.onShoot,
    required this.onPause,
    required this.onResume,
    required this.onEnd,
    required this.onSpeak,
    required this.onTryAgain,
    required this.onParentOverride,
  });

  final CameraController? camera;
  final String? cameraError;
  final Target target;
  final Strings strings;
  final String nativeLang;
  final String learnLang;
  final double fractionLeft;
  final bool checking;
  final bool paused;
  final HuntSheet? sheet;
  final VoidCallback onShoot;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onEnd;
  final VoidCallback onSpeak;
  final VoidCallback onTryAgain;
  final VoidCallback onParentOverride;

  @override
  Widget build(BuildContext context) {
    final s = strings;
    final cam = camera;
    final stopped = sheet != null || checking || paused;

    return Scaffold(
      backgroundColor: FoxColors.night,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (cam != null && cam.value.isInitialized)
            _CameraCover(controller: cam)
          else if (cameraError != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  cameraError!,
                  textAlign: TextAlign.center,
                  style: body(20, color: Colors.white),
                ),
              ),
            )
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),
          if (sheet == null) const CameraFrame(),
          if (stopped && !checking) const ColoredBox(color: Color(0x99000000)),
          // Top bar: pause and the task chip.
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      RoundIconButton(
                        icon: Icons.pause_rounded,
                        tooltip: s.t('paused'),
                        background: const Color(0x66000000),
                        onPressed: onPause,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Pill(
                          padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                          child: Row(
                            children: [
                              Sticker(
                                target: target,
                                learnLang: learnLang,
                                size: 40,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      target.words[learnLang] ?? '',
                                      style: display(22),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      target.words[nativeLang] ?? '',
                                      style: body(14, color: FoxColors.muted),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              SpeakerButton(onPressed: onSpeak, size: 40),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (sheet != null) ...[
                    const SizedBox(height: 16),
                    Pill(
                      color: FoxColors.sun,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.pause_circle_filled_rounded,
                            color: FoxColors.ink,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(s.t('timeStops'), style: body(16)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: switch (sheet) {
              null => _ShutterPanel(
                hint: s.t('aimHint'),
                fractionLeft: fractionLeft,
                onShoot: checking || paused ? null : onShoot,
              ),
              final kind => _AlmostSheet(
                kind: kind,
                word: target.words[nativeLang] ?? '',
                target: target,
                learnLang: learnLang,
                strings: s,
                onTryAgain: onTryAgain,
                onParentOverride: onParentOverride,
              ),
            },
          ),
          if (checking)
            ColoredBox(
              color: const Color(0x66000000),
              child: Center(
                child: Pill(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox.square(
                        dimension: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: FoxColors.jungle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(s.t('checking'), style: display(24)),
                    ],
                  ),
                ),
              ),
            ),
          if (paused && sheet == null && !checking)
            _PauseOverlay(strings: s, onResume: onResume, onEnd: onEnd),
        ],
      ),
    );
  }
}

class _CameraCover extends StatelessWidget {
  const _CameraCover({required this.controller});
  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    final size = controller.value.previewSize;
    if (size == null) return CameraPreview(controller);
    // previewSize is landscape; the app is portrait-only.
    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: size.height,
          height: size.width,
          child: CameraPreview(controller),
        ),
      ),
    );
  }
}

class _ShutterPanel extends StatelessWidget {
  const _ShutterPanel({
    required this.hint,
    required this.fractionLeft,
    required this.onShoot,
  });

  final String hint;
  final double fractionLeft;
  final VoidCallback? onShoot;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.fromLTRB(
      20,
      20,
      20,
      20 + MediaQuery.paddingOf(context).bottom,
    ),
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TimerRing(
          fraction: fractionLeft,
          child: Semantics(
            button: true,
            label: hint,
            child: GestureDetector(
              onTap: onShoot,
              child: Container(
                key: const Key('shutter'),
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: FoxColors.jungle,
                  border: Border.all(color: Colors.white, width: 6),
                  boxShadow: const [
                    BoxShadow(color: FoxColors.jungleDark, blurRadius: 0),
                  ],
                ),
                child: const Icon(
                  Icons.photo_camera_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(hint, style: body(18, color: FoxColors.muted)),
      ],
    ),
  );
}

class _AlmostSheet extends StatelessWidget {
  const _AlmostSheet({
    required this.kind,
    required this.word,
    required this.target,
    required this.learnLang,
    required this.strings,
    required this.onTryAgain,
    required this.onParentOverride,
  });

  final HuntSheet kind;
  final String word;
  final Target target;
  final String learnLang;
  final Strings strings;
  final VoidCallback onTryAgain;
  final VoidCallback onParentOverride;

  @override
  Widget build(BuildContext context) {
    final s = strings;
    final almost = kind == HuntSheet.almost;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        16 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Fox(size: 84, mood: almost ? FoxMood.wink : FoxMood.sad),
          const SizedBox(height: 8),
          Text(
            almost ? s.t('almost') : s.t('notIt'),
            style: display(almost ? 40 : 30),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            almost
                ? s.t('getCloser', {'word': word})
                : s.t('keepLooking', {'word': word}),
            style: body(19, color: FoxColors.muted, weight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          if (almost) ...[
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Illustration(target: target, size: 40),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: FoxColors.muted,
                  ),
                ),
                Illustration(target: target, size: 88),
              ],
            ),
          ],
          const SizedBox(height: 20),
          BigButton(
            label: s.t('tryAgain'),
            icon: Icons.photo_camera_rounded,
            height: 68,
            onPressed: onTryAgain,
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onParentOverride,
            icon: const Icon(
              Icons.lock_rounded,
              size: 18,
              color: FoxColors.muted,
            ),
            label: Text(
              s.t('parentSays', {'word': word}),
              style: body(15, color: FoxColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}

class _PauseOverlay extends StatelessWidget {
  const _PauseOverlay({
    required this.strings,
    required this.onResume,
    required this.onEnd,
  });

  final Strings strings;
  final VoidCallback onResume;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: const Color(0xCC14241A),
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Fox(size: 110, mood: FoxMood.wink),
            const SizedBox(height: 12),
            Text(strings.t('paused'), style: display(44, color: Colors.white)),
            const SizedBox(height: 32),
            BigButton(
              label: strings.t('resume'),
              icon: Icons.play_arrow_rounded,
              color: FoxColors.sun,
              shadow: FoxColors.sunDark,
              textColor: FoxColors.ink,
              onPressed: onResume,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onEnd,
              child: Text(
                strings.t('endRound'),
                style: body(18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ---- Reward and time up -----------------------------------------------------

class RewardView extends StatelessWidget {
  const RewardView({
    super.key,
    required this.result,
    required this.strings,
    required this.nativeLang,
    required this.learnLang,
    required this.onSpeak,
    required this.onNext,
  });

  final TaskResult result;
  final Strings strings;
  final String nativeLang;
  final String learnLang;
  final ValueChanged<String> onSpeak;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final s = strings;
    final target = result.target;
    final secs = (result.time.inMilliseconds / 1000).ceil();
    return Scaffold(
      backgroundColor: FoxColors.sun,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Confetti(seed: target.id.hashCode),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              child: Column(
                children: [
                  Text(s.t('bravo'), style: display(56)),
                  Text(
                    s.t('foundIn', {'s': secs}),
                    style: body(20, weight: FontWeight.w800),
                  ),
                  const Spacer(),
                  Transform.rotate(
                    angle: -0.06,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: const [
                              BoxShadow(
                                color: FoxColors.sunDark,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Illustration(target: target, size: 170),
                        ),
                        if (result.isNew)
                          Positioned(
                            right: -18,
                            top: -14,
                            child: Transform.rotate(
                              angle: 0.18,
                              child: Pill(
                                color: FoxColors.coral,
                                child: Text(
                                  s.t('newSticker'),
                                  style: body(16, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  WordRow(
                    lang: learnLang,
                    word: target.words[learnLang] ?? '',
                    onSpeak: () => onSpeak(learnLang),
                    primary: true,
                  ),
                  const SizedBox(height: 10),
                  WordRow(
                    lang: nativeLang,
                    word: target.words[nativeLang] ?? '',
                    onSpeak: () => onSpeak(nativeLang),
                  ),
                  const SizedBox(height: 24),
                  BigButton(
                    label: s.t('next'),
                    icon: Icons.arrow_forward_rounded,
                    color: FoxColors.ink,
                    shadow: Colors.black,
                    onPressed: onNext,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TimeUpView extends StatelessWidget {
  const TimeUpView({
    super.key,
    required this.target,
    required this.strings,
    required this.nativeLang,
    required this.learnLang,
    required this.onSpeak,
    required this.onNext,
  });

  final Target target;
  final Strings strings;
  final String nativeLang;
  final String learnLang;
  final ValueChanged<String> onSpeak;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final s = strings;
    return Scaffold(
      backgroundColor: FoxColors.sky,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          child: Column(
            children: [
              const Fox(size: 110, mood: FoxMood.wink),
              const SizedBox(height: 8),
              Text(s.t('timeUp'), style: display(44, color: Colors.white)),
              Text(
                s.t('nextTime'),
                style: body(18, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              Text(s.t('itWas'), style: body(20, color: Colors.white)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Illustration(target: target, size: 140),
              ),
              const Spacer(),
              WordRow(
                lang: learnLang,
                word: target.words[learnLang] ?? '',
                onSpeak: () => onSpeak(learnLang),
                primary: true,
              ),
              const SizedBox(height: 10),
              WordRow(
                lang: nativeLang,
                word: target.words[nativeLang] ?? '',
                onSpeak: () => onSpeak(nativeLang),
              ),
              const SizedBox(height: 24),
              BigButton(
                label: s.t('next'),
                icon: Icons.arrow_forward_rounded,
                color: FoxColors.sun,
                shadow: FoxColors.sunDark,
                textColor: FoxColors.ink,
                onPressed: onNext,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---- Summary ----------------------------------------------------------------

class SummaryView extends StatelessWidget {
  const SummaryView({
    super.key,
    required this.results,
    required this.strings,
    required this.learnLang,
    required this.onAgain,
    required this.onHome,
  });

  final List<TaskResult> results;
  final Strings strings;
  final String learnLang;
  final VoidCallback onAgain;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final s = strings;
    final found = results.where((r) => r.found).length;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 20),
          child: Column(
            children: [
              Fox(
                size: 130,
                mood: found >= results.length / 2
                    ? FoxMood.happy
                    : FoxMood.wink,
              ),
              const SizedBox(height: 12),
              Text(s.t('roundOver'), style: display(44)),
              const SizedBox(height: 6),
              Text(
                s.t('foundCount', {'n': found, 'total': results.length}),
                style: body(22, color: FoxColors.muted),
              ),
              const SizedBox(height: 28),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  for (final r in results)
                    Sticker(
                      target: r.target,
                      learnLang: learnLang,
                      size: 64,
                      found: r.found,
                    ),
                ],
              ),
              const Spacer(),
              BigButton(
                label: s.t('playAgain'),
                icon: Icons.replay_rounded,
                onPressed: onAgain,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: onHome,
                child: Text(
                  s.t('home'),
                  style: body(18, color: FoxColors.jungle),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
