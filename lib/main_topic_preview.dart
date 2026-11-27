import 'package:flutter/material.dart';

import 'core/uy_theme.dart';
import 'routes.dart';
import 'views/mh05_chu_de_screen.dart';

void main() {
  runApp(const TopicPreviewApp());
}

class TopicPreviewApp extends StatelessWidget {
  const TopicPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Omega Quiz — Preview T17 Chủ đề',
      debugShowCheckedModeBanner: false,
      theme: buildUyTheme(),
      home: const Mh05ChuDeScreen(token: 'dev:thinh'),
      routes: appRoutes(),
    );
  }
}
