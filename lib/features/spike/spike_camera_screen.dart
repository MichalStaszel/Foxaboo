import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import '../../content/content_repository.dart';
import '../../content/models.dart';
import '../../recognition/recognition_result.dart';
import '../../recognition/recognizer.dart';
import 'spike_results.dart';

/// Camera with a centre frame and a shutter. After each photo it shows the
/// verdict and what the model saw, and records the attempt for the summary.
class SpikeCameraScreen extends ConsumerStatefulWidget {
  const SpikeCameraScreen({
    super.key,
    required this.kind,
    required this.targetId,
  });

  /// `item` or `color`.
  final String kind;
  final String targetId;

  @override
  ConsumerState<SpikeCameraScreen> createState() => _SpikeCameraScreenState();
}

class _SpikeCameraScreenState extends ConsumerState<SpikeCameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  String? _cameraError;
  bool _busy = false;
  RecognitionResult? _last;

  String get _key => '${widget.kind}/${widget.targetId}';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _openCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _controller = null;
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _openCamera();
    }
  }

  Future<void> _openCamera() async {
    try {
      final cameras = await availableCameras();
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _controller = controller);
    } on CameraException catch (e) {
      setState(() => _cameraError = e.description ?? e.code);
    } on StateError {
      setState(() => _cameraError = 'Nie znaleziono aparatu');
    }
  }

  Future<void> _shoot(Target target) async {
    final controller = _controller;
    if (controller == null || _busy) return;
    setState(() => _busy = true);
    try {
      final photo = await controller.takePicture();
      final result =
          await ref.read(recognizerProvider).recognize(photo.path, target);
      ref.read(spikeResultsProvider.notifier).record(_key, result);
      if (mounted) setState(() => _last = result);
    } on CameraException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nie udało się zrobić zdjęcia: ${e.code}')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Target? _findTarget(ContentPack pack) => switch (widget.kind) {
        'item' => pack.items
            .where((i) => i.id == widget.targetId)
            .map<Target>(ItemTarget.new)
            .firstOrNull,
        'color' => pack.colors
            .where((c) => c.id == widget.targetId)
            .map<Target>(ColorTarget.new)
            .firstOrNull,
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    final pack = ref.watch(basePackProvider).value;
    final target = pack == null ? null : _findTarget(pack);
    final controller = _controller;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (controller != null && controller.value.isInitialized)
            Center(child: CameraPreview(controller))
          else
            Center(
              child: Text(
                _cameraError ?? 'Włączam aparat…',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          const _Frame(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _TaskBar(target: target, onBack: () => context.pop()),
                  const Spacer(),
                  if (_last != null) _ResultPanel(result: _last!),
                  const SizedBox(height: 16),
                  _Shutter(
                    busy: _busy,
                    onPressed: target == null ? null : () => _shoot(target),
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

class _TaskBar extends StatelessWidget {
  const _TaskBar({required this.target, required this.onBack});
  final Target? target;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          IconButton.filled(
            tooltip: 'Wróć',
            style: IconButton.styleFrom(backgroundColor: Colors.black54),
            onPressed: onBack,
            icon: const Icon(Icons.close, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(
                    text: target?.words['pl'] ?? '…',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: FoxColors.ink,
                    ),
                  ),
                  TextSpan(
                    text: '  ${target?.words['en'] ?? ''}',
                    style: const TextStyle(fontSize: 18, color: FoxColors.sky),
                  ),
                ]),
              ),
            ),
          ),
        ],
      );
}

/// Corner brackets around the centre of the frame, where the colour sample is
/// taken and where the child should aim.
class _Frame extends StatelessWidget {
  const _Frame();

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: Center(
          child: FractionallySizedBox(
            widthFactor: 0.55,
            child: AspectRatio(
              aspectRatio: 1,
              child: CustomPaint(painter: _FramePainter()),
            ),
          ),
        ),
      );
}

class _FramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final l = size.width * 0.2;
    final w = size.width, h = size.height;
    for (final (start, a, b) in [
      (Offset.zero, Offset(l, 0), Offset(0, l)),
      (Offset(w, 0), Offset(w - l, 0), Offset(w, l)),
      (Offset(0, h), Offset(l, h), Offset(0, h - l)),
      (Offset(w, h), Offset(w - l, h), Offset(w, h - l)),
    ]) {
      canvas
        ..drawLine(start, a, paint)
        ..drawLine(start, b, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({required this.result});
  final RecognitionResult result;

  @override
  Widget build(BuildContext context) {
    final (title, color) = switch (result.verdict) {
      Verdict.hit => ('Brawo! Znalezione', FoxColors.jungle),
      Verdict.almost => ('Prawie! Podejdź bliżej', FoxColors.sunDark),
      Verdict.miss => ('Szukaj dalej', FoxColors.coral),
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Model widzi: ${result.signals.take(5).join(', ')}',
            style: const TextStyle(color: FoxColors.ink),
          ),
          Text(
            'Czas: ${result.elapsed.inMilliseconds} ms'
            '${result.matched == null ? '' : ' · pasuje: ${result.matched}'}',
            style: const TextStyle(color: FoxColors.muted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _Shutter extends StatelessWidget {
  const _Shutter({required this.busy, required this.onPressed});
  final bool busy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: 'Zrób zdjęcie',
        child: GestureDetector(
          onTap: busy ? null : onPressed,
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: FoxColors.sun, width: 8),
            ),
            child: busy
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(strokeWidth: 4),
                  )
                : const Icon(Icons.photo_camera, size: 40, color: FoxColors.ink),
          ),
        ),
      );
}
