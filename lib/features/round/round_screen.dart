import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../content/content_repository.dart';
import '../../content/models.dart';
import '../../data/app_store.dart';
import '../../game/round_engine.dart';
import '../../l10n/strings.dart';
import '../../narrator/narrator.dart';
import '../../recognition/recognition_result.dart';
import '../../recognition/recognizer.dart';
import '../parent/gate_screen.dart';
import 'round_views.dart';

enum RoundPhase { task, hunt, checking, almost, miss, reward, timeUp, summary }

/// One round: five targets, each as task card → camera hunt → reward or
/// time up, then a summary. The camera stays open for the whole round.
class RoundScreen extends ConsumerStatefulWidget {
  const RoundScreen({super.key, required this.mode, this.random});

  final String mode;
  final Random? random;

  @override
  ConsumerState<RoundScreen> createState() => _RoundScreenState();
}

class _RoundScreenState extends ConsumerState<RoundScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final Random _random = widget.random ?? Random();
  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;

  late List<Target> _targets;
  int _index = 0;
  final _results = <TaskResult>[];
  RoundPhase _phase = RoundPhase.task;
  late HuntClock _clock;
  bool _paused = false;
  bool _roundRecorded = false;

  CameraController? _camera;
  String? _cameraError;
  bool _opening = false;
  Narrator? _narrator;

  Target get _target => _targets[_index];
  String get _native => ref.read(appStoreProvider).settings.nativeLang;
  String get _learn => ref.read(appStoreProvider).settings.learnLang;
  Duration get _limit =>
      Duration(seconds: ref.read(appStoreProvider).settings.roundSeconds);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ticker = createTicker(_onTick);
    _newRound();
    _openCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    _camera?.dispose();
    _narrator?.stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      if (_phase == RoundPhase.hunt) setState(() => _paused = true);
      _setRunning(false);
      final camera = _camera;
      _camera = null;
      camera?.dispose();
    } else if (state == AppLifecycleState.resumed && _camera == null) {
      _openCamera();
    }
  }

  /// The ticker only runs while the clock does, so nothing redraws every
  /// frame on the task card, reward or summary.
  void _setRunning(bool running) {
    _clock.running = running;
    if (running && !_ticker.isActive) {
      _lastTick = Duration.zero;
      _ticker.start();
    } else if (!running && _ticker.isActive) {
      _ticker.stop();
    }
  }

  void _onTick(Duration now) {
    final delta = now - _lastTick;
    _lastTick = now;
    if (!_clock.running) return;
    _clock.tick(delta);
    if (_clock.isOver) {
      _timeUp();
    } else {
      setState(() {});
    }
  }

  Future<void> _openCamera() async {
    // The permission prompt sends the app to "inactive" and back, which
    // would otherwise open a second camera while the first is pending.
    if (_opening) return;
    _opening = true;
    try {
      final cameras = await availableCameras();
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller =
          CameraController(back, ResolutionPreset.high, enableAudio: false);
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _camera = controller;
        _cameraError = null;
      });
    } on CameraException catch (e) {
      if (mounted) setState(() => _cameraError = e.code);
    } on StateError {
      if (mounted) setState(() => _cameraError = 'noCamera');
    } on Exception catch (e) {
      // No camera plugin (tests) or another platform failure.
      if (mounted) setState(() => _cameraError = '$e');
    } finally {
      _opening = false;
    }
  }

  // ---- Round flow ----------------------------------------------------------

  void _newRound() {
    final data = ref.read(appStoreProvider);
    _targets = pickTargets(
      pack: ref.read(contentPackProvider),
      mode: widget.mode,
      alreadyFound: data.activeProgress.finds.keys.toSet(),
      random: _random,
    );
    _index = 0;
    _results.clear();
    _roundRecorded = false;
    _startTask();
  }

  void _startTask() {
    if (_ticker.isActive) _ticker.stop();
    _clock = HuntClock(_limit);
    _paused = false;
    _phase = RoundPhase.task;
    _sayTask();
  }

  void _sayTask() {
    final s = ref.read(stringsProvider);
    ref.read(narratorProvider).say([
      (
        text: s.t('findSpoken', {'word': _target.words[_native] ?? ''}),
        lang: _native,
      ),
      (text: _target.words[_learn] ?? '', lang: _learn),
    ]);
  }

  void _sayWord() => ref.read(narratorProvider).say([
        (text: _target.words[_native] ?? '', lang: _native),
        (text: _target.words[_learn] ?? '', lang: _learn),
      ]);

  void _sayIn(String lang) => ref
      .read(narratorProvider)
      .say([(text: _target.words[lang] ?? '', lang: lang)]);

  void _swapTarget() {
    final next = replacementTarget(
      pack: ref.read(contentPackProvider),
      mode: widget.mode,
      exclude: {for (final t in _targets) t.id},
      random: _random,
    );
    if (next == null) return;
    setState(() => _targets[_index] = next);
    _sayTask();
  }

  void _startHunt() {
    setState(() {
      _phase = RoundPhase.hunt;
      _paused = false;
      _setRunning(true);
    });
  }

  Future<void> _shoot() async {
    final camera = _camera;
    if (camera == null || _phase != RoundPhase.hunt || _paused) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _phase = RoundPhase.checking;
      _setRunning(false);
    });
    RecognitionResult result;
    try {
      final photo = await camera.takePicture();
      result = await ref.read(recognizerProvider).recognize(photo.path, _target);
    } on CameraException {
      if (mounted) _startHuntAgain();
      return;
    }
    if (!mounted) return;
    final s = ref.read(stringsProvider);
    final word = _target.words[_native] ?? '';
    switch (result.verdict) {
      case Verdict.hit:
        _found(TaskOutcome.found);
      case Verdict.almost:
        setState(() => _phase = RoundPhase.almost);
        ref.read(narratorProvider).say([
          (text: s.t('almost'), lang: _native),
          (text: s.t('getCloser', {'word': word}), lang: _native),
        ]);
      case Verdict.miss:
        setState(() => _phase = RoundPhase.miss);
        ref.read(narratorProvider).say([
          (text: s.t('notIt'), lang: _native),
          (text: s.t('keepLooking', {'word': word}), lang: _native),
        ]);
    }
  }

  void _startHuntAgain() {
    ref.read(narratorProvider).stop();
    _startHunt();
  }

  Future<void> _parentOverride() async {
    if (await requireParent(context) && mounted) {
      _found(TaskOutcome.foundByParent);
    }
  }

  void _found(TaskOutcome outcome) {
    HapticFeedback.heavyImpact();
    final time = _clock.elapsed;
    final isNew =
        ref.read(appStoreProvider.notifier).recordFind(_target.id, time);
    final s = ref.read(stringsProvider);
    setState(() {
      _setRunning(false);
      _results.add(TaskResult(_target, outcome, time, isNew: isNew));
      _phase = RoundPhase.reward;
    });
    ref.read(narratorProvider).say([
      (text: s.t('bravo'), lang: _native),
      (text: _target.words[_native] ?? '', lang: _native),
      (text: _target.words[_learn] ?? '', lang: _learn),
    ]);
  }

  void _timeUp() {
    final s = ref.read(stringsProvider);
    setState(() {
      _setRunning(false);
      _results.add(TaskResult(_target, TaskOutcome.timedOut, _clock.limit));
      _phase = RoundPhase.timeUp;
    });
    ref.read(narratorProvider).say([
      (
        text: s.t('timeUpSpoken', {'word': _target.words[_native] ?? ''}),
        lang: _native,
      ),
      (text: _target.words[_learn] ?? '', lang: _learn),
    ]);
  }

  void _next() {
    if (_index + 1 >= _targets.length) {
      _recordRound();
      setState(() => _phase = RoundPhase.summary);
      final s = ref.read(stringsProvider);
      ref.read(narratorProvider).say([
        (text: s.t('roundOver'), lang: _native),
        (
          text: s.t('foundCount', {
            'n': _results.where((r) => r.found).length,
            'total': _results.length,
          }),
          lang: _native,
        ),
      ]);
      return;
    }
    setState(() {
      _index++;
      _startTask();
    });
  }

  void _recordRound() {
    if (_roundRecorded || _results.isEmpty) return;
    _roundRecorded = true;
    final found = _results.where((r) => r.found);
    ref.read(appStoreProvider.notifier).recordRound(
          found: found.length,
          total: _results.length,
          foundTime: found.fold(Duration.zero, (sum, r) => sum + r.time),
        );
  }

  void _leave() {
    _recordRound();
    context.pop();
  }

  void _pause() => setState(() {
        _paused = true;
        _setRunning(false);
      });

  void _resume() => setState(() {
        _paused = false;
        _setRunning(_phase == RoundPhase.hunt);
      });

  // ---- UI ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    _narrator = ref.watch(narratorProvider);
    final settings = ref.watch(appStoreProvider.select((d) => d.settings));
    final native = settings.nativeLang, learn = settings.learnLang;

    final Widget view = switch (_phase) {
      RoundPhase.task => TaskView(
          target: _target,
          strings: s,
          nativeLang: native,
          learnLang: learn,
          index: _index,
          total: _targets.length,
          seconds: _clock.limit.inSeconds,
          onClose: _leave,
          onSpeak: _sayWord,
          onStart: _startHunt,
          onSwap: _swapTarget,
        ),
      RoundPhase.hunt ||
      RoundPhase.checking ||
      RoundPhase.almost ||
      RoundPhase.miss =>
        HuntView(
          camera: _camera,
          cameraError: _cameraError == null ? null : s.t('cameraDenied'),
          target: _target,
          strings: s,
          nativeLang: native,
          learnLang: learn,
          fractionLeft: _clock.fractionLeft,
          checking: _phase == RoundPhase.checking,
          paused: _paused,
          sheet: switch (_phase) {
            RoundPhase.almost => HuntSheet.almost,
            RoundPhase.miss => HuntSheet.miss,
            _ => null,
          },
          onShoot: _shoot,
          onPause: _pause,
          onResume: _resume,
          onEnd: _leave,
          onSpeak: _sayWord,
          onTryAgain: _startHuntAgain,
          onParentOverride: _parentOverride,
        ),
      RoundPhase.reward => RewardView(
          result: _results.last,
          strings: s,
          nativeLang: native,
          learnLang: learn,
          onSpeak: _sayIn,
          onNext: _next,
        ),
      RoundPhase.timeUp => TimeUpView(
          target: _target,
          strings: s,
          nativeLang: native,
          learnLang: learn,
          onSpeak: _sayIn,
          onNext: _next,
        ),
      RoundPhase.summary => SummaryView(
          results: _results,
          strings: s,
          learnLang: learn,
          onAgain: () => setState(_newRound),
          onHome: _leave,
        ),
    };

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_phase == RoundPhase.hunt && !_paused) {
          _pause();
        } else {
          _leave();
        }
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: KeyedSubtree(key: ValueKey(view.runtimeType), child: view),
      ),
    );
  }
}
