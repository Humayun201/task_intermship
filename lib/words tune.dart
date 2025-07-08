import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:task_internship/service.dart';

class WordTuneScreen extends StatefulWidget {
  final String originalText;
  final String? quickAction;

  WordTuneScreen({required this.originalText, this.quickAction});

  @override
  _WordTuneScreenState createState() => _WordTuneScreenState();
}

class _WordTuneScreenState extends State<WordTuneScreen> {
  final GeminiService _geminiService = GeminiService();
  Map<String, String> _suggestions = {};
  bool _isLoading = false;
  String _selectedTone = 'Professional';
  String? _errorMessage;

  List<ToneOption> _toneOptions = [
    ToneOption('Professional', Icons.business, Colors.blue),
    ToneOption('Casual', Icons.chat, Colors.green),
    ToneOption('Polite', Icons.favorite, Colors.pink),
    ToneOption('Creative', Icons.lightbulb, Colors.orange),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.quickAction != null) {
      _performQuickAction();
    } else {
      _generateSuggestions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Word Tune'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF0f3460),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Original Text',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.originalText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.quickAction == null) ...[
              Container(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _toneOptions.length,
                  itemBuilder: (context, index) {
                    final option = _toneOptions[index];
                    final isSelected = _selectedTone == option.name;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTone = option.name;
                          _errorMessage = null;
                        });
                        _generateSuggestions();
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 12),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? option.color : Color(0xFF0f3460),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? option.color : Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              option.icon,
                              color: isSelected ? Colors.white : Colors.white70,
                              size: 20,
                            ),
                            SizedBox(height: 4),
                            Text(
                              option.name,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            Expanded(
              child: _isLoading
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.purple),
                    SizedBox(height: 16),
                    Text(
                      'Generating AI suggestions...',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              )
                  : _errorMessage != null
                  ? Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Error',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _errorMessage = null;
                          });
                          if (widget.quickAction != null) {
                            _performQuickAction();
                          } else {
                            _generateSuggestions();
                          }
                        },
                        child: Text('Try Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  : _suggestions.isEmpty
                  ? Center(
                child: Text(
                  'No suggestions available',
                  style: TextStyle(color: Colors.white70),
                ),
              )
                  : ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final entry = _suggestions.entries.elementAt(index);
                  return _buildSuggestionCard(entry.key, entry.value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionCard(String title, String suggestion) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Color(0xFF0f3460),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_fix_high, color: Colors.purple, size: 20),
                    SizedBox(width: 8),
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.purple,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  suggestion,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: suggestion));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Copied to clipboard'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    icon: Icon(Icons.copy, color: Colors.white70, size: 18),
                    label: Text(
                      'Copy',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withOpacity(0.1),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      // Share functionality can be implemented here
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Share feature coming soon'),
                          backgroundColor: Colors.blue,
                        ),
                      );
                    },
                    icon: Icon(Icons.share, color: Colors.white70, size: 18),
                    label: Text(
                      'Share',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _generateSuggestions() async {
    setState(() {
      _isLoading = true;
      _suggestions.clear();
      _errorMessage = null;
    });

    try {
      final suggestions = await _geminiService.rewriteText(
        widget.originalText,
        _selectedTone.toLowerCase(),
      );

      setState(() {
        _suggestions = suggestions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _performQuickAction() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _geminiService.performQuickAction(
        widget.originalText,
        widget.quickAction!,
      );

      setState(() {
        _suggestions = {widget.quickAction!.toUpperCase(): result};
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }
}

class ToneOption {
  final String name;
  final IconData icon;
  final Color color;

  ToneOption(this.name, this.icon, this.color);
}
