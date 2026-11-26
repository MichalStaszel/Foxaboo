import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The app promises parents that nothing leaves the phone. CI also checks
/// the built APK (tool/check_permissions.sh); this catches it earlier.
void main() {
  final manifest =
      File('android/app/src/main/AndroidManifest.xml').readAsStringSync();

  for (final permission in [
    'android.permission.INTERNET',
    'android.permission.ACCESS_NETWORK_STATE',
    'android.permission.RECORD_AUDIO',
  ]) {
    test('the manifest removes $permission that libraries add', () {
      expect(
        manifest,
        contains('<uses-permission android:name="$permission" '
            'tools:node="remove" />'),
      );
    });
  }

  test('no Dart code opens network connections', () {
    final offenders = [
      for (final f in Directory('lib').listSync(recursive: true))
        if (f is File && f.path.endsWith('.dart'))
          if (RegExp(r'HttpClient|package:http/|Socket\.connect|WebSocket')
              .hasMatch(f.readAsStringSync()))
            f.path,
    ];
    expect(offenders, isEmpty);
  });
}
