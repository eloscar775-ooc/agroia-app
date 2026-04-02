import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/parcelas_screen.dart';
import 'screens/diagnostico_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/costos_screen.dart';
import 'providers/app_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: const AgroIAApp(),
    ),
  );
}

class AgroIAApp extends StatelessWidget {
  const AgroIAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgroIA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF2ECC71),
          secondary: const Color(0xFF00FF88),
          surface: const Color(0xFF1A2A1E),
        ),
        scaffoldBackgroundColor: const Color(0xFF0A0F0D),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF111A14),
          foregroundColor: Color(0xFFE8F5EC),
          elevation: 0,
        ),
        cardTheme: const CardTheme(
          color: Color(0xFF1A2A1E),
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF111A14),
          selectedItemColor: Color(0xFF2ECC71),
          unselectedItemColor: Color(0xFF9DBFA8),
        ),
      ),
      home: const MainNavigator(),
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ParcelasScreen(),
    const DiagnosticoScreen(),
    const ChatScreen(),
    const CostosScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Parcelas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Diagnostico',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy),
            label: 'IA',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Costos',
          ),
        ],
      ),
    );
  }
}
