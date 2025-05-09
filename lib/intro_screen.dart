import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Welcome',
      'description': 'Welcome to our app!  Discover amazing features.',
      'image': 'assets/images/user.png', // Replace with your image path
    },
    {
      'title': 'Explore',
      'description': 'Explore a variety of exciting content and tools.',
      'image': 'assets/images/user.png', // Replace with your image path
    },
    {
      'title': 'Get Started',
      'description': 'Ready to get started?  Let\'s go!',
      'image': 'assets/images/user.png', // Replace with your image path
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToMain(); // Navigate to main screen after the last page
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipIntro() {
    _navigateToMain(); // Navigate to main screen
  }

  void _navigateToMain() {
    context.go('/temp');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return IntroPage(
                    title: page['title'] ?? '',
                    description: page['description'] ?? '',
                    image: page['image'] ?? '',
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _previousPage,
                  child: const Text('Previous'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildPageIndicator(),
                ),
                TextButton(
                  onPressed: _nextPage,
                  child:
                  Text(_currentPage == _pages.length - 1 ? 'Finish' : 'Next'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _skipIntro,
              child: const Text('Skip'),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPageIndicator() {
    List<Widget> indicators = [];
    for (int i = 0; i < _pages.length; i++) {
      indicators.add(
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == i ? Colors.blue : Colors.grey,
          ),
        ),
      );
    }
    return indicators;
  }
}

class IntroPage extends StatelessWidget {
  final String title;
  final String description;
  final String image;

  const IntroPage(
      {super.key, required this.title, required this.description, required this.image});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            image, // Load image from assets
            height: 200, // Adjust the height as needed
          ),
          const SizedBox(height: 32),
          Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

