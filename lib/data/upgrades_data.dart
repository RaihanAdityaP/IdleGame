import 'package:flutter/material.dart';
import '../core/localization.dart';

// ─────────────────────────────────────────────
//  UPGRADE MODEL
// ─────────────────────────────────────────────
import 'dart:math';

class Upgrade {
  final String id;
  final String nameKey;
  final double baseCost;
  final double cps;
  final double cpc;
  final IconData icon;
  final bool isTap;
  int owned;

  Upgrade({
    required this.id,
    required this.nameKey,
    required this.baseCost,
    required this.cps,
    required this.cpc,
    required this.icon,
    required this.isTap,
    required this.owned,
  });

  String get name => L10n.get(nameKey);

  // Nerfed price scaling: 1.12 instead of 1.15
  double get currentCost => baseCost * pow(1.12, owned);
}

// ─────────────────────────────────────────────
//  UPGRADE DEFINITIONS
// Buffed: CPS/CPC ~2-3x higher, base prices nerfed ~20-30%
// ─────────────────────────────────────────────
List<Upgrade> makeUpgrades() => [
  // ── IDLE / AUTO ────────────────────────────
  Upgrade(
    id: 'cup',      nameKey: 'up_cup',
    baseCost: 8,    cps: 1.2,   cpc: 0,
    icon: Icons.local_drink,    isTap: false, owned: 0,
  ),
  Upgrade(
    id: 'gerobak',  nameKey: 'up_gerobak',
    baseCost: 75,   cps: 7,     cpc: 0,
    icon: Icons.shopping_cart,  isTap: false, owned: 0,
  ),
  Upgrade(
    id: 'menu',     nameKey: 'up_menu',
    baseCost: 350,  cps: 25,    cpc: 0,
    icon: Icons.restaurant_menu, isTap: false, owned: 0,
  ),
  Upgrade(
    id: 'karyawan', nameKey: 'up_karyawan',
    baseCost: 1500, cps: 80,    cpc: 0,
    icon: Icons.person,         isTap: false, owned: 0,
  ),
  Upgrade(
    id: 'dapur',    nameKey: 'up_dapur',
    baseCost: 7000, cps: 280,   cpc: 0,
    icon: Icons.outdoor_grill,  isTap: false, owned: 0,
  ),
  Upgrade(
    id: 'franchise', nameKey: 'up_franchise',
    baseCost: 30000, cps: 1000, cpc: 0,
    icon: Icons.store,          isTap: false, owned: 0,
  ),

  // ── TAP ────────────────────────────────────
  Upgrade(
    id: 'spatula',  nameKey: 'up_spatula',
    baseCost: 40,   cps: 0,     cpc: 8,
    icon: Icons.soup_kitchen,   isTap: true,  owned: 0,
  ),
  Upgrade(
    id: 'tangan',   nameKey: 'up_tangan',
    baseCost: 220,  cps: 0,     cpc: 35,
    icon: Icons.back_hand,      isTap: true,  owned: 0,
  ),
  Upgrade(
    id: 'resep',    nameKey: 'up_resep',
    baseCost: 1200, cps: 0,     cpc: 120,
    icon: Icons.auto_stories,   isTap: true,  owned: 0,
  ),
  Upgrade(
    id: 'blender',  nameKey: 'up_blender',
    baseCost: 6000, cps: 0,     cpc: 400,
    icon: Icons.blender,        isTap: true,  owned: 0,
  ),
];