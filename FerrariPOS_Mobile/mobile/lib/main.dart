import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'screens/home.dart';
import 'screens/settings.dart';

final api = ApiService();

void main() async { WidgetsFlutterBinding.ensureInitialized(); await api.load(); runApp(const FerrariApp()); }

class FerrariApp extends StatelessWidget {
  const FerrariApp({super.key});
  @override Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false, title: "Ferrari's POS",
    theme: ThemeData.dark(useMaterial3: true).copyWith(
      scaffoldBackgroundColor: const Color(0xFF101318),
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F7DFF), brightness: Brightness.dark),
      cardTheme: const CardThemeData(color: Color(0xFF191E26), margin: EdgeInsets.zero),
    ),
    home: api.baseUrl.isEmpty ? const SettingsScreen(firstRun: true) : const HomeScreen(),
  );
}
