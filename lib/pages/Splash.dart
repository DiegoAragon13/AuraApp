import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:drmarmotino/pages/Navigation/navigationForPages.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _titleAnimation;
  late Animation<double> _subtitleAnimation;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky, overlays: []);
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _titleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );

    _subtitleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 0.9, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 3500), () async {
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const navigationForPages(),
            transitionDuration: const Duration(milliseconds: 800),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? Colors.black : const Color(0xFFF5F5F5);
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1A2138);

    return Scaffold(
      backgroundColor: bgColor,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),

                // Texto principal: Doctor Marmotino
                FadeTransition(
                  opacity: _titleAnimation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.4),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _controller,
                        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
                      ),
                    ),
                    child: Text(
                      "Aura Mind",
                      style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        letterSpacing: 3.0,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Texto secundario opcional
                FadeTransition(
                  opacity: _subtitleAnimation,
                  child: Text(
                    "Salud cardiaca al ritmo real",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: textColor.withOpacity(0.7),
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDarkMode ? Colors.white : const Color(0xFF1A2138),
                      ),
                      strokeWidth: 2.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
