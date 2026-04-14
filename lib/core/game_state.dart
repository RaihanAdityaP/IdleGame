import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/localization.dart';
import '../data/upgrades_data.dart';
import '../data/events_data.dart';

export '../data/upgrades_data.dart';
export '../data/events_data.dart';

// ─────────────────────────────────────────────
//  GAME STATE
// ─────────────────────────────────────────────
class GameState extends ChangeNotifier {
  double _coins   = 0;
  double _baseCps = 0;
  double _baseCpc = 1;
  double _cpsMult = 1;
  double _cpcMult = 1;

  double get coins          => _coins;
  double get coinsPerSecond => _baseCps * _cpsMult;
  double get coinsPerClick  => _baseCpc * _cpcMult;

  GameEvent? activeEvent;
  int        eventSecondsLeft = 0;
  bool       pendingNegative  = false;  // generic flag for pay-or-penalty events
  double     penaltyPayAmount = 0;
  EventType? pendingType;               // which negative event is pending

  final Set<int> _reachedMilestones = {};
  static const _milestones = [500, 5000, 25000, 100000, 500000, 2000000];

  Function(double)?    onTapCallback;
  Function(GameEvent)? onEventTriggered;

  late List<Upgrade> upgrades;

  Timer? _tickTimer;
  Timer? _saveTimer;
  Timer? _eventCountdown;
  Timer? _randomEventTimer;
  Timer? _penaltyTimer;

  GameState() {
    upgrades = makeUpgrades();
    _tickTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _coins += coinsPerSecond * 0.1;
      _checkMilestones();
      notifyListeners();
    });
    _saveTimer = Timer.periodic(const Duration(seconds: 5), (_) => save());
    _scheduleRandomEvent();
  }

  // ── SCHEDULING ─────────────────────────────
  void _scheduleRandomEvent() {
    final delay = 25 + Random().nextInt(46); // 25–70s
    _randomEventTimer = Timer(Duration(seconds: delay), () {
      if (activeEvent == null) {
        triggerEvent(allEvents[Random().nextInt(allEvents.length)]);
      }
      _scheduleRandomEvent();
    });
  }

  void _checkMilestones() {
    for (final m in _milestones) {
      if (!_reachedMilestones.contains(m) && _coins >= m) {
        _reachedMilestones.add(m);
        if (activeEvent == null) {
          triggerEvent(positiveEvents[Random().nextInt(positiveEvents.length)]);
        }
      }
    }
  }

  // ── TRIGGER EVENT ──────────────────────────
  void triggerEvent(GameEvent ev) {
    activeEvent      = ev;
    eventSecondsLeft = ev.durationSec;

    switch (ev.type) {
      // ── POSITIVE INSTANTS ──
      case EventType.airdrop:
        final bonus = max(ev.value, coinsPerSecond * 15);
        _coins += bonus;
        Future.delayed(const Duration(seconds: 4), _clearEvent);

      case EventType.artis:
        final bonus = max(ev.value, coinsPerSecond * 30);
        _coins += bonus;
        Future.delayed(const Duration(seconds: 4), _clearEvent);

      // ── POSITIVE DURATION ──
      case EventType.rushHour:
        _cpsMult = ev.value;
        _startCountdown(ev.durationSec);

      case EventType.vip:
        _cpcMult = ev.value;
        _startCountdown(ev.durationSec);

      case EventType.promo:
        _cpsMult = ev.value;
        _startCountdown(ev.durationSec);

      case EventType.gajian:
        _cpsMult = ev.value;
        _startCountdown(ev.durationSec);

      case EventType.festival:
        _cpcMult = ev.value;
        _startCountdown(ev.durationSec);

      case EventType.supplier:
        _cpsMult = ev.value;
        _startCountdown(ev.durationSec);

      // ── NEGATIVE: PAY OR PENALTY ──
      case EventType.bencana:
        _setupPayOrPenalty(ev, penaltyMultiplier: 1 - ev.value, payMultiplier: 5);

      case EventType.hujan:
        _setupPayOrPenalty(ev, penaltyMultiplier: 1 - ev.value, payMultiplier: 8);

      case EventType.listrik:
        // Goes to 0 CPS until paid
        _setupPayOrPenalty(ev, penaltyMultiplier: 0.0, payMultiplier: 10);

      case EventType.gosip:
        _setupPayOrPenalty(ev, penaltyMultiplier: 1 - ev.value, payMultiplier: 3);
    }

    onEventTriggered?.call(ev);
    notifyListeners();
  }

  void _setupPayOrPenalty(GameEvent ev, {
    required double penaltyMultiplier,
    required double payMultiplier,
  }) {
    pendingNegative  = true;
    pendingType      = ev.type;
    penaltyPayAmount = max(50, coinsPerSecond * payMultiplier);

    _penaltyTimer?.cancel();
    _penaltyTimer = Timer(const Duration(seconds: 10), () {
      if (pendingNegative) _applyPenalty(penaltyMultiplier);
    });
  }

  void payPenalty() {
    if (_coins >= penaltyPayAmount) {
      _coins -= penaltyPayAmount;
      pendingNegative = false;
      pendingType     = null;
      _penaltyTimer?.cancel();
      _clearEvent();
      notifyListeners();
    }
  }

  void _applyPenalty(double mult) {
    _baseCps       = max(0, _baseCps * mult);
    pendingNegative = false;
    pendingType     = null;
    _clearEvent();
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

  void _clearEvent() {
    _cpsMult        = 1;
    _cpcMult        = 1;
    activeEvent     = null;
    pendingNegative = false;
    pendingType     = null;
    notifyListeners();
  }

  // ── TAP ────────────────────────────────────
  void tap() {
    final gained = coinsPerClick;
    _coins += gained;
    onTapCallback?.call(gained);
    HapticFeedback.lightImpact();
    notifyListeners();
  }

  // ── BUY UPGRADE ────────────────────────────
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

  // ── CHANGE LANGUAGE ────────────────────────
  void setLanguage(AppLang lang) {
    L10n.current = lang;
    notifyListeners();
  }

  // ── RESET ──────────────────────────────────
  Future<void> reset() async {
    _tickTimer?.cancel();
    _saveTimer?.cancel();
    _eventCountdown?.cancel();
    _randomEventTimer?.cancel();
    _penaltyTimer?.cancel();

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _coins   = 0;
    _baseCps = 0;
    _baseCpc = 1;
    _cpsMult = 1;
    _cpcMult = 1;
    activeEvent     = null;
    pendingNegative = false;
    eventSecondsLeft = 0;
    _reachedMilestones.clear();
    upgrades = makeUpgrades();

    _tickTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _coins += coinsPerSecond * 0.1;
      _checkMilestones();
      notifyListeners();
    });
    _saveTimer = Timer.periodic(const Duration(seconds: 5), (_) => save());
    _scheduleRandomEvent();
    notifyListeners();
  }

  // ── SAVE / LOAD ────────────────────────────
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('coins', _coins);
    await prefs.setString('upgrades', upgrades.map((u) => '${u.id}:${u.owned}').join(','));
    await prefs.setString('milestones', _reachedMilestones.join(','));
    await prefs.setString('lang', L10n.current == AppLang.en ? 'en' : 'id');
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _coins = prefs.getDouble('coins') ?? 0;

    // Load language preference
    final savedLang = prefs.getString('lang') ?? 'id';
    L10n.current = savedLang == 'en' ? AppLang.en : AppLang.id;

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
    _penaltyTimer?.cancel();
    save();
    super.dispose();
  }
}