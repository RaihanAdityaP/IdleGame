import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/game_state.dart';
import '../core/localization.dart';

class ActiveEventBar extends StatelessWidget {
  final GameState state;
  const ActiveEventBar({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final ev = state.activeEvent!;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: ev.color.withValues(alpha: 0.12),
        border: Border.all(color: ev.color, width: 2),
      ),
      child: Row(children: [
        Icon(ev.icon, color: ev.color, size: 16),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(ev.title, style: px(size: 8, color: ev.color)),
            const SizedBox(height: 2),
            Text(ev.desc,  style: px(size: 5.5, color: RP.white.withValues(alpha: 0.6))),
          ],
        )),

        // Pay button for negative events
        if (state.pendingNegative)
          GestureDetector(
            onTap: state.payPenalty,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: RP.red,
                border: Border.all(color: Colors.white24, width: 1),
              ),
              child: Text(
                '${L10n.get("bayar")}\n${fmtCoins(state.penaltyPayAmount)}',
                textAlign: TextAlign.center,
                style: px(size: 6, color: RP.white),
              ),
            ),
          )
        // Countdown timer for duration events
        else if (state.eventSecondsLeft > 0)
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: ev.color.withValues(alpha: 0.15),
              border: Border.all(color: ev.color, width: 2),
            ),
            alignment: Alignment.center,
            child: Text('${state.eventSecondsLeft}s', style: px(size: 8, color: ev.color)),
          ),
      ]),
    );
  }
}

// Snackbar banner (used on event trigger)
class EventBanner extends StatelessWidget {
  final GameEvent event;
  const EventBanner({super.key, required this.event});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: RP.panel,
      border: Border.all(color: event.color, width: 2),
      boxShadow: [BoxShadow(color: event.color.withValues(alpha: 0.25), blurRadius: 14)],
    ),
    child: Row(children: [
      Icon(event.icon, color: event.color, size: 20),
      const SizedBox(width: 12),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(event.title, style: px(size: 9, color: event.color)),
          const SizedBox(height: 3),
          Text(event.desc,  style: px(size: 6, color: RP.white.withValues(alpha: 0.75))),
        ],
      )),
    ]),
  );
}