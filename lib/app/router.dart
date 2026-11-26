import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/app_store.dart';
import '../features/album/album_screen.dart';
import '../features/home/home_screen.dart';
import '../features/parent/gate_screen.dart';
import '../features/parent/parent_screen.dart';
import '../features/round/round_screen.dart';
import '../features/setup/privacy_promise.dart';
import '../features/setup/setup_screen.dart';
import '../features/spike/spike_camera_screen.dart';
import '../features/spike/spike_home_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    redirect: (context, state) {
      final setUp = ref.read(appStoreProvider).isSetUp;
      if (!setUp && state.matchedLocation != '/setup') return '/setup';
      if (setUp && state.matchedLocation == '/setup') return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
      GoRoute(
        path: '/setup',
        builder: (_, _) => SetupScreen(
          deviceLanguage: PlatformDispatcher.instance.locale.languageCode,
        ),
      ),
      GoRoute(
        path: '/round/:mode',
        builder: (_, state) =>
            RoundScreen(mode: state.pathParameters['mode']!),
      ),
      GoRoute(path: '/album', builder: (_, _) => const AlbumScreen()),
      GoRoute(path: '/gate', builder: (_, _) => const GateScreen()),
      GoRoute(path: '/parent', builder: (_, _) => const ParentScreen()),
      GoRoute(path: '/privacy', builder: (_, _) => const PrivacyScreen()),
      // Recognition test from the spike, reachable from the parent zone.
      GoRoute(
        path: '/spike',
        builder: (_, _) => const SpikeHomeScreen(),
        routes: [
          GoRoute(
            path: 'hunt/:kind/:id',
            builder: (_, state) => SpikeCameraScreen(
              kind: state.pathParameters['kind']!,
              targetId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
    ],
  );
});
