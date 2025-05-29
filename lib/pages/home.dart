import 'package:flutter/material.dart';
import '../widgets/navigation_button_widget.dart';
import '../widgets/welcome_card_widget.dart';
import '../widgets/heart_visualization_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF6E9), // Light purple background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 2),

              // App Title with Aura Mind
              Center(
                child: Text(
                  ' ',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo[900],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Pulsating Heart
              const Center(
                child: PulsatingHeartAnimation(),
              ),

              const SizedBox(height: 20),

              // Welcome card widget
              const WelcomeCardWidget(),

              const SizedBox(height: 24),

              // 3D Heart Visualization title
              Text(
                '3D Heart Visualization',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[900],
                ),
              ),

              const SizedBox(height: 16),

              // Heart visualization widget
              const UnityLauncherWidget(),

              const SizedBox(height: 24),

              // Navigation title

              const SizedBox(height: 16),

              // Navigation buttons
              // You can add your navigation buttons here

              // Bottom spacing
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

// Pulsating Heart Animation Widget
class PulsatingHeartAnimation extends StatefulWidget {
  const PulsatingHeartAnimation({Key? key}) : super(key: key);

  @override
  State<PulsatingHeartAnimation> createState() => _PulsatingHeartAnimationState();
}

class _PulsatingHeartAnimationState extends State<PulsatingHeartAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Icon(
            Icons.favorite,
            size: 150,
            color: Colors.indigo[800],
          ),
        );
      },
    );
  }
}