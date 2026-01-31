import 'package:flutter/material.dart';
import 'package:krishi_mitra/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'en';
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString(AppConstants.keyLanguage) ?? 'en';
      _notificationsEnabled =
          prefs.getBool(AppConstants.keyNotificationsEnabled) ?? true;
    });
  }

  Future<void> _changeLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyLanguage, languageCode);
    setState(() => _selectedLanguage = languageCode);
    // Restart app to apply language change
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please restart the app to apply language changes'),
        ),
      );
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyNotificationsEnabled, value);
    setState(() => _notificationsEnabled = value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.language),
            subtitle: Text(_selectedLanguage == 'en' ? l10n.english : l10n.marathi),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.changeLanguage),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadioListTile<String>(
                        title: Text(l10n.english),
                        value: 'en',
                        groupValue: _selectedLanguage,
                        onChanged: (value) {
                          if (value != null) {
                            _changeLanguage(value);
                            Navigator.pop(context);
                          }
                        },
                      ),
                      RadioListTile<String>(
                        title: Text(l10n.marathi),
                        value: 'mr',
                        groupValue: _selectedLanguage,
                        onChanged: (value) {
                          if (value != null) {
                            _changeLanguage(value);
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: Text(l10n.enableNotifications),
            value: _notificationsEnabled,
            onChanged: _toggleNotifications,
          ),
        ],
      ),
    );
  }
}
