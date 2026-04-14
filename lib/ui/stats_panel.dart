import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/game_state.dart';
import '../core/localization.dart';

class StatsPanel extends StatelessWidget {
  final GameState state;
  const StatsPanel({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final cpsColor = (state.activeEvent?.type == EventType.rushHour ||
                      state.activeEvent?.type == EventType.promo    ||
                      state.activeEvent?.type == EventType.gajian   ||
                      state.activeEvent?.type == EventType.supplier)
        ? RP.green
        : RP.blue;

    final tapColor = (state.activeEvent?.type == EventType.vip ||
                      state.activeEvent?.type == EventType.festival)
        ? RP.purple
        : RP.orange;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: RP.panel,
        border: Border.all(color: RP.border, width: 2),
      ),
      child: Column(
        children: [
          // Coin display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.monetization_on, color: RP.yellow, size: 20),
              const SizedBox(width: 8),
              Text(fmtCoins(state.coins), style: px(size: 20, color: RP.yellow)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Income auto - friendly label, no "CPS"
              Expanded(child: _StatChip(
                icon: Icons.access_time,
                label: L10n.get('income_auto'),
                value: '+${fmtCoins(state.coinsPerSecond)}${L10n.get('per_second')}',
                color: cpsColor,
              )),
              const SizedBox(width: 8),
              // Tap income - friendly label, no "CPC"
              Expanded(child: _StatChip(
                icon: Icons.touch_app,
                label: L10n.get('income_tap'),
                value: '+${fmtCoins(state.coinsPerClick)}${L10n.get('per_tap')}',
                color: tapColor,
              )),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.08),
      border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
    ),
    child: Row(children: [
      Icon(icon, color: color, size: 14),
      const SizedBox(width: 6),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: px(size: 4.5, color: color.withValues(alpha: 0.6))),
          const SizedBox(height: 2),
          Text(value, style: px(size: 6.5, color: color)),
        ]),
      ),
    ]),
  );
}