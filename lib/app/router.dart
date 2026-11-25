import 'package:go_router/go_router.dart';

import '../features/spike/spike_camera_screen.dart';
import '../features/spike/spike_home_screen.dart';

/// For now the app opens on the recognition spike. Game screens from the
/// design (start, task, hunt, reward, album, parent zone) come next.
final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SpikeHomeScreen(),
      routes: [
        GoRoute(
          path: 'hunt/:kind/:id',
          builder: (context, state) => SpikeCameraScreen(
            kind: state.pathParameters['kind']!,
            targetId: state.pathParameters['id']!,
          ),
        ),
      ],
    ),
  ],
);
