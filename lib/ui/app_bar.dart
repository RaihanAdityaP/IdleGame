import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/localization.dart';

class GameAppBar extends StatelessWidget {
  final VoidCallback onReset;
  final VoidCallback onSettings;
  const GameAppBar({super.key, required this.onReset, required this.onSettings});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: RP.panel,
        border: Border(bottom: BorderSide(color: RP.orange, width: 2)),
      ),
      child: Row(
        children: [
          Icon(Icons.storefront_rounded, color: RP.orange, size: 18),
          const SizedBox(width: 10),
          Text(L10n.get('app_title'), style: px(size: 11, color: RP.orange)),
          const Spacer(),

          // Settings button
          GestureDetector(
            onTap: onSettings,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(color: RP.blue, width: 1.5),
                color: RP.blue.withValues(alpha: 0.1),
              ),
              child: Icon(Icons.settings, color: RP.blue, size: 13),
            ),
          ),
          const SizedBox(width: 8),

          // Reset button
          GestureDetector(
            onTap: onReset,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(color: RP.red, width: 1.5),
                color: RP.red.withValues(alpha: 0.1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, color: RP.red, size: 11),
                  const SizedBox(width: 4),
                  Text(L10n.get('reset'), style: px(size: 6, color: RP.red)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          _Dot(RP.green), const SizedBox(width: 5),
          _Dot(RP.yellow), const SizedBox(width: 5),
          _Dot(RP.red),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color c;
  const _Dot(this.c);
  @override
  Widget build(BuildContext ctx) => Container(width: 9, height: 9, color: c);
}