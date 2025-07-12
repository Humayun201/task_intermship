import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomKeyboard extends StatefulWidget {
  final TextEditingController textController;
  final Function(String, String) onAIAction; // action, text
  final VoidCallback onClose;

  CustomKeyboard({
    required this.textController,
    required this.onAIAction,
    required this.onClose,
  });

  @override
  _CustomKeyboardState createState() => _CustomKeyboardState();
}

class _CustomKeyboardState extends State<CustomKeyboard> {
  bool _isShiftPressed = false;
  bool _isNumberMode = false;

  List<List<String>> _keyboardLayout = [
    ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
    ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'],
    ['shift', 'z', 'x', 'c', 'v', 'b', 'n', 'm', 'backspace'],
    ['123', 'space', 'enter']
  ];

  List<List<String>> _numbersLayout = [
    ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
    ['-', '/', ':', ';', '(', ')', '\$', '&', '@', '"'],
    ['#+=', '.', ',', '?', '!', "'", 'backspace'],
    ['ABC', 'space', 'enter']
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildKeyboardHeader(),

          Divider(color: Colors.grey[800], height: 1),

          _buildIconOnlyAIActionsRow(),

          Divider(color: Colors.grey[800], height: 1),


          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                children: _buildKeyboardRows(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyboardHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple, Colors.blue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.auto_fix_high, color: Colors.white, size: 16),
              ),
              SizedBox(width: 8),
              Text(
                'CleverType AI Keyboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              // Settings icon
              IconButton(
                icon: Icon(Icons.settings, color: Colors.white70, size: 20),
                onPressed: () {
                  // Settings functionality
                },
              ),
              // Close keyboard icon
              IconButton(
                icon: Icon(Icons.keyboard_hide, color: Colors.white),
                onPressed: widget.onClose,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconOnlyAIActionsRow() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Grammar Check
          Expanded(
            child: _buildIconOnlyAIButton(
              Icons.spellcheck,
              Colors.blue,
                  () => _handleAIAction('grammar'),
            ),
          ),
          SizedBox(width: 8),
          // Summarize
          Expanded(
            child: _buildIconOnlyAIButton(
              Icons.summarize,
              Colors.green,
                  () => _handleAIAction('summarize'),
            ),
          ),
          SizedBox(width: 8),
          // Expand
          Expanded(
            child: _buildIconOnlyAIButton(
              Icons.expand_more,
              Colors.orange,
                  () => _handleAIAction('expand'),
            ),
          ),
          SizedBox(width: 8),
          // Translate
          Expanded(
            child: _buildIconOnlyAIButton(
              Icons.translate,
              Colors.red,
                  () => _handleAIAction('translate'),
            ),
          ),
          SizedBox(width: 8),
          // Gemini AI (wider button)
          Expanded(
            flex: 2,
            child: _buildGeminiIconButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildIconOnlyAIButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.9),
              color.withOpacity(0.7),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildGeminiIconButton() {
    return GestureDetector(
      onTap: () => _handleAIAction('gemini'),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF4285F4), // Google Blue
              Color(0xFF34A853), // Google Green
              Color(0xFFFBBC05), // Google Yellow
              Color(0xFFEA4335), // Google Red
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.auto_awesome,
                color: Color(0xFF4285F4),
                size: 14,
              ),
            ),
            SizedBox(width: 6),
            Text(
              'Ai',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildKeyboardRows() {
    List<List<String>> currentLayout = _isNumberMode ? _numbersLayout : _keyboardLayout;

    return currentLayout.map((row) {
      return Expanded(
        child: Row(
          children: row.map((key) {
            return Expanded(
              flex: _getKeyFlex(key),
              child: Padding(
                padding: EdgeInsets.all(2),
                child: _buildKey(key),
              ),
            );
          }).toList(),
        ),
      );
    }).toList();
  }

  int _getKeyFlex(String key) {
    if (key == 'space') return 4;
    if (key == 'shift' || key == 'backspace') return 2;
    return 1;
  }

  Widget _buildKey(String key) {
    Color keyColor = Colors.grey[800]!;
    Color textColor = Colors.white;
    IconData? icon;
    String displayText = key;

    // Special key styling
    switch (key) {
      case 'shift':
        keyColor = _isShiftPressed ? Colors.purple : Colors.grey[700]!;
        icon = Icons.keyboard_arrow_up;
        displayText = '';
        break;
      case 'backspace':
        keyColor = Colors.grey[700]!;
        icon = Icons.backspace_outlined;
        displayText = '';
        break;
      case 'space':
        keyColor = Colors.grey[700]!;
        displayText = 'space';
        break;
      case 'enter':
        keyColor = Colors.purple;
        icon = Icons.keyboard_return;
        displayText = '';
        break;
      case '123':
      case 'ABC':
      case '#+=':
        keyColor = Colors.grey[700]!;
        break;
      default:
        if (_isShiftPressed && key.length == 1) {
          displayText = key.toUpperCase();
        }
        break;
    }

    return GestureDetector(
      onTap: () => _handleKeyPress(key),
      child: Container(
        decoration: BoxDecoration(
          color: keyColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[600]!, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: icon != null
              ? Icon(icon, color: textColor, size: 20)
              : Text(
            displayText,
            style: TextStyle(
              color: textColor,
              fontSize: key == 'space' ? 12 : 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  void _handleKeyPress(String key) {
    HapticFeedback.lightImpact();

    switch (key) {
      case 'shift':
        setState(() {
          _isShiftPressed = !_isShiftPressed;
        });
        break;
      case 'backspace':
        _deleteCharacter();
        break;
      case 'space':
        _insertText(' ');
        break;
      case 'enter':
        _insertText('\n');
        break;
      case '123':
        setState(() {
          _isNumberMode = true;
        });
        break;
      case 'ABC':
        setState(() {
          _isNumberMode = false;
        });
        break;
      case '#+=':
        break;
      default:
        String textToInsert = _isShiftPressed && key.length == 1 ? key.toUpperCase() : key;
        _insertText(textToInsert);
        if (_isShiftPressed && key.length == 1) {
          setState(() {
            _isShiftPressed = false;
          });
        }
        break;
    }
  }

  void _insertText(String text) {
    final currentText = widget.textController.text;
    final selection = widget.textController.selection;

    final newText = currentText.replaceRange(
      selection.start,
      selection.end,
      text,
    );

    widget.textController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.start + text.length,
      ),
    );
  }

  void _deleteCharacter() {
    final currentText = widget.textController.text;
    final selection = widget.textController.selection;

    if (selection.start > 0) {
      final newText = currentText.replaceRange(
        selection.start - 1,
        selection.start,
        '',
      );

      widget.textController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: selection.start - 1,
        ),
      );
    }
  }

  void _handleAIAction(String action) {
    final text = widget.textController.text;
    if (text.isNotEmpty) {
      widget.onAIAction(action, text);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please type some text first to use AI features'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
