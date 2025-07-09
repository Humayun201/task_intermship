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
  int _wordsRemaining = 102;
  String _selectedKeyboardType = 'System';

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
          color: Colors.white,
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
                    'Select Keyboard Type',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildKeyboardOption(
                    'System Keyboard',
                    'Default system keyboard',
                    Icons.keyboard,
                    Colors.blue,
                    'System',
                  ),
                  _buildKeyboardOption(
                    'CleverType AI',
                    'AI-powered smart keyboard',
                    Icons.smart_toy,
                    Colors.purple,
                    'CleverType',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyboardOption(String title, String subtitle, IconData icon, Color color, String type, {bool isComingSoon = false}) {
    bool isSelected = _selectedKeyboardType == type;

    return GestureDetector(
      onTap: isComingSoon ? null : () {
        setState(() {
          _selectedKeyboardType = type;
          _useCleverKeyboard = type == 'CleverType';
          _showCustomKeyboard = false;
        });
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title selected'),
            backgroundColor: color,
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isComingSoon ? Colors.grey[400] : color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isComingSoon ? Colors.grey[500] : Colors.black87,
                        ),
                      ),
                      if (isComingSoon) ...[
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'SOON',
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
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 24),
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'CleverType',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          actions: [
            Container(
              margin: EdgeInsets.only(right: 16),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue,
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
                    // Subscription Plan Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Subscription Plan',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '$_wordsRemaining Words left',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: Icon(Icons.diamond, color: Colors.white, size: 18),
                            label: Text(
                              'Upgrade',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),

                    // Settings Menu Items
                    _buildMenuItem(Icons.settings, 'Keyboard Settings', 'Auto Correct, Suggestions, Sound & Vibrations'),
                    _buildMenuItem(Icons.psychology, 'AI Settings', 'Custom Tones, Grammar Prompts and more', badge: 'NEW'),
                    _buildMenuItem(Icons.palette, 'Keyboard Themes', 'Day Mode, Night mode, Pure Night mode'),
                    _buildMenuItem(Icons.translate, 'Keyboard Languages', '30+ Languages'),
                    _buildMenuItem(Icons.share, 'Share CleverType', 'Let your friends and family find us'),
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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: TextField(
                            controller: _textController,
                            focusNode: _textFocusNode,
                            style: TextStyle(fontSize: 16, color: Colors.black87),
                            decoration: InputDecoration(
                              hintText: 'Try $_selectedKeyboardType keyboard here!',
                              hintStyle: TextStyle(color: Colors.grey[500]),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            readOnly: _useCleverKeyboard,
                            showCursor: true,
                            cursorColor: Colors.purple,
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
                  if (_selectedKeyboardType != 'System') ...[
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.purple.withOpacity(0.3)),
                      ),
                      child: Text(
                        '$_selectedKeyboardType Active',
                        style: TextStyle(
                          color: Colors.purple,
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
            if (_showCustomKeyboard && _useCleverKeyboard)
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

  Widget _buildMenuItem(IconData icon, String title, String subtitle, {String? badge}) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
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
            child: Icon(icon, color: Colors.black87, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    if (badge != null) ...[
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badge,
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
                  subtitle,
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