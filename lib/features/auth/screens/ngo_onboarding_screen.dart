import 'dart:ui';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_theme.dart';

class NGOOnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;
  final VoidCallback onBack;

  const NGOOnboardingScreen({super.key, required this.onFinish, required this.onBack});

  @override
  State<NGOOnboardingScreen> createState() => _NGOOnboardingScreenState();
}

class _NGOOnboardingScreenState extends State<NGOOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentIndex < 2) {
      _pageController.animateToPage(
        _currentIndex + 1,
        duration: const Duration(milliseconds: 600),
        curve: Curves.fastOutSlowIn,
      );
    } else {
      widget.onFinish();
    }
  }

  void _onBack() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.fastOutSlowIn,
      );
    } else {
      widget.onBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _onBack();
      },
      child: Scaffold(
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
                      top: size.height * 0.05,
                      left: -50,
                      child: Container(
                        width: 400,
                        height: 400,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF00C98B).withOpacity(0.35),
                        ),
                      ).animate(onPlay: (c) => c.repeat(reverse: true))
                       .moveX(begin: 0, end: size.width * 0.5, duration: 6.seconds, curve: Curves.easeInOutSine)
                       .moveY(begin: 0, end: 100, duration: 7.seconds, curve: Curves.easeInOutSine),
                    ),
                    Positioned(
                      bottom: size.height * 0.2,
                      right: -50,
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF0EA5E9).withOpacity(0.25),
                        ),
                      ).animate(onPlay: (c) => c.repeat(reverse: true))
                       .moveX(begin: 0, end: -size.width * 0.4, duration: 5.5.seconds, curve: Curves.easeInOutSine)
                       .moveY(begin: 0, end: -100, duration: 6.5.seconds, curve: Curves.easeInOutSine),
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
                  .moveY(begin: -20, end: 20, duration: 8.seconds, curve: Curves.easeInOut)
                  .moveX(begin: -15, end: 15, duration: 6.seconds, curve: Curves.easeInOut),
              ),

              SafeArea(
                child: Column(
                  children: [
                    // Top bar: Indicators & Skip
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 40), // Balance the skip text
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(3, (index) {
                              final isActive = index == _currentIndex;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: isActive ? 32 : 12,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isActive ? const Color(0xFF00C98B) : Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }),
                          ),
                          GestureDetector(
                            onTap: widget.onFinish,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withOpacity(0.2)),
                              ),
                              child: Text(
                                'Skip',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Expanded PageView for Center Art
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const BouncingScrollPhysics(),
                        onPageChanged: (index) => setState(() => _currentIndex = index),
                        children: const [
                          _Slide1(),
                          _Slide2(),
                          _Slide3(),
                        ],
                      ),
                    ),
                    
                    // Bottom Card placed below the PageView in the Column
                    _BottomCardContainer(
                      currentIndex: _currentIndex,
                      onNext: _nextPage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// SLIDE 1 (Live Map of Nearby Surplus)
// ---------------------------------------------------------
class _Slide1 extends StatelessWidget {
  const _Slide1();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.topCenter,
        child: Container(
          margin: const EdgeInsets.only(top: 24),
          width: 320,
          height: 260,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: const LatLng(28.52728, 77.27131),
                    initialZoom: 15.0,
                    interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.manavseva',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: const LatLng(28.52728, 77.27131),
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.location_on, color: Color(0xFFEF4444), size: 36)
                            .animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: -5, end: 5, duration: 1.seconds),
                        ),
                        Marker(
                          point: const LatLng(28.525, 77.275),
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.location_on, color: Color(0xFFEF4444), size: 36)
                            .animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: -5, end: 5, duration: 1.2.seconds),
                        ),
                      ],
                    ),
                  ],
                ),
                // Overlay to give a bit of dark tint so it fits the aesthetic
                Container(color: Colors.black.withOpacity(0.1)),
              ],
            ),
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true))
         .rotate(begin: -0.02, end: 0.02, duration: 3.seconds, curve: Curves.easeInOutSine)
         .moveY(begin: -10, end: 10, duration: 4.seconds, curve: Curves.easeInOutSine),
      ),
    );
  }
}

// ---------------------------------------------------------
// SLIDE 2 (Frictionless Pickups)
// ---------------------------------------------------------
class _Slide2 extends StatelessWidget {
  const _Slide2();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.topCenter,
        child: Container(
          margin: const EdgeInsets.only(top: 24),
          width: 300,
          height: 210,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.assignment_outlined,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Active Claim',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.access_time_outlined,
                          size: 14,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Expires in 2h',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(height: 1, color: Colors.white.withOpacity(0.2)),
                    const SizedBox(height: 16),
                    Text(
                      'Fresh Produce Box',
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '45 lbs • 2 crates',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C98B).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(color: const Color(0xFF00C98B).withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Gate Instructions',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true))
         .rotate(begin: 0.02, end: -0.02, duration: 3.seconds, curve: Curves.easeInOutSine)
         .moveY(begin: 10, end: -10, duration: 4.seconds, curve: Curves.easeInOutSine),
      ),
    );
  }
}

// ---------------------------------------------------------
// SLIDE 3 (Track Your Community Impact)
// ---------------------------------------------------------
class _Slide3 extends StatelessWidget {
  const _Slide3();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.topCenter,
        child: Container(
          margin: const EdgeInsets.only(top: 24),
          width: 320,
          height: 280,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Rescue Target Box
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'RESCUE TARGET',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '85%',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF00C98B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: const LinearProgressIndicator(
                              value: 0.85,
                              minHeight: 10,
                              backgroundColor: Colors.white24,
                              color: Color(0xFF00C98B),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFF00C98B),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check, size: 14, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: 5, end: -5, duration: 2.5.seconds),
              const SizedBox(height: 12),
              // Metric Cards Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.eco_outlined, color: Colors.white, size: 24),
                                const SizedBox(height: 12),
                                Text(
                                  'Zero Waste\nScore',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '9/10',
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: -5, end: 5, duration: 3.seconds),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.people_outline, color: Colors.white, size: 24),
                                const SizedBox(height: 12),
                                Text(
                                  'Community\nImpact',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '450 Meals',
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: 5, end: -5, duration: 3.seconds),
                  ),
                ],
              ),
            ],
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true))
         .rotate(begin: -0.01, end: 0.01, duration: 4.seconds, curve: Curves.easeInOutSine)
         .moveY(begin: -8, end: 8, duration: 5.seconds, curve: Curves.easeInOutSine),
      ),
    );
  }
}

// ---------------------------------------------------------
// Bottom Card Container
// ---------------------------------------------------------
class _BottomCardContainer extends StatelessWidget {
  final int currentIndex;
  final VoidCallback onNext;

  const _BottomCardContainer({
    required this.currentIndex,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    // Dynamic text data for each slide
    final titles = [
      'Live Map of\nNearby Surplus',
      'Frictionless\nPickups',
      'Track Your\nCommunity Impact',
    ];

    final descriptions = [
      'Instantly locate fresh, high-quality food donations from local restaurants and bakeries in real-time.',
      'Claim food with one tap and get optimized routing, gate codes, and direct contact details.',
      'Measure the meals you provide and track your zero-waste milestones to share with donors.',
    ];

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 64),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
        ),
        padding: const EdgeInsets.fromLTRB(32, 32, 32, 32),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Animated Title
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Text(
                titles[currentIndex],
                key: ValueKey<int>(currentIndex),
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  height: 1.1,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Animated Description
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Text(
                descriptions[currentIndex],
                key: ValueKey<int>(currentIndex + 10), // Different key
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Bottom Action Row
            Row(
              children: [
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildBadge(currentIndex),
                  ),
                ),
                const SizedBox(width: 16),
                // The circular next button (NO BOXSHADOW)
                GestureDetector(
                  onTap: onNext,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00C98B),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildBadge(int index) {
    if (index == 0) {
      return Container(
        key: const ValueKey(0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0EA5E9).withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.mapPin, color: Color(0xFF0EA5E9), size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Live Updates',
                style: GoogleFonts.inter(
                  color: const Color(0xFF0EA5E9),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (index == 1) {
      return Container(
        key: const ValueKey(1),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF8B5CF6).withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.zap, color: Color(0xFF8B5CF6), size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Instant Claims',
                style: GoogleFonts.inter(
                  color: const Color(0xFF8B5CF6),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        key: const ValueKey(2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF59E0B).withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.barChart2, color: Color(0xFFF59E0B), size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Full Tracking',
                style: GoogleFonts.inter(
                  color: const Color(0xFFF59E0B),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}

// ---------------------------------------------------------
// Tiled Parallax Background
// ---------------------------------------------------------
class _TiledIcons extends StatelessWidget {
  final Size size;
  const _TiledIcons({required this.size});

  @override
  Widget build(BuildContext context) {
    const double iconSize = 24.0;
    const double spacing = 60.0;
    final int cols = (size.width / (iconSize + spacing)).ceil() + 2;
    final int rows = (size.height / (iconSize + spacing)).ceil() + 2;

    final icons = [
      LucideIcons.heart,
      LucideIcons.coffee,
      LucideIcons.utensils,
      LucideIcons.mapPin,
      LucideIcons.apple,
      LucideIcons.sun,
    ];

    return Opacity(
      opacity: 0.03, // Very faint
      child: Transform.rotate(
        angle: -0.2, // Slanted background
        child: Stack(
          children: List.generate(rows * cols, (index) {
            final int r = index ~/ cols;
            final int c = index % cols;
            final icon = icons[(r + c) % icons.length];
            return Positioned(
              top: r * (iconSize + spacing) - 50,
              left: c * (iconSize + spacing) - 50,
              child: Icon(icon, size: iconSize, color: Colors.white),
            );
          }),
        ),
      ),
    );
  }
}
