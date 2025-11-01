import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../models/theme_mode.dart';

class SettingsDialog extends StatefulWidget {
  final bool colorBlindMode;
  final bool darkMode;
  final AppThemeMode themeMode;
  final Function(bool) onColorBlindModeChanged;
  final Function(AppThemeMode) onThemeModeChanged;

  const SettingsDialog({
    super.key,
    required this.colorBlindMode,
    required this.darkMode,
    required this.themeMode,
    required this.onColorBlindModeChanged,
    required this.onThemeModeChanged,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late bool _colorBlindMode;
  late bool _darkMode;
  late AppThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _colorBlindMode = widget.colorBlindMode;
    _darkMode = widget.darkMode;
    _themeMode = widget.themeMode;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.getBackgroundColor(_darkMode),
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
                Text(
                  'SETTINGS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextColorForBackground(_darkMode),
                  ),
                ),
                Tooltip(
                  message: 'Close',
                  child: IconButton(
                    icon: Icon(
                      Icons.close,
                      color: AppColors.getTextColorForBackground(_darkMode),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Theme',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.getTextColorForBackground(_darkMode),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _ThemeButton(
                          label: 'System',
                          isSelected: _themeMode == AppThemeMode.system,
                          darkMode: _darkMode,
                          colorBlindMode: _colorBlindMode,
                          onTap: () {
                            setState(() {
                              _themeMode = AppThemeMode.system;
                            });
                            widget.onThemeModeChanged(AppThemeMode.system);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ThemeButton(
                          label: 'Light',
                          isSelected: _themeMode == AppThemeMode.light,
                          darkMode: _darkMode,
                          colorBlindMode: _colorBlindMode,
                          onTap: () {
                            setState(() {
                              _themeMode = AppThemeMode.light;
                            });
                            widget.onThemeModeChanged(AppThemeMode.light);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ThemeButton(
                          label: 'Dark',
                          isSelected: _themeMode == AppThemeMode.dark,
                          darkMode: _darkMode,
                          colorBlindMode: _colorBlindMode,
                          onTap: () {
                            setState(() {
                              _themeMode = AppThemeMode.dark;
                            });
                            widget.onThemeModeChanged(AppThemeMode.dark);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SwitchListTile(
              title: Text(
                'Color Blind Mode',
                style: TextStyle(
                  color: AppColors.getTextColorForBackground(_darkMode),
                ),
              ),
              subtitle: Text(
                'High contrast colors',
                style: TextStyle(
                  color: _darkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              value: _colorBlindMode,
              activeTrackColor: _colorBlindMode
                  ? const Color(0xFFF5793A).withValues(
                      alpha: 0.5,
                    ) // Orange for colorblind mode
                  : null, // Default green
              activeThumbColor: _colorBlindMode
                  ? const Color(0xFFF5793A) // Orange for colorblind mode
                  : null, // Default green
              onChanged: (value) {
                setState(() {
                  _colorBlindMode = value;
                });
                widget.onColorBlindModeChanged(value);
              },
            ),
            const SizedBox(height: 20),
            Text(
              'WOR6LE v1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: _darkMode ? Colors.grey[500] : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool darkMode;
  final bool colorBlindMode;
  final VoidCallback onTap;

  const _ThemeButton({
    required this.label,
    required this.isSelected,
    required this.darkMode,
    required this.colorBlindMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Use orange for colorblind mode, green otherwise
    final activeColor = colorBlindMode
        ? const Color(0xFFF5793A) // Orange
        : Colors.green;

    final backgroundColor = isSelected
        ? (darkMode
              ? (colorBlindMode
                    ? const Color(0xFFD16530)
                    : Colors.green.shade700)
              : (colorBlindMode
                    ? const Color(0xFFF5793A)
                    : Colors.green.shade600))
        : (darkMode ? Colors.grey.shade800 : Colors.grey.shade300);

    final textColor = isSelected
        ? Colors.white
        : AppColors.getTextColorForBackground(darkMode);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: activeColor, width: 2) : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
