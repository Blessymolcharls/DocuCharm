import "package:flutter/material.dart";
import "package:docucharm_frontend/core/theme/app_theme.dart";
import "package:docucharm_frontend/features/home/presentation/home_screen.dart";

void main() {
  runApp(const DocuCharmApp());
}

class DocuCharmApp extends StatelessWidget {
  const DocuCharmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "DocuCharm",
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
