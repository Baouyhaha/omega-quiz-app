import 'package:flutter/material.dart';

import 'core/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Omega Quiz',
      theme: buildAppTheme(),
      home: const Scaffold(
        body: Center(child: Text('Omega Quiz')),
      ),
    );
  }
}
