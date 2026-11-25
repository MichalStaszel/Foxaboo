import 'dart:io';
import 'dart:isolate';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image/image.dart' as img;

import '../content/models.dart';
import 'color_classifier.dart';
import 'label_matcher.dart';
import 'recognition_result.dart';

/// Checks a photo against a target. Screens only talk to this interface, so
/// swapping ML Kit for our own model later changes one class.
///
/// The photo never leaves the phone and is deleted right after the check.
abstract class Recognizer {
  Future<RecognitionResult> recognize(String photoPath, Target target);
  Future<void> dispose();
}

/// Routes items to the label model and colours to the colour classifier.
class GameRecognizer implements Recognizer {
  GameRecognizer({
    this.labelThresholds = const LabelThresholds(),
    this.colorThresholds = const ColorThresholds(),
  }) : _labeler = ImageLabeler(
          options: ImageLabelerOptions(confidenceThreshold: 0.15),
        );

  final LabelThresholds labelThresholds;
  final ColorThresholds colorThresholds;
  final ImageLabeler _labeler;

  @override
  Future<RecognitionResult> recognize(String photoPath, Target target) async {
    final watch = Stopwatch()..start();
    try {
      final result = switch (target) {
        ItemTarget(:final item) => await _recognizeItem(photoPath, item),
        ColorTarget(:final color) => await _recognizeColor(photoPath, color),
      };
      return result.withElapsed(watch.elapsed);
    } finally {
      await _deletePhoto(photoPath);
    }
  }

  Future<RecognitionResult> _recognizeItem(String path, Item item) async {
    final labels = await _labeler.processImage(InputImage.fromFilePath(path));
    return matchLabels(
      labels: [for (final l in labels) Signal(l.label, l.confidence)],
      acceptedLabels: item.labels,
      thresholds: labelThresholds,
    );
  }

  Future<RecognitionResult> _recognizeColor(String path, HuntColor color) async {
    final shares = await Isolate.run(() => centerColorShares(path));
    return matchColor(
      shares: shares,
      targetColor: color.id,
      thresholds: colorThresholds,
    );
  }

  Future<void> _deletePhoto(String path) async {
    try {
      await File(path).delete();
    } on FileSystemException {
      // Already gone; nothing to clean up.
    }
  }

  @override
  Future<void> dispose() => _labeler.close();
}

/// Colour shares of the central 30% of the photo (where the frame is drawn).
/// Runs in a background isolate because decoding a camera JPEG is slow.
List<Signal> centerColorShares(String path) {
  final decoded = img.decodeJpg(File(path).readAsBytesSync());
  if (decoded == null) return const [];
  final upright = img.bakeOrientation(decoded);
  final side = (upright.width < upright.height ? upright.width : upright.height);
  final crop = (side * 0.30).round();
  final center = img.copyCrop(
    upright,
    x: (upright.width - crop) ~/ 2,
    y: (upright.height - crop) ~/ 2,
    width: crop,
    height: crop,
  );
  final small = img.copyResize(center, width: 64, height: 64);
  final pixels = <int>[
    for (final p in small)
      (p.r.toInt() << 16) | (p.g.toInt() << 8) | p.b.toInt(),
  ];
  return colorShares(pixels);
}

final recognizerProvider = Provider<Recognizer>((ref) {
  final recognizer = GameRecognizer();
  ref.onDispose(recognizer.dispose);
  return recognizer;
});
