import 'package:flutter/material.dart';

import 'core/uy_theme.dart';
import 'routes.dart';

// Diem chay thu RIENG cho cac man hinh phan cua Uy.
// Chay: flutter run -t lib/main_uy_preview.dart
// File main.dart chinh cua nhom giu nguyen nhu tren main — file nay chi
// them moi, khong sua file chung nao, nen khong anh huong cac ban khac.
void main() {
  runApp(const UyPreviewApp());
}

class UyPreviewApp extends StatelessWidget {
  const UyPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Omega Quiz — Preview phần Uy',
      debugShowCheckedModeBanner: false,
      theme: buildUyTheme(),
      initialRoute: AppRoutes.mh01,
      routes: appRoutes(),
    );
  }
}
