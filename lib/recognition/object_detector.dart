import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import 'detector_classes.dart';
import 'label_matcher.dart';
import 'recognition_result.dart';

/// Second recogniser: EfficientDet-Lite2 trained on COCO (MediaPipe model,
/// Apache 2.0), bundled in assets/models and run on the phone.
///
/// ML Kit's labeler describes the whole picture, so for a sofa or a laptop
/// it often answers "Room", "Wall" or "Shelf" first. A detector looks for
/// objects anywhere in the photo, which suits big things, and knows classes
/// ML Kit has no label for (laptop, keyboard, remote, book, bed, fridge...).
const detectorAsset = 'assets/models/efficientdet_lite2.tflite';

/// Detector scores are per class, not a ranking, so there is no top-K.
/// Calibrated on 600 Open Images photos: at 0.40 about 72% of big objects
/// are found with about 1% false positives.
const detectorThresholds = LabelThresholds(hit: 0.40, almost: 0.25, topK: 1000);

/// Best score per COCO class in the photo. Top-level so it can run in a
/// background isolate: it decodes the JPEG, crops the centre square (what
/// the child sees on screen), and runs the model.
Map<String, double> detectObjects((Uint8List model, String path) job) {
  final (modelBytes, path) = job;
  final decoded = img.decodeJpg(File(path).readAsBytesSync());
  if (decoded == null) return const {};
  final upright = img.bakeOrientation(decoded);
  final side = upright.width < upright.height ? upright.width : upright.height;
  final square = img.copyCrop(
    upright,
    x: (upright.width - side) ~/ 2,
    y: (upright.height - side) ~/ 2,
    width: side,
    height: side,
  );

  final interpreter = Interpreter.fromBuffer(modelBytes);
  try {
    final input = interpreter.getInputTensor(0);
    final size = input.shape[1];
    final small = img.copyResize(
      square,
      width: size,
      height: size,
      interpolation: img.Interpolation.linear,
    );
    final rgb = Uint8List(size * size * 3);
    var i = 0;
    for (final p in small) {
      rgb[i++] = p.r.toInt();
      rgb[i++] = p.g.toInt();
      rgb[i++] = p.b.toInt();
    }
    input.data = rgb;
    interpreter.invoke();

    final classes = detectorClasses.length;
    final scores = interpreter.getOutputTensors().firstWhere(
      (t) => t.shape.last == classes,
    );
    return maxScorePerClass(
      scores.data.buffer.asFloat32List(
        scores.data.offsetInBytes,
        scores.data.lengthInBytes ~/ 4,
      ),
    );
  } finally {
    interpreter.close();
  }
}

/// Reduces the model's anchors × classes scores to the best score per class.
Map<String, double> maxScorePerClass(Float32List scores) {
  final classes = detectorClasses.length;
  final best = Float32List(classes);
  for (var a = 0; a < scores.length; a += classes) {
    for (var c = 0; c < classes; c++) {
      final s = scores[a + c];
      if (s > best[c]) best[c] = s;
    }
  }
  return {
    for (var c = 0; c < classes; c++)
      if (best[c] > 0.05 && detectorClasses[c] != '???')
        detectorClasses[c]: best[c],
  };
}

RecognitionResult matchDetections({
  required Map<String, double> scores,
  required List<String> acceptedClasses,
}) => matchLabels(
  labels: [for (final e in scores.entries) Signal(e.key, e.value)],
  acceptedLabels: acceptedClasses,
  thresholds: detectorThresholds,
);
