import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': "Découvrez les Événements",
      'subtitle': "Explorez les concerts, théâtres, expositions et festivals culturels d'Alger.",
      'image': 'assets/images/festival.png',
      'icon': Icons.event,
      'color': AppTheme.primaryColor,
    },
    {
      'title': "Réservez Facilement",
      'subtitle': "Réservez vos places en quelques clics et recevez votre confirmation immédiatement.",
      'image': 'assets/images/concert.png',
      'icon': Icons.confirmation_number,
      'color': AppTheme.accentColor,
    },
    {
      'title': "Explorez la Carte",
      'subtitle': "Trouvez les événements près de vous grâce à la carte interactive d'Alger.",
      'image': 'assets/images/expo.png',
      'icon': Icons.map,
      'color': AppTheme.goldColor,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _goToLogin,
                child: const Text(
                  'Passer',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return _buildPage(page);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _pages.length,
                    effect: ExpandingDotsEffect(
                      dotColor: Colors.grey.shade300,
                      activeDotColor: AppTheme.primaryColor,
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _currentPage < _pages.length - 1
                          ? () => _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              )
                          : _goToLogin,
                      child: Text(
                        _currentPage < _pages.length - 1 ? 'Suivant' : 'Commencer',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(Map<String, dynamic> page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 280,
            width: double.infinity,
            decoration: BoxDecoration(
              color: (page['color'] as Color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                page['image'] as String,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Icon(
                  page['icon'] as IconData,
                  size: 100,
                  color: page['color'] as Color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            page['title'] as String,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: page['color'] as Color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page['subtitle'] as String,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
