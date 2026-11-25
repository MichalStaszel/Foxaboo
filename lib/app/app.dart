import 'package:material_ui/material_ui.dart';

import 'router.dart';
import 'theme.dart';

class FoxabooApp extends StatelessWidget {
  const FoxabooApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Foxaboo',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      routerConfig: appRouter,
    );
  }
}
