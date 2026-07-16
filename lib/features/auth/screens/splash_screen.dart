import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 3800), widget.onComplete);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF001A11), // Deep dark green background
      body: SizedBox.expand(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. Moving Gradient Orbs in Background
            Positioned.fill(
              child: Stack(
                children: [
                  Positioned(
                    top: size.height * 0.1,
                    left: -50,
                    child: Container(
                      width: 400,
                      height: 400,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF00C98B).withOpacity(0.35),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF00C98B).withOpacity(0.3), blurRadius: 100, spreadRadius: 50)
                        ]
                      ),
                    ).animate(onPlay: (c) => c.repeat(reverse: true))
                     .moveX(begin: 0, end: size.width * 0.5, duration: 4.seconds, curve: Curves.easeInOutSine)
                     .moveY(begin: 0, end: 100, duration: 5.seconds, curve: Curves.easeInOutSine),
                  ),
                  Positioned(
                    bottom: size.height * 0.1,
                    right: -50,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF0EA5E9).withOpacity(0.25),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF0EA5E9).withOpacity(0.2), blurRadius: 100, spreadRadius: 50)
                        ]
                      ),
                    ).animate(onPlay: (c) => c.repeat(reverse: true))
                     .moveX(begin: 0, end: -size.width * 0.4, duration: 3.5.seconds, curve: Curves.easeInOutSine)
                     .moveY(begin: 0, end: -100, duration: 4.5.seconds, curve: Curves.easeInOutSine),
                  ),
                ],
              ),
            ),
            
            // 2. Glassmorphic Blur to blend the orbs
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.transparent),
              ),
            ),

            // 3. Tiled Parallax Background
            Positioned.fill(
              child: _TiledIcons(size: size)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(begin: -30, end: 30, duration: 6.seconds, curve: Curves.easeInOut)
                .moveX(begin: -20, end: 20, duration: 5.seconds, curve: Curves.easeInOut),
            ),

            // 4. Expanding Neon Rings
            for (int i = 0; i < 4; i++)
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF00C98B).withOpacity(0.8), width: 3),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF00C98B).withOpacity(0.5), blurRadius: 30, spreadRadius: 10),
                  ],
                ),
              ).animate(onPlay: (c) => c.repeat())
               .scaleXY(begin: 0.1, end: 8.0, duration: 2.5.seconds, delay: (i * 600).ms)
               .fadeOut(duration: 2.5.seconds, delay: (i * 600).ms, curve: Curves.easeOut),

            // 5. Epic Center Content
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 3D Spinning Logo Reveal
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF00C98B).withOpacity(0.6), blurRadius: 80, spreadRadius: 20),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 120,
                    height: 120,
                  ),
                )
                .animate()
                .scaleXY(begin: 0.0, end: 1.0, duration: 1000.ms, curve: Curves.elasticOut)
                .rotate(begin: -2.0, end: 0.0, duration: 1200.ms, curve: Curves.easeOutBack)
                .then()
                .shimmer(duration: 1500.ms, color: Colors.white, delay: 200.ms)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(begin: -10, end: 10, duration: 2.seconds, curve: Curves.easeInOutSine),

                // Welcome to text
                Text(
                  'Welcome to',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.8),
                    letterSpacing: 2,
                  ),
                )
                .animate()
                .fadeIn(duration: 800.ms, delay: 300.ms)
                .slideY(begin: 0.5, end: 0.0, duration: 800.ms, curve: Curves.easeOutBack),

                const SizedBox(height: 8),

                // Insane Glowing Text
                Text(
                  'ManavSeva',
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -2,
                  ),
                )
                .animate()
                .fadeIn(duration: 800.ms, delay: 500.ms)
                .slideY(begin: 0.8, end: 0.0, duration: 1000.ms, curve: Curves.easeOutBack)
                .shimmer(duration: 2.seconds, delay: 1000.ms, color: Colors.white),

                const SizedBox(height: 24),
                
                // Pulsing Subtitle
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C98B).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: const Color(0xFF00C98B).withOpacity(0.4), width: 1.5),
                  ),
                  child: Text(
                    'HELP WITH DIGNITY',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF00C98B),
                      letterSpacing: 4,
                    ),
                  ),
                )
                .animate()
                .slideY(begin: 0.5, end: 0.0, duration: 1000.ms, delay: 800.ms, curve: Curves.easeOutBack)
                .fadeIn(duration: 800.ms, delay: 800.ms)
                .then()
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(begin: 1.0, end: 1.05, duration: 1.seconds),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TiledIcons extends StatelessWidget {
  final Size size;
  const _TiledIcons({required this.size});

  @override
  Widget build(BuildContext context) {
    const iconSize = 60.0;
    const gap = 100.0;
    const opacity = 0.08;

    final cols = (size.width / gap).ceil() + 3;
    final rows = (size.height / gap).ceil() + 3;

    return ClipRect(
      child: OverflowBox(
        maxWidth: double.infinity,
        maxHeight: double.infinity,
        child: SizedBox(
          width: size.width + 100,
          height: size.height + 100,
          child: Stack(
            children: [
              for (int row = 0; row < rows; row++)
                for (int col = 0; col < cols; col++)
                  Positioned(
                    left: col * gap - 50,
                    top: row * gap - 50,
                    child: Opacity(
                      opacity: opacity,
                      child: Transform.rotate(
                        angle: ((row + col) % 2 == 0) ? -0.4 : 0.4,
                        child: Image.asset(
                          (row + col) % 2 == 0
                              ? 'assets/images/icon1.png'
                              : 'assets/images/icon2.png',
                          width: iconSize,
                          height: iconSize,
                          color: const Color(0xFF00C98B),
                        ),
                      ).animate(onPlay: (c) => c.repeat(reverse: true))
                       .rotate(begin: 0, end: ((row + col) % 2 == 0) ? 0.2 : -0.2, duration: 3.seconds),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
