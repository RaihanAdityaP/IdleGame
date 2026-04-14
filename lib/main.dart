import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../core/game_state.dart';
import '../ui/app_bar.dart';
import '../ui/stats_panel.dart';
import '../ui/tap_zone.dart';
import '../ui/shop_panel.dart';
import '../ui/event_bar.dart';
import '../ui/settings_screen.dart';

void main() {
  runApp(const IdleWarungApp());
}

class IdleWarungApp extends StatelessWidget {
  const IdleWarungApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameState(),
      child: MaterialApp(
        title: 'Idle Warung',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: RP.bg,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameState>().load();
      context.read<GameState>().onEventTriggered = _showEventBanner;
    });
  }

  void _showEventBanner(GameEvent ev) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      duration: const Duration(seconds: 3),
      content: EventBanner(event: ev),
    ));
  }

  void _openSettings() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    return Scaffold(
      backgroundColor: RP.bg,
      body: SafeArea(
        child: Column(
          children: [
            GameAppBar(onSettings: _openSettings),
            StatsPanel(state: state),
            if (state.activeEvent != null) ActiveEventBar(state: state),
            Expanded(child: Center(child: const TapZone())),
            ShopPanel(state: state),
          ],
        ),
      ),
    );
  }
}