import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoCorrect = true;
  bool _suggestions = true;
  bool _hapticFeedback = false;
  String _defaultTone = 'Professional';

  // Keyboard status variables
  bool _keyboardEnabled = false;
  bool _keyboardSelected = false;
  bool _isCheckingStatus = false;

  static const platform = MethodChannel('keyboard_settings');

  @override
  void initState() {
    super.initState();
    _checkKeyboardStatus();
  }

  // Check keyboard status using your existing method
  Future<void> _checkKeyboardStatus() async {
    if (!Platform.isAndroid) return;

    setState(() {
      _isCheckingStatus = true;
    });

    try {
      final result = await platform.invokeMethod('checkKeyboardStatus');
      setState(() {
        _keyboardEnabled = result['enabled'] ?? false;
        _keyboardSelected = result['selected'] ?? false;
        _isCheckingStatus = false;
      });
    } catch (e) {
      print('Error checking keyboard status: $e');
      setState(() {
        _isCheckingStatus = false;
      });
    }
  }

  // Open keyboard settings using your existing method
  Future<void> _openKeyboardSettings() async {
    if (!Platform.isAndroid) {
      _showKeyboardSettingsDialog();
      return;
    }

    try {
      await platform.invokeMethod('openKeyboardSettings');
      // Refresh status after opening settings
      Future.delayed(Duration(seconds: 2), () {
        _checkKeyboardStatus();
      });
    } catch (e) {
      print('Error opening keyboard settings: $e');
      _showErrorDialog('Could not open keyboard settings');
    }
  }

  void _showKeyboardSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF0f3460),
          title: Text(
            'Keyboard Settings',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            Platform.isAndroid
                ? 'Go to Settings > System > Languages & input > Virtual keyboard to change your keyboard.'
                : 'Go to Settings > General > Keyboard to change your keyboard settings.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: TextStyle(color: Colors.purple),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF0f3460),
          title: Text(
            'Error',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            message,
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: TextStyle(color: Colors.purple),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Color(0xFF1a1a2e),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            _buildSectionHeader('AI Features'),
            _buildSettingsTile(
              'Auto-correct',
              'Automatically correct spelling mistakes',
              Icons.spellcheck,
              Switch(
                value: _autoCorrect,
                onChanged: (value) {
                  setState(() {
                    _autoCorrect = value;
                  });
                },
                activeColor: Colors.purple,
              ),
            ),
            _buildSettingsTile(
              'Smart Suggestions',
              'Show AI-powered text suggestions',
              Icons.lightbulb_outline,
              Switch(
                value: _suggestions,
                onChanged: (value) {
                  setState(() {
                    _suggestions = value;
                  });
                },
                activeColor: Colors.purple,
              ),
            ),
            SizedBox(height: 20),
            _buildSectionHeader('Keyboard & Input'),
            _buildSettingsTile(
              'Enable Keyboard',
              'Add CleverType to your keyboards',
              Icons.keyboard_alt,
              Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
              onTap: _openKeyboardSettings,
            ),
            SizedBox(height: 20),
            _buildSectionHeader('Preferences'),
            _buildSettingsTile(
              'Default Tone',
              'Choose your preferred writing tone',
              Icons.tune,
              DropdownButton<String>(
                value: _defaultTone,
                dropdownColor: Color(0xFF0f3460),
                style: TextStyle(color: Colors.white),
                items: ['Professional', 'Casual', 'Polite', 'Creative']
                    .map((tone) => DropdownMenuItem(
                  value: tone,
                  child: Text(tone),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _defaultTone = value!;
                  });
                },
              ),
            ),
            _buildSettingsTile(
              'Haptic Feedback',
              'Vibrate on key press',
              Icons.vibration,
              Switch(
                value: _hapticFeedback,
                onChanged: (value) {
                  setState(() {
                    _hapticFeedback = value;
                  });
                },
                activeColor: Colors.purple,
              ),
            ),
            SizedBox(height: 20),
            _buildSectionHeader('About'),
            _buildSettingsTile(
              'Version',
              '1.0.0',
              Icons.info_outline,
              null,
            ),
            _buildSettingsTile(
              'Privacy Policy',
              'View our privacy policy',
              Icons.privacy_tip_outlined,
              Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
              onTap: () {
                // Open privacy policy
              },
            ),
            _buildSettingsTile(
              'Terms of Service',
              'View terms and conditions',
              Icons.description_outlined,
              Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
              onTap: () {
                // Open terms of service
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.purple,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
      String title,
      String subtitle,
      IconData icon,
      Widget? trailing, {
        VoidCallback? onTap,
      }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Color(0xFF0f3460),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white70),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.white54),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}