import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home page.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PageController _pageController = PageController();
  int _currentPage = 0;

  // Getters for onboarding configuration
  List<OnboardingPage> get pages => [
    OnboardingPage(
      title: "AI-Powered Writing",
      description: "Transform your text with intelligent AI suggestions and corrections",
      icon: Icons.auto_fix_high,
      color: Colors.purple,
    ),
    OnboardingPage(
      title: "Multiple Tones",
      description: "Rewrite text in Professional, Casual, or Polite tones instantly",
      icon: Icons.tune,
      color: Colors.blue,
    ),
    OnboardingPage(
      title: "Smart Keyboard",
      description: "Enhanced typing experience with real-time AI assistance",
      icon: Icons.keyboard,
      color: Colors.green,
    ),
  ];

  // Getters for UI text
  String get skipButtonText => 'Skip';
  String get nextButtonText => 'Next';
  String get getStartedButtonText => 'Get Started';

  // Getters for styling
  Color get backgroundColor1 => Color(0xFF1a1a2e);
  Color get backgroundColor2 => Color(0xFF16213e);
  Color get primaryColor => Colors.purple;
  Color get textColor => Colors.white;
  Color get subtitleColor => Colors.white70;

  // Getters for current page state
  OnboardingPage get currentPage => pages[_currentPage];
  bool get isLastPage => _currentPage == pages.length - 1;
  String get buttonText => isLastPage ? getStartedButtonText : nextButtonText;

  // Getter for page indicators
  List<Widget> get pageIndicators => List.generate(
    pages.length,
        (index) => Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 20 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? primaryColor : Colors.white30,
        borderRadius: BorderRadius.circular(4),
      ),
    ),
  );

  // Method to mark onboarding as completed
  Future<void> _completeOnboarding() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('first_time', false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } catch (e) {
      // Handle error - still navigate to home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  // Method to handle next button press
  void _handleNextButton() {
    if (isLastPage) {
      _completeOnboarding();
    } else {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Method to handle page change
  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [backgroundColor1, backgroundColor2],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Padding(
                padding: EdgeInsets.only(top: 20, right: 20),
                child: Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _completeOnboarding,
                    child: Text(
                      skipButtonText,
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              // Page view
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: pages.length,
                  itemBuilder: (context, index) {
                    final page = pages[index];
                    return Padding(
                      padding: EdgeInsets.all(40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: page.color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(60),
                            ),
                            child: Icon(
                              page.icon,
                              size: 60,
                              color: page.color,
                            ),
                          ),
                          SizedBox(height: 40),
                          Text(
                            page.title,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 20),
                          Text(
                            page.description,
                            style: TextStyle(
                              fontSize: 16,
                              color: subtitleColor,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Page indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: pageIndicators,
              ),
              SizedBox(height: 40),
              // Next/Get Started button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleNextButton,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    child: Text(
                      buttonText,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
