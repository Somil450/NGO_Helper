import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_theme.dart';

class SupplierOnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback onBack;

  const SupplierOnboardingScreen({super.key, required this.onComplete, required this.onBack});

  @override
  State<SupplierOnboardingScreen> createState() => _SupplierOnboardingScreenState();
}

class _SupplierOnboardingScreenState extends State<SupplierOnboardingScreen> {
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
      widget.onComplete();
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
                            onTap: widget.onComplete,
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
// SLIDE 1 (Floating Map)
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
          width: 320,
          height: 200,
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
                      ],
                    ),
                  ],
                ),
                // Crowne Plaza Text Area
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Crowne Plaza New\nDelhi Okhla by IHG', textAlign: TextAlign.right, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF0D3B2E), fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(begin: 1.0, end: 1.05, duration: 2.seconds),
                ),
                // Bottom Left Pill
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00C98B),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('3 rescues nearby', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                  ).animate(onPlay: (c) => c.repeat(reverse: true)).moveX(begin: -5, end: 5, duration: 2.seconds),
                ),
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
// SLIDE 2 (Verified Partners)
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
          width: 300,
          height: 220,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00C98B).withOpacity(0.2), 
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF00C98B), width: 2),
                    ),
                    child: const Icon(Icons.handshake_outlined, color: Colors.white, size: 40),
                  ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(begin: 1.0, end: 1.1, duration: 1.5.seconds),
                  const SizedBox(height: 24),
                  Text('100% Verified NGO', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00C98B), 
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.shieldCheck, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text('Secure & Compliant', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true))
         .rotate(begin: 0.03, end: -0.03, duration: 4.seconds, curve: Curves.easeInOutSine)
         .moveY(begin: 10, end: -10, duration: 3.seconds, curve: Curves.easeInOutSine),
      ),
    );
  }
}

// ---------------------------------------------------------
// SLIDE 3 (They come to you)
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
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 300,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Center(
                    child: Text('They Come to\nYou', textAlign: TextAlign.center, style: GoogleFonts.bricolageGrotesque(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1)),
                  ),
                ),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(begin: 1.0, end: 1.05, duration: 3.seconds).moveY(begin: -5, end: 5, duration: 2.seconds),
            
            Positioned(
              right: -15,
              bottom: 25,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white, 
                  shape: BoxShape.circle, 
                ),
                child: const Icon(LucideIcons.truck, color: Color(0xFF0D3B2E), size: 32),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).moveX(begin: -10, end: 10, duration: 1.5.seconds),
            ),
            
            Positioned(
              left: -20,
              top: -20,
              child: Transform.rotate(
                angle: -0.15,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444), // Red tag
                    borderRadius: BorderRadius.circular(20), 
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.ban, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text('Zero Driving', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white)),
                    ],
                  ),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).rotate(begin: -0.05, end: 0.05, duration: 2.seconds),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// BOTTOM CARD LOGIC
// ---------------------------------------------------------
class _BottomCardContainer extends StatelessWidget {
  final int currentIndex;
  final VoidCallback onNext;

  const _BottomCardContainer({required this.currentIndex, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 64),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 50,
                  offset: const Offset(0, -10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  _getTitle(),
                  style: GoogleFonts.bricolageGrotesque(fontSize: 32, fontWeight: FontWeight.w900, color: const Color(0xFF0D3B2E), height: 1.1),
                ).animate(key: ValueKey('title_$currentIndex')).slideX(begin: 0.1, end: 0).fadeIn(duration: 400.ms),
                const SizedBox(height: 16),
                Text(
                  _getDesc(),
                  style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF477267), height: 1.6, fontWeight: FontWeight.w500),
                ).animate(key: ValueKey('desc_$currentIndex')).slideX(begin: 0.1, end: 0).fadeIn(duration: 400.ms, delay: 100.ms),
                const SizedBox(height: 32),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBadge(_getBadge1Icon(), _getBadge1Text())
                            .animate(key: ValueKey('badge1_$currentIndex')).slideY(begin: 0.5, end: 0).fadeIn(duration: 400.ms, delay: 200.ms),
                          const SizedBox(height: 12),
                          _buildBadge(_getBadge2Icon(), _getBadge2Text())
                            .animate(key: ValueKey('badge2_$currentIndex')).slideY(begin: 0.5, end: 0).fadeIn(duration: 400.ms, delay: 300.ms),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: onNext,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00C98B),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.arrowRight, color: Colors.white, size: 28),
                      ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(begin: 1.0, end: 1.05, duration: 1.seconds),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().slideY(begin: 1.0, end: 0.0, duration: 600.ms, curve: Curves.easeOutCubic),
          
          // Floating Icon Top Left
          Positioned(
            top: -28,
            left: 24,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF00C98B), width: 4),
              ),
              child: Icon(_getFloatingIcon(), color: const Color(0xFF00C98B), size: 32),
            ).animate(key: ValueKey('icon_$currentIndex'))
             .scaleXY(begin: 0.0, end: 1.0, duration: 500.ms, curve: Curves.elasticOut)
             .then()
             .animate(onPlay: (c) => c.repeat(reverse: true))
             .moveY(begin: -5, end: 5, duration: 2.seconds),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF00C98B).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00C98B).withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF00C98B)),
          const SizedBox(width: 8),
          Flexible(child: Text(text, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFF00C98B)))),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (currentIndex) {
      case 0: return 'Feed People, Not Landfills';
      case 1: return '100% Verified Partners';
      case 2: return 'They Come to You';
      default: return '';
    }
  }

  String _getDesc() {
    switch (currentIndex) {
      case 0: return 'Transform your daily unsold inventory into high-quality meals for families, shelters, and food banks right in your own neighborhood.';
      case 1: return 'Donate with complete peace of mind. We rigorously vet every NGO on our platform to ensure your food is handled safely and legally.';
      case 2: return 'No driving required. Verified, registered NGOs will claim your surplus and arrive at your back door with their own vehicles and crates.';
      default: return '';
    }
  }

  IconData _getFloatingIcon() {
    switch (currentIndex) {
      case 0: return LucideIcons.heartHandshake;
      case 1: return LucideIcons.badgeCheck;
      case 2: return LucideIcons.truck;
      default: return Icons.star;
    }
  }

  IconData _getBadge1Icon() {
    switch (currentIndex) {
      case 0: return LucideIcons.mapPin;
      case 1: return LucideIcons.lock;
      case 2: return LucideIcons.clock;
      default: return Icons.star;
    }
  }

  String _getBadge1Text() {
    switch (currentIndex) {
      case 0: return 'Flexible Routes';
      case 1: return 'Secure Handoffs';
      case 2: return 'Saves Time';
      default: return '';
    }
  }

  IconData _getBadge2Icon() {
    switch (currentIndex) {
      case 0: return LucideIcons.leaf;
      case 1: return LucideIcons.fileCheck;
      case 2: return LucideIcons.doorOpen; 
      default: return Icons.star;
    }
  }

  String _getBadge2Text() {
    switch (currentIndex) {
      case 0: return 'Zero Waste';
      case 1: return 'Tax Compliant';
      case 2: return 'Doorstep Pickup';
      default: return '';
    }
  }
}

// ---------------------------------------------------------
// TILED BACKGROUND
// ---------------------------------------------------------
class _TiledIcons extends StatelessWidget {
  final Size size;
  const _TiledIcons({required this.size});

  @override
  Widget build(BuildContext context) {
    const iconSize = 64.0;
    const gap = 120.0;
    const opacity = 0.04;

    final cols = (size.width / gap).ceil() + 3;
    final rows = (size.height / gap).ceil() + 3;

    return ClipRect(
      child: OverflowBox(
        maxWidth: double.infinity,
        maxHeight: double.infinity,
        child: SizedBox(
          width: size.width + 200,
          height: size.height + 200,
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
                        angle: ((row + col) % 2 == 0) ? -0.3 : 0.3,
                        child: Icon(
                          (row + col) % 2 == 0 ? LucideIcons.truck : LucideIcons.apple,
                          size: iconSize,
                          color: Colors.white,
                        ),
                      ).animate(onPlay: (c) => c.repeat(reverse: true))
                       .rotate(begin: 0, end: ((row + col) % 2 == 0) ? 0.2 : -0.2, duration: 4.seconds),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
