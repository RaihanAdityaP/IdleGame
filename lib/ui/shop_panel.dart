import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/game_state.dart';
import '../core/localization.dart';

class ShopPanel extends StatelessWidget {
  final GameState state;
  const ShopPanel({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final idleUps = state.upgrades.where((u) => !u.isTap).toList();
    final tapUps  = state.upgrades.where((u) =>  u.isTap).toList();

    return Container(
      height: 310,
      decoration: BoxDecoration(
        color: RP.panel,
        border: Border(top: BorderSide(color: RP.border, width: 2)),
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
          child: Row(children: [
            Icon(Icons.storefront, color: RP.orange, size: 14),
            const SizedBox(width: 8),
            Text(L10n.get('shop'), style: px(size: 8, color: RP.orange)),
            const Spacer(),
            _ShopTag(Icons.access_time, L10n.get('tag_idle'), RP.blue),
            const SizedBox(width: 8),
            _ShopTag(Icons.touch_app, L10n.get('tag_tap'), RP.green),
          ]),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            children: [
              _SectionLabel(L10n.get('section_idle'), RP.blue),
              ...idleUps.map((u) => _UpgradeTile(upgrade: u, state: state)),
              const SizedBox(height: 6),
              _SectionLabel(L10n.get('section_tap'), RP.green),
              ...tapUps.map((u) => _UpgradeTile(upgrade: u, state: state)),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ]),
    );
  }
}

class _ShopTag extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _ShopTag(this.icon, this.label, this.color);
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 10, color: color),
    const SizedBox(width: 3),
    Text(label, style: px(size: 6, color: color)),
  ]);
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final Color color;
  const _SectionLabel(this.text, this.color);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Text(text, style: px(size: 6, color: color.withValues(alpha: 0.55))),
  );
}

class _UpgradeTile extends StatelessWidget {
  final Upgrade upgrade;
  final GameState state;
  const _UpgradeTile({required this.upgrade, required this.state});

  @override
  Widget build(BuildContext context) {
    final canBuy = state.coins >= upgrade.currentCost;
    final color  = upgrade.isTap ? RP.green : RP.blue;
    final statLabel = upgrade.isTap
        ? '+${upgrade.cpc}${L10n.get("stat_per_tap")}'
        : '+${upgrade.cps}${L10n.get("stat_per_s")}';

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: canBuy ? color.withValues(alpha: 0.07) : RP.card,
        border: Border.all(color: canBuy ? color.withValues(alpha: 0.45) : RP.border, width: 1.5),
      ),
      child: Row(children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            color: canBuy ? color.withValues(alpha: 0.15) : RP.border.withValues(alpha: 0.3),
            border: Border.all(color: canBuy ? color : RP.grey, width: 1),
          ),
          child: Icon(upgrade.icon, color: canBuy ? color : RP.grey, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${upgrade.name} [${upgrade.owned}]',
              style: px(size: 6, color: canBuy ? RP.white : RP.grey)),
          const SizedBox(height: 4),
          Text(statLabel, style: px(size: 5, color: color.withValues(alpha: 0.65))),
        ])),
        GestureDetector(
          onTap: canBuy ? () => state.buyUpgrade(upgrade) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: canBuy ? color : Colors.transparent,
              border: Border.all(color: canBuy ? color : RP.grey, width: 1.5),
            ),
            child: Column(children: [
              Text(L10n.get('beli'), style: px(size: 6, color: canBuy ? RP.bg : RP.grey)),
              Text(fmtCoins(upgrade.currentCost),
                  style: px(size: 5, color: canBuy ? RP.bg.withValues(alpha: 0.65) : RP.grey)),
            ]),
          ),
        ),
      ]),
    );
  }
}