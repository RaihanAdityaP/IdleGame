import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../core/game_state.dart';
import '../core/localization.dart';
import 'app_bar.dart';
import 'stats_panel.dart';
import 'tap_zone.dart';
import 'shop_panel.dart';
import 'event_bar.dart';
import 'settings_screen.dart';

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

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: RP.panel,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: RP.red, width: 2),
          borderRadius: BorderRadius.zero,
        ),
        title: Text(L10n.get('reset_title'), style: px(size: 10, color: RP.red)),
        content: Text(L10n.get('reset_body'), style: px(size: 7, color: RP.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(L10n.get('batal'), style: px(size: 7, color: RP.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<GameState>().reset();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  backgroundColor: RP.red,
                  content: Text(L10n.get('reset_success'), style: px(size: 7)),
                  duration: const Duration(seconds: 2),
                ));
              }
            },
            child: Text(L10n.get('reset'), style: px(size: 7, color: RP.red)),
          ),
        ],
      ),
    );
  }

  void _openSettings() {
    final state = context.read<GameState>();
    Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen(gameState: state)));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    return Scaffold(
      backgroundColor: RP.bg,
      body: SafeArea(
        child: Column(
          children: [
            GameAppBar(onReset: _showResetDialog, onSettings: _openSettings),
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