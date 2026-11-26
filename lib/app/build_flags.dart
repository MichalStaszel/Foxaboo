import 'package:flutter/foundation.dart';

/// Builds for testing on a phone (the APK from CI) pass
/// `--dart-define=FOXABOO_TEST_BUILD=true`. They show a "test unlock" button
/// so every room can be tried without a Play Store purchase.
const testBuild = kDebugMode || bool.fromEnvironment('FOXABOO_TEST_BUILD');
