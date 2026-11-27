import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'routes.dart';
import 'services/session.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase chỉ khởi tạo được khi máy đã có google-services.json
  // (xem docs/T14_HUONG_DAN_CAU_HINH_FIREBASE.md). Chưa có thì app
  // vẫn chạy ở chế độ token dev để kiểm thử giao diện và luồng API.
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Chua khoi tao duoc Firebase: $e');
  }
  await Session.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Omega Quiz',
      theme: buildAppTheme(),
      routes: appRoutes(),
      initialRoute: Session.daDangNhap ? AppRoutes.khung : AppRoutes.mh01,
    );
  }
}
