import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/dashboard.dart';
import 'screens/parcelas.dart';
import 'screens/diagnostico.dart';
import 'screens/chat.dart';
import 'screens/costos.dart';

void main() {
  runApp(MultiProvider(providers: [ChangeNotifierProvider(create: (_) => AppProvider())], child: const AgroIAApp()));
}

class AgroIAApp extends StatelessWidget {
  const AgroIAApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'AgroIA', debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: const ColorScheme.dark(primary: Color(0xFF2ECC71), surface: Color(0xFF1A2A1E)),
      scaffoldBackgroundColor: const Color(0xFF0A0F0D), useMaterial3: true,
      appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF111A14), foregroundColor: Color(0xFFE8F5EC), elevation: 0),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(backgroundColor: Color(0xFF111A14), selectedItemColor: Color(0xFF2ECC71), unselectedItemColor: Color(0xFF9DBFA8)),
    ),
    home: const HomeNav(),
  );
}

class HomeNav extends StatefulWidget {
  const HomeNav({super.key});
  @override
  State<HomeNav> createState() => _HomeNavState();
}
class _HomeNavState extends State<HomeNav> {
  int _idx = 0;
  final List<Widget> _s = const [DashboardScreen(), ParcelasScreen(), DiagnosticoScreen(), ChatScreen(), CostosScreen()];
  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(index: _idx, children: _s),
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: _idx, onTap: (i) => setState(() => _idx = i), type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Parcelas'),
        BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Diagnostico'),
        BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: 'IA'),
        BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Costos'),
      ],
    ),
  );
}
