import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../core/game_state.dart';

class TapZone extends StatefulWidget {
  const TapZone({super.key});
  @override
  State<TapZone> createState() => _TapZoneState();
}

class _TapZoneState extends State<TapZone> with TickerProviderStateMixin {
  late final AnimationController _scale;
  late final AnimationController _pulse;
  final List<_FloatItem> _floats = [];

  @override
  void initState() {
    super.initState();
    _scale = AnimationController(vsync: this, duration: const Duration(milliseconds: 80));
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameState>().onTapCallback = _spawnFloat;
    });
  }

  void _spawnFloat(double amount) {
    final item = _FloatItem(
      id: DateTime.now().microsecondsSinceEpoch,
      label: '+${fmtCoins(amount)}',
      dx: (Random().nextDouble() - 0.5) * 100,
    );
    setState(() => _floats.add(item));
    Future.delayed(const Duration(milliseconds: 950), () {
      if (mounted) setState(() => _floats.remove(item));
    });
  }

  void _handleTap() {
    context.read<GameState>().tap();
    _scale.forward().then((_) => _scale.reverse());
  }

  @override
  void dispose() {
    context.read<GameState>().onTapCallback = null;
    _scale.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    final btnColor = state.activeEvent?.type == EventType.vip      ? RP.purple
                   : state.activeEvent?.type == EventType.festival  ? RP.teal
                   : state.activeEvent?.type == EventType.rushHour  ? RP.green
                   : RP.orange;

    return SizedBox(
      width: 240, height: 240,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, _) => Transform.scale(
              scale: 1.0 + _pulse.value * 0.45,
              child: Opacity(
                opacity: (1.0 - _pulse.value).clamp(0.0, 1.0),
                child: Container(
                  width: 160, height: 160,
                  decoration: BoxDecoration(
                    border: Border.all(color: btnColor, width: 3),
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: _handleTap,
            child: AnimatedBuilder(
              animation: _scale,
              builder: (_, child) => Transform.scale(
                scale: 1.0 - _scale.value * 0.08,
                child: child,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 158, height: 158,
                decoration: BoxDecoration(
                  color: btnColor.withValues(alpha: 0.13),
                  border: Border.all(color: btnColor, width: 3),
                  boxShadow: [BoxShadow(
                    color: btnColor.withValues(alpha: 0.35),
                    blurRadius: 22, spreadRadius: 2,
                  )],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.storefront_rounded, color: btnColor, size: 50),
                    const SizedBox(height: 8),
                    Text('TAP', style: px(size: 13, color: btnColor)),
                  ],
                ),
              ),
            ),
          ),
          ..._floats.map((f) => _FloatNumber(item: f, color: btnColor)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  FLOAT NUMBER
// ─────────────────────────────────────────────
class _FloatItem {
  final int id;
  final String label;
  final double dx;
  _FloatItem({required this.id, required this.label, required this.dx});
}

class _FloatNumber extends StatefulWidget {
  final _FloatItem item;
  final Color color;
  const _FloatNumber({required this.item, required this.color});
  @override
  State<_FloatNumber> createState() => _FloatNumberState();
}

class _FloatNumberState extends State<_FloatNumber> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity, _dy;

  @override
  void initState() {
    super.initState();
    _ctrl    = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
    _opacity = Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.4, 1.0)));
    _dy      = Tween(begin: 0.0, end: -80.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _ctrl,
    builder: (_, _) => Positioned(
      top:  60 + _dy.value,
      left: 120 + widget.item.dx,
      child: Opacity(
        opacity: _opacity.value,
        child: Text(widget.item.label, style: px(size: 10, color: widget.color)),
      ),
    ),
  );
}