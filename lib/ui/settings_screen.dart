import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/game_state.dart';
import '../core/localization.dart';

class SettingsScreen extends StatefulWidget {
  final GameState gameState;
  const SettingsScreen({super.key, required this.gameState});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AppLang _selected;

  @override
  void initState() {
    super.initState();
    _selected = L10n.current;
  }

  void _save() {
    widget.gameState.setLanguage(_selected);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RP.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: RP.panel,
                border: Border(bottom: BorderSide(color: RP.blue, width: 2)),
              ),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.arrow_back_ios, color: RP.blue, size: 16),
                ),
                const SizedBox(width: 12),
                Text(L10n.get('settings'), style: px(size: 11, color: RP.blue)),
              ]),
            ),

            const SizedBox(height: 24),

            // Language section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(L10n.get('language'), style: px(size: 9, color: RP.white)),
                  const SizedBox(height: 16),

                  _LangOption(
                    lang: AppLang.id,
                    label: L10n.get('bahasa_id'),
                    flag: '🇮🇩',
                    selected: _selected,
                    onTap: () => setState(() => _selected = AppLang.id),
                  ),
                  const SizedBox(height: 10),
                  _LangOption(
                    lang: AppLang.en,
                    label: L10n.get('bahasa_en'),
                    flag: '🇬🇧',
                    selected: _selected,
                    onTap: () => setState(() => _selected = AppLang.en),
                  ),

                  const SizedBox(height: 32),

                  // Save button
                  GestureDetector(
                    onTap: _save,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: RP.blue.withValues(alpha: 0.15),
                        border: Border.all(color: RP.blue, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: Text(L10n.get('save'), style: px(size: 10, color: RP.blue)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LangOption extends StatelessWidget {
  final AppLang lang;
  final String label;
  final String flag;
  final AppLang selected;
  final VoidCallback onTap;
  const _LangOption({
    required this.lang,
    required this.label,
    required this.flag,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = lang == selected;
    final color = isSelected ? RP.blue : RP.grey;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? RP.blue.withValues(alpha: 0.1) : RP.card,
          border: Border.all(color: color, width: isSelected ? 2 : 1),
        ),
        child: Row(children: [
          Text(flag, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 16),
          Text(label, style: px(size: 9, color: isSelected ? RP.white : RP.grey)),
          const Spacer(),
          if (isSelected)
            Icon(Icons.check, color: RP.blue, size: 16),
        ]),
      ),
    );
  }
}