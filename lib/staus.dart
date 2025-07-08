import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeyboardStatusChecker extends StatefulWidget {
  @override
  _KeyboardStatusCheckerState createState() => _KeyboardStatusCheckerState();
}

class _KeyboardStatusCheckerState extends State<KeyboardStatusChecker> {
  static const platform = MethodChannel('keyboard_settings');
  Map<String, dynamic>? keyboardStatus;

  @override
  void initState() {
    super.initState();
    checkKeyboardStatus();
  }

  Future<void> checkKeyboardStatus() async {
    try {
      final result = await platform.invokeMethod('checkKeyboardStatus');
      setState(() {
        keyboardStatus = Map<String, dynamic>.from(result);
      });
    } catch (e) {
      print('Error checking keyboard status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Keyboard Status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          SizedBox(height: 12),
          if (keyboardStatus != null) ...[
            _buildStatusRow(
              'Enabled in Settings',
              keyboardStatus!['enabled'] ?? false,
            ),
            _buildStatusRow(
              'Currently Selected',
              keyboardStatus!['selected'] ?? false,
            ),
          ] else ...[
            Text('Checking status...'),
          ],
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    await platform.invokeMethod('openKeyboardSettings');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: Text(
                    'Open Settings',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    await platform.invokeMethod('openInputMethodPicker');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text(
                    'Switch Keyboard',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: checkKeyboardStatus,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: Text(
              'Refresh Status',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, bool status) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            status ? Icons.check_circle : Icons.cancel,
            color: status ? Colors.green : Colors.red,
            size: 20,
          ),
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: status ? Colors.green : Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
