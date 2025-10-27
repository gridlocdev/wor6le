import 'package:flutter/material.dart';

class SettingsDialog extends StatefulWidget {
  final bool colorBlindMode;
  final bool darkMode;
  final Function(bool) onColorBlindModeChanged;
  final Function(bool) onDarkModeChanged;

  const SettingsDialog({
    super.key,
    required this.colorBlindMode,
    required this.darkMode,
    required this.onColorBlindModeChanged,
    required this.onDarkModeChanged,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late bool _colorBlindMode;
  late bool _darkMode;

  @override
  void initState() {
    super.initState();
    _colorBlindMode = widget.colorBlindMode;
    _darkMode = widget.darkMode;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'SETTINGS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Color Blind Mode'),
              subtitle: const Text('High contrast colors'),
              value: _colorBlindMode,
              onChanged: (value) {
                setState(() {
                  _colorBlindMode = value;
                });
                widget.onColorBlindModeChanged(value);
              },
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Dark theme'),
              value: _darkMode,
              onChanged: (value) {
                setState(() {
                  _darkMode = value;
                });
                widget.onDarkModeChanged(value);
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'WOR6LE v1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
