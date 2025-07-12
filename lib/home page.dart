import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:task_internship/words%20tune.dart';
import 'aetting.dart';
import 'key board.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController _textController = TextEditingController();
  bool _showCustomKeyboard = false;
  bool _useCleverKeyboard = false;
  FocusNode _textFocusNode = FocusNode();
  String _selectedKeyboardType = 'System';

  // Getters for UI text and configuration
  String get appTitle => 'smart Ai';


  String get keyboardSelectorTitle => 'Select Keyboard Type';

  String get textFieldHint => 'Try $_selectedKeyboardType keyboard here!';

  String get keyboardActiveText => '$_selectedKeyboardType Active';

  // Getters for keyboard options
  List<KeyboardOption> get keyboardOptions => [
    KeyboardOption(
      title: 'System Keyboard',
      subtitle: 'Default system keyboard',
      icon: Icons.keyboard,
      color: Colors.blue,
      type: 'System',
    ),
    KeyboardOption(
      title: 'CleverType AI',
      subtitle: 'AI-powered smart keyboard',
      icon: Icons.smart_toy,
      color: Colors.purple,
      type: 'CleverType',
    ),
  ];

  // Getters for menu items
  List<MenuItem> get menuItems => [
    MenuItem(
      icon: Icons.settings,
      title: 'Keyboard Settings',
      subtitle: 'Auto Correct, Suggestions, Sound & Vibrations',
    ),
    MenuItem(
      icon: Icons.psychology,
      title: 'AI Settings',
      subtitle: 'Custom Tones, Grammar Prompts and more',
      badge: 'NEW',
    ),
    MenuItem(
      icon: Icons.palette,
      title: 'Keyboard Themes',
      subtitle: 'Day Mode, Night mode, Pure Night mode',
    ),
    MenuItem(
      icon: Icons.translate,
      title: 'Keyboard Languages',
      subtitle: '30+ Languages',
    ),
    MenuItem(
      icon: Icons.share,
      title: 'Share CleverType',
      subtitle: 'Let your friends and family find us',
    ),
  ];

  // Getters for styling
  Color get primaryColor => Colors.purple;
  Color get secondaryColor => Colors.blue;
  Color get backgroundColor => Colors.white;
  Color get cardBackgroundColor => Colors.grey[50]!;
  Color get borderColor => Colors.grey[200]!;

  // Getter for checking if custom keyboard should be shown
  bool get shouldShowCustomKeyboard => _showCustomKeyboard && _useCleverKeyboard;

  // Getter for checking if keyboard type indicator should be shown
  bool get shouldShowKeyboardIndicator => _selectedKeyboardType != 'System';

  @override
  void initState() {
    super.initState();
    _textFocusNode.addListener(() {
      if (_textFocusNode.hasFocus && _useCleverKeyboard) {
        _showCleverKeyboard();
      }
    });
  }

  @override
  void dispose() {
    _textFocusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (_showCustomKeyboard) {
      setState(() {
        _showCustomKeyboard = false;
      });
      _textFocusNode.unfocus();
      return false;
    }
    return true;
  }

  void _showCleverKeyboard() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        _showCustomKeyboard = true;
      });
    });
  }

  void _showKeyboardSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    keyboardSelectorTitle,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 20),
                  ...keyboardOptions.map((option) => _buildKeyboardOption(option)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyboardOption(KeyboardOption option) {
    bool isSelected = _selectedKeyboardType == option.type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedKeyboardType = option.type;
          _useCleverKeyboard = option.type == 'CleverType';
          _showCustomKeyboard = false;
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${option.title} selected'),
            backgroundColor: option.color,
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? option.color.withOpacity(0.1) : cardBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? option.color : borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: option.color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(option.icon, color: Colors.white, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    option.subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: option.color, size: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          title: Text(
            appTitle,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          actions: [
            Container(
              margin: EdgeInsets.only(right: 16),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: secondaryColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.settings, color: Colors.white, size: 24),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsScreen()),
                  );
                },
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 30),
                    // Settings Menu Items
                    ...menuItems.map((item) => _buildMenuItem(item)),
                  ],
                ),
              ),
            ),
            // Keyboard Test Area
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: TextField(
                            controller: _textController,
                            focusNode: _textFocusNode,
                            style: TextStyle(fontSize: 16, color: Colors.black87),
                            decoration: InputDecoration(
                              hintText: textFieldHint,
                              hintStyle: TextStyle(color: Colors.grey[500]),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            readOnly: _useCleverKeyboard,
                            showCursor: true,
                            cursorColor: primaryColor,
                            onTap: () {
                              if (_useCleverKeyboard) {
                                _showCleverKeyboard();
                              }
                            },
                            onChanged: (text) => setState(() {}),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      // Keyboard Selector Button
                      GestureDetector(
                        onTap: _showKeyboardSelector,
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[600],
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey[600]!.withOpacity(0.3),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(Icons.keyboard, color: Colors.white, size: 24),
                        ),
                      ),
                    ],
                  ),
                  if (shouldShowKeyboardIndicator) ...[
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: primaryColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        keyboardActiveText,
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Custom Keyboard
            if (shouldShowCustomKeyboard)
              CustomKeyboard(
                textController: _textController,
                onAIAction: (action, text) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WordTuneScreen(
                        originalText: text,
                        quickAction: action,
                      ),
                    ),
                  );
                },
                onClose: () {
                  setState(() {
                    _showCustomKeyboard = false;
                  });
                  _textFocusNode.unfocus();
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(MenuItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: Colors.black87, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    if (item.badge != null) ...[
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.badge!,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
        ],
      ),
    );
  }
}

// Data classes for better organization
class KeyboardOption {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String type;

  KeyboardOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.type,
  });
}

class MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? badge;

  MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.badge,
  });
}
