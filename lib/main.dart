import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────
//  ENTRY
// ─────────────────────────────────────────────
void main() => runApp(
      MaterialApp(
        home: const IdleWarungApp(),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          textTheme: GoogleFonts.pressStart2pTextTheme(),
        ),
      ),
    );

class IdleWarungApp extends StatelessWidget {
  const IdleWarungApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameState()..load(),
      child: const MainScreen(),
    );
  }
}

// ─────────────────────────────────────────────
//  PALETTE
// ─────────────────────────────────────────────
class RP {
  static const bg     = Color(0xFF0D0D0D);
  static const panel  = Color(0xFF1A1A2E);
  static const card   = Color(0xFF16213E);
  static const border = Color(0xFF0F3460);
  static const orange = Color(0xFFE94560);
  static const yellow = Color(0xFFFFD700);
  static const green  = Color(0xFF39FF14);
  static const blue   = Color(0xFF00D4FF);
  static const purple = Color(0xFFB44FFF);
  static const white  = Color(0xFFE8E8E8);
  static const grey   = Color(0xFF4A4A6A);
  static const red    = Color(0xFFFF2D55);
}

// ─────────────────────────────────────────────
//  MODEL
// ─────────────────────────────────────────────
class Upgrade {
  final String id, name;
  final double baseCost, cps, cpc;
  final IconData icon;
  final bool isTap;
  int owned;

  Upgrade({
    required this.id, required this.name,
    required this.baseCost, required this.cps, required this.cpc,
    required this.icon, required this.isTap, required this.owned,
  });

  double get currentCost => baseCost * pow(1.15, owned);
}

enum EventType { airdrop, rushHour, vip, bencana }

class GameEvent {
  final EventType type;
  final String title, desc;
  final Color color;
  final IconData icon;
  final int durationSec;
  final double value;

  const GameEvent({
    required this.type, required this.title, required this.desc,
    required this.color, required this.icon,
    required this.durationSec, required this.value,
  });
}

const _allEvents = [
  GameEvent(type: EventType.airdrop,  title: 'AIRDROP!',       desc: 'Bonus koin dari langit!',    color: RP.yellow, icon: Icons.card_giftcard,  durationSec: 0,  value: 500),
  GameEvent(type: EventType.rushHour, title: 'RUSH HOUR!',     desc: 'CPS 2x selama 15 detik!',    color: RP.green,  icon: Icons.bolt,           durationSec: 15, value: 2),
  GameEvent(type: EventType.vip,      title: 'PELANGGAN VIP!', desc: 'TAP 5x selama 20 detik!',    color: RP.blue,   icon: Icons.star,           durationSec: 20, value: 5),
  GameEvent(type: EventType.bencana,  title: 'BENCANA!',       desc: 'Bayar atau CPS turun 30%!',  color: RP.red,    icon: Icons.warning_amber,  durationSec: 0,  value: 0.3),
];

// ─────────────────────────────────────────────
//  STATE
// ─────────────────────────────────────────────
class GameState extends ChangeNotifier {
  double _coins    = 0;
  double _baseCps  = 0;
  double _baseCpc  = 1;
  double _cpsMult  = 1;
  double _cpcMult  = 1;

  double get coins          => _coins;
  double get coinsPerSecond => _baseCps * _cpsMult;
  double get coinsPerClick  => _baseCpc * _cpcMult;

  GameEvent? activeEvent;
  int        eventSecondsLeft = 0;
  bool       pendingBencana   = false;
  double     bencanaPayAmount = 0;

  final Set<int> _reachedMilestones = {};
  static const _milestones = [1000, 10000, 50000, 200000, 1000000];

  Function(double)? onTapCallback;
  Function(GameEvent)? onEventTriggered;

  List<Upgrade> _makeUpgrades() => [
    Upgrade(id:'cup',      name:'Gelas Plastik',  baseCost:10,    cps:0.5,  cpc:0,  icon:Icons.local_drink,      isTap:false, owned:0),
    Upgrade(id:'gerobak',  name:'Gerobak Baru',   baseCost:100,   cps:3,    cpc:0,  icon:Icons.shopping_cart,    isTap:false, owned:0),
    Upgrade(id:'menu',     name:'Menu Tambahan',  baseCost:500,   cps:12,   cpc:0,  icon:Icons.restaurant_menu,  isTap:false, owned:0),
    Upgrade(id:'karyawan', name:'Pelayan',         baseCost:2000,  cps:40,   cpc:0,  icon:Icons.person,           isTap:false, owned:0),
    Upgrade(id:'dapur',    name:'Dapur Express',  baseCost:10000, cps:150,  cpc:0,  icon:Icons.outdoor_grill,    isTap:false, owned:0),
    Upgrade(id:'spatula',  name:'Spatula Pro',    baseCost:50,    cps:0,    cpc:5,  icon:Icons.soup_kitchen,     isTap:true,  owned:0),
    Upgrade(id:'tangan',   name:'Tangan Cepat',   baseCost:300,   cps:0,    cpc:20, icon:Icons.back_hand,        isTap:true,  owned:0),
    Upgrade(id:'resep',    name:'Resep Rahasia',  baseCost:1500,  cps:0,    cpc:80, icon:Icons.auto_stories,     isTap:true,  owned:0),
  ];

  late List<Upgrade> upgrades;

  Timer? _tickTimer;
  Timer? _saveTimer;
  Timer? _eventCountdown;
  Timer? _randomEventTimer;

  GameState() {
    upgrades = _makeUpgrades();
    _tickTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _coins += coinsPerSecond * 0.1;
      _checkMilestones();
      notifyListeners();
    });
    _saveTimer = Timer.periodic(const Duration(seconds: 5), (_) => save());
    _scheduleRandomEvent();
  }

  void _scheduleRandomEvent() {
    final delay = 30 + Random().nextInt(61);
    _randomEventTimer = Timer(Duration(seconds: delay), () {
      if (activeEvent == null) {
        triggerEvent(_allEvents[Random().nextInt(_allEvents.length)]);
      }
      _scheduleRandomEvent();
    });
  }

  void _checkMilestones() {
    for (final m in _milestones) {
      if (!_reachedMilestones.contains(m) && _coins >= m) {
        _reachedMilestones.add(m);
        if (activeEvent == null) {
          final positive = _allEvents.where((e) => e.type != EventType.bencana).toList();
          triggerEvent(positive[Random().nextInt(positive.length)]);
        }
      }
    }
  }

  void triggerEvent(GameEvent ev) {
    activeEvent      = ev;
    eventSecondsLeft = ev.durationSec;

    switch (ev.type) {
      case EventType.airdrop:
        final bonus = max(ev.value, coinsPerSecond * 10);
        _coins += bonus;
        Future.delayed(const Duration(seconds: 4), _clearEvent);
        break;
      case EventType.rushHour:
        _cpsMult = ev.value;
        _startCountdown(ev.durationSec);
        break;
      case EventType.vip:
        _cpcMult = ev.value;
        _startCountdown(ev.durationSec);
        break;
      case EventType.bencana:
        pendingBencana   = true;
        bencanaPayAmount = max(50, coinsPerSecond * 5);
        Future.delayed(const Duration(seconds: 10), () {
          if (pendingBencana) _applyBencana();
        });
        break;
    }

    onEventTriggered?.call(ev);
    notifyListeners();
  }

  void _startCountdown(int seconds) {
    _eventCountdown?.cancel();
    _eventCountdown = Timer.periodic(const Duration(seconds: 1), (_) {
      eventSecondsLeft--;
      if (eventSecondsLeft <= 0) {
        _eventCountdown?.cancel();
        _clearEvent();
      }
      notifyListeners();
    });
  }

  void payBencana() {
    if (_coins >= bencanaPayAmount) {
      _coins -= bencanaPayAmount;
      pendingBencana = false;
      _clearEvent();
      notifyListeners();
    }
  }

  void _applyBencana() {
    _baseCps *= (1 - (activeEvent?.value ?? 0.3));
    pendingBencana = false;
    _clearEvent();
    notifyListeners();
  }

  void _clearEvent() {
    _cpsMult       = 1;
    _cpcMult       = 1;
    activeEvent    = null;
    pendingBencana = false;
    notifyListeners();
  }

  void tap() {
    final gained = coinsPerClick;
    _coins += gained;
    onTapCallback?.call(gained);
    HapticFeedback.lightImpact();
    notifyListeners();
  }

  void buyUpgrade(Upgrade u) {
    if (_coins >= u.currentCost) {
      _coins -= u.currentCost;
      u.owned++;
      _baseCps += u.cps;
      _baseCpc += u.cpc;
      notifyListeners();
      save();
    }
  }

  // ── RESET ──────────────────────────────────
  Future<void> reset() async {
    _tickTimer?.cancel();
    _saveTimer?.cancel();
    _eventCountdown?.cancel();
    _randomEventTimer?.cancel();

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _coins    = 0;
    _baseCps  = 0;
    _baseCpc  = 1;
    _cpsMult  = 1;
    _cpcMult  = 1;
    activeEvent    = null;
    pendingBencana = false;
    eventSecondsLeft = 0;
    _reachedMilestones.clear();
    upgrades = _makeUpgrades();

    _tickTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _coins += coinsPerSecond * 0.1;
      _checkMilestones();
      notifyListeners();
    });
    _saveTimer = Timer.periodic(const Duration(seconds: 5), (_) => save());
    _scheduleRandomEvent();

    notifyListeners();
  }

  // ── SAVE ───────────────────────────────────
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('coins', _coins);
    // Simpan owned per upgrade (bukan baseCps langsung)
    await prefs.setString('upgrades', upgrades.map((u) => '${u.id}:${u.owned}').join(','));
    await prefs.setString('milestones', _reachedMilestones.join(','));
  }

  // ── LOAD ───────────────────────────────────
  // FIX: Hitung ulang _baseCps & _baseCpc dari owned, bukan dari nilai tersimpan.
  // Ini memastikan CPS selalu konsisten dengan jumlah upgrade yang dimiliki.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _coins = prefs.getDouble('coins') ?? 0;

    final saved = prefs.getString('upgrades') ?? '';
    for (final pair in saved.split(',')) {
      if (pair.isEmpty) continue;
      final parts = pair.split(':');
      if (parts.length == 2) {
        try {
          final u = upgrades.firstWhere((x) => x.id == parts[0]);
          u.owned = int.tryParse(parts[1]) ?? 0;
        } catch (_) {}
      }
    }

    // Hitung ulang dari scratch berdasarkan owned
    _baseCps = 0;
    _baseCpc = 1;
    for (final u in upgrades) {
      _baseCps += u.cps * u.owned;
      _baseCpc += u.cpc * u.owned;
    }

    final ms = prefs.getString('milestones') ?? '';
    for (final s in ms.split(',')) {
      final v = int.tryParse(s);
      if (v != null) _reachedMilestones.add(v);
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _saveTimer?.cancel();
    _eventCountdown?.cancel();
    _randomEventTimer?.cancel();
    save();
    super.dispose();
  }
}

// ─────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────
String fmtCoins(double v) {
  if (v >= 1e9)  return '${(v / 1e9).toStringAsFixed(2)}B';
  if (v >= 1e6)  return '${(v / 1e6).toStringAsFixed(2)}M';
  if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
  return v.toStringAsFixed(0);
}

TextStyle px({double size = 10, Color color = RP.white}) =>
    GoogleFonts.pressStart2p(fontSize: size, color: color);

// ─────────────────────────────────────────────
//  MAIN SCREEN
// ─────────────────────────────────────────────
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
      content: _EventBanner(event: ev),
    ));
  }

  // ── Dialog konfirmasi reset ─────────────────
  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: RP.panel,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: RP.red, width: 2),
          borderRadius: BorderRadius.zero,
        ),
        title: Text('RESET?', style: px(size: 10, color: RP.red)),
        content: Text(
          'Semua progress akan\ndihapus permanen!\n\nYakin?',
          style: px(size: 7, color: RP.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('BATAL', style: px(size: 7, color: RP.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<GameState>().reset();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: RP.red,
                    content: Text('Progress direset!', style: px(size: 7)),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: Text('RESET', style: px(size: 7, color: RP.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    return Scaffold(
      backgroundColor: RP.bg,
      body: SafeArea(
        child: Column(
          children: [
            _AppBar(onReset: _showResetDialog),
            _StatsPanel(state: state),
            if (state.activeEvent != null) _ActiveEventBar(state: state),
            Expanded(child: Center(child: const TapZone())),
            _ShopPanel(state: state),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  APP BAR
// ─────────────────────────────────────────────
class _AppBar extends StatelessWidget {
  final VoidCallback onReset;
  const _AppBar({required this.onReset});

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
          Text('IDLE WARUNG', style: px(size: 11, color: RP.orange)),
          const Spacer(),
          // Tombol Reset
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
                  Text('RESET', style: px(size: 6, color: RP.red)),
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

// ─────────────────────────────────────────────
//  STATS PANEL
// ─────────────────────────────────────────────
class _StatsPanel extends StatelessWidget {
  final GameState state;
  const _StatsPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    final cpsColor = state.activeEvent?.type == EventType.rushHour ? RP.green : RP.blue;
    final tapColor = state.activeEvent?.type == EventType.vip      ? RP.purple : RP.orange;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: RP.panel,
        border: Border.all(color: RP.border, width: 2),
      ),
      child: Column(
        children: [
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
              Expanded(child: _Chip(Icons.trending_up, 'CPS', '+${fmtCoins(state.coinsPerSecond)}/s', cpsColor)),
              const SizedBox(width: 8),
              Expanded(child: _Chip(Icons.touch_app, 'TAP', '+${fmtCoins(state.coinsPerClick)}', tapColor)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _Chip(this.icon, this.label, this.value, this.color);

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
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: px(size: 6,  color: color.withValues(alpha: 0.6))),
        Text(value,  style: px(size: 7,  color: color)),
      ]),
    ]),
  );
}

// ─────────────────────────────────────────────
//  ACTIVE EVENT BAR
// ─────────────────────────────────────────────
class _ActiveEventBar extends StatelessWidget {
  final GameState state;
  const _ActiveEventBar({required this.state});

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
          children: [
            Text(ev.title, style: px(size: 8, color: ev.color)),
            const SizedBox(height: 2),
            Text(ev.desc,  style: px(size: 6, color: RP.white.withValues(alpha: 0.6))),
          ],
        )),
        if (state.pendingBencana)
          GestureDetector(
            onTap: state.payBencana,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: RP.red,
                border: Border.all(color: Colors.white24, width: 1),
              ),
              child: Text('BAYAR\n${fmtCoins(state.bencanaPayAmount)}',
                  textAlign: TextAlign.center,
                  style: px(size: 6, color: RP.white)),
            ),
          )
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

// ─────────────────────────────────────────────
//  TAP ZONE
// ─────────────────────────────────────────────
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
    final btnColor = state.activeEvent?.type == EventType.vip     ? RP.purple
                   : state.activeEvent?.type == EventType.rushHour ? RP.green
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
                  boxShadow: [BoxShadow(color: btnColor.withValues(alpha: 0.35), blurRadius: 22, spreadRadius: 2)],
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

// ─────────────────────────────────────────────
//  SHOP PANEL
// ─────────────────────────────────────────────
class _ShopPanel extends StatelessWidget {
  final GameState state;
  const _ShopPanel({required this.state});

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
            Text('SHOP', style: px(size: 10, color: RP.orange)),
            const Spacer(),
            _ShopTag(Icons.access_time, 'IDLE', RP.blue),
            const SizedBox(width: 8),
            _ShopTag(Icons.touch_app, 'TAP', RP.green),
          ]),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            children: [
              _SectionLabel('── IDLE ──', RP.blue),
              ...idleUps.map((u) => _UpgradeTile(upgrade: u, state: state)),
              const SizedBox(height: 6),
              _SectionLabel('── TAP ──', RP.green),
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
          Text(upgrade.isTap ? '+${upgrade.cpc}/tap' : '+${upgrade.cps}/s',
              style: px(size: 5, color: color.withValues(alpha: 0.65))),
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
              Text('BELI', style: px(size: 6, color: canBuy ? RP.bg : RP.grey)),
              Text(fmtCoins(upgrade.currentCost),
                  style: px(size: 5, color: canBuy ? RP.bg.withValues(alpha: 0.65) : RP.grey)),
            ]),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
//  EVENT BANNER
// ─────────────────────────────────────────────
class _EventBanner extends StatelessWidget {
  final GameEvent event;
  const _EventBanner({required this.event});

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