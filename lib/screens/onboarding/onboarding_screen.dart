import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/onboarding_service.dart';

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  const _OnboardingPage({required this.icon, required this.title, required this.description});
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      icon: Icons.receipt_long,
      title: 'Invoice Management',
      description: 'Create invoices, track payments and manage customers with ease.',
    ),
    _OnboardingPage(
      icon: Icons.insights,
      title: 'AI Insights',
      description: 'Forecast cash flow and understand payment risks using AI.',
    ),
    _OnboardingPage(
      icon: Icons.mic,
      title: 'Voice Commands',
      description: 'Navigate the app and add tasks hands-free.',
    ),
  ];

  Future<void> _finish() async {
    await OnboardingService.setComplete();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) {
                  final page = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(page.icon, size: 120, color: AppTheme.primaryColor),
                        const SizedBox(height: 32),
                        Text(page.title, style: AppTheme.headerStyle.copyWith(fontSize: 24)),
                        const SizedBox(height: 16),
                        Text(
                          page.description,
                          style: AppTheme.bodyStyle,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == _index ? AppTheme.accentColor : AppTheme.borderColor,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_index == _pages.length - 1) {
                      _finish();
                    } else {
                      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                    }
                  },
                  child: Text(_index == _pages.length - 1 ? 'Get Started' : 'Next'),
                ),
              ),
            ),
            TextButton(
              onPressed: _finish,
              child: Text('Skip', style: AppTheme.bodyStyle.copyWith(color: AppTheme.accentColor)),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
