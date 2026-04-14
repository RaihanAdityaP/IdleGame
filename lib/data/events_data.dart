import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/localization.dart';

// ─────────────────────────────────────────────
//  EVENT MODEL
// ─────────────────────────────────────────────
enum EventType {
  airdrop,    // instant coin bonus
  rushHour,   // cps multiplier duration
  vip,        // cpc multiplier duration
  bencana,    // pay or cps penalty
  promo,      // cps 3x short duration
  artis,      // instant big bonus
  hujan,      // pay or cps -50%
  listrik,    // pay or cps goes 0 briefly
  festival,   // cpc 10x duration
  supplier,   // cps 1.5x, free
  gosip,      // pay or cps -20%
  gajian,     // cps 3x duration
}

class GameEvent {
  final EventType type;
  final Color color;
  final IconData icon;
  final int durationSec;
  final double value;

  // Resolved from L10n at runtime
  String get title => L10n.get(_titleKey);
  String get desc  => L10n.get(_descKey);

  final String _titleKey;
  final String _descKey;

  const GameEvent({
    required this.type,
    required String titleKey,
    required String descKey,
    required this.color,
    required this.icon,
    required this.durationSec,
    required this.value,
  })  : _titleKey = titleKey,
        _descKey  = descKey;
}

// ─────────────────────────────────────────────
//  EVENT DEFINITIONS
// ─────────────────────────────────────────────
const allEvents = [
  // ── POSITIVE ───────────────────────────────
  GameEvent(
    type: EventType.airdrop,
    titleKey: 'ev_airdrop_title', descKey: 'ev_airdrop_desc',
    color: RP.yellow, icon: Icons.card_giftcard,
    durationSec: 0, value: 500,
  ),
  GameEvent(
    type: EventType.rushHour,
    titleKey: 'ev_rush_title', descKey: 'ev_rush_desc',
    color: RP.green, icon: Icons.bolt,
    durationSec: 15, value: 2,
  ),
  GameEvent(
    type: EventType.vip,
    titleKey: 'ev_vip_title', descKey: 'ev_vip_desc',
    color: RP.blue, icon: Icons.star,
    durationSec: 20, value: 5,
  ),
  GameEvent(
    type: EventType.promo,
    titleKey: 'ev_promo_title', descKey: 'ev_promo_desc',
    color: RP.pink, icon: Icons.campaign,
    durationSec: 10, value: 3,
  ),
  GameEvent(
    type: EventType.artis,
    titleKey: 'ev_artis_title', descKey: 'ev_artis_desc',
    color: RP.purple, icon: Icons.emoji_events,
    durationSec: 0, value: 2000,
  ),
  GameEvent(
    type: EventType.festival,
    titleKey: 'ev_festival_title', descKey: 'ev_festival_desc',
    color: RP.teal, icon: Icons.celebration,
    durationSec: 30, value: 10,
  ),
  GameEvent(
    type: EventType.supplier,
    titleKey: 'ev_supplier_title', descKey: 'ev_supplier_desc',
    color: RP.green, icon: Icons.local_shipping,
    durationSec: 20, value: 1.5,
  ),
  GameEvent(
    type: EventType.gajian,
    titleKey: 'ev_gajian_title', descKey: 'ev_gajian_desc',
    color: RP.yellow, icon: Icons.payments,
    durationSec: 25, value: 3,
  ),

  // ── NEGATIVE ───────────────────────────────
  GameEvent(
    type: EventType.bencana,
    titleKey: 'ev_bencana_title', descKey: 'ev_bencana_desc',
    color: RP.red, icon: Icons.warning_amber,
    durationSec: 0, value: 0.3,
  ),
  GameEvent(
    type: EventType.hujan,
    titleKey: 'ev_hujan_title', descKey: 'ev_hujan_desc',
    color: RP.blue, icon: Icons.water_drop,
    durationSec: 0, value: 0.5,
  ),
  GameEvent(
    type: EventType.listrik,
    titleKey: 'ev_listrik_title', descKey: 'ev_listrik_desc',
    color: RP.grey, icon: Icons.power_off,
    durationSec: 0, value: 0.0,
  ),
  GameEvent(
    type: EventType.gosip,
    titleKey: 'ev_gosip_title', descKey: 'ev_gosip_desc',
    color: RP.orange, icon: Icons.forum,
    durationSec: 0, value: 0.2,
  ),
];

List<GameEvent> get positiveEvents =>
    allEvents.where((e) => ![
      EventType.bencana,
      EventType.hujan,
      EventType.listrik,
      EventType.gosip,
    ].contains(e.type)).toList();