import 'package:flutter/material.dart';

import 'core/uy_theme.dart';
import 'routes.dart';
import 'views/mh15_ban_be_screen.dart';

void main() {
  runApp(const ThinhPreviewApp());
}

class ThinhPreviewApp extends StatelessWidget {
  const ThinhPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Omega Quiz — Preview T16 Bạn bè',
      debugShowCheckedModeBanner: false,
      theme: buildUyTheme(),
      home: const Mh15BanBeScreen(token: 'dev:thinh'),
      routes: appRoutes(),
    );
  }
}
