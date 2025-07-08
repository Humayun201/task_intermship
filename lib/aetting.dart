import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoCorrect = true;
  bool _suggestions = true;
  bool _hapticFeedback = false;
  String _defaultTone = 'Professional';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
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
