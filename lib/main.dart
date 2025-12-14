import 'package:flutter/material.dart';
import 'package:ahmedlb_tenis_flutter_marcador_proyecto/config/router/app_router.dart';
import 'package:ahmedlb_tenis_flutter_marcador_proyecto/config/theme/app_theme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Juez de Silla Tenis',
      routerConfig: appRouter,
      theme: AppTheme(selectedColor: 0).getTheme(),
    );
  }
}
