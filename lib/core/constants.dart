import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  static const teal   = Color(0xFF00FFD4);
  static const pink   = Color(0xFFFF6EC7);
}

// ─────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────
String fmtCoins(double v) {
  if (v >= 1e12) return '${(v / 1e12).toStringAsFixed(2)}T';
  if (v >= 1e9)  return '${(v / 1e9).toStringAsFixed(2)}B';
  if (v >= 1e6)  return '${(v / 1e6).toStringAsFixed(2)}M';
  if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
  return v.toStringAsFixed(0);
}

TextStyle px({double size = 10, Color color = RP.white}) =>
    GoogleFonts.pressStart2p(fontSize: size, color: color);