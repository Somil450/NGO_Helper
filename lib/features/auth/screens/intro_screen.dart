import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/theme/app_theme.dart';

class IntroScreen extends StatefulWidget {
  final VoidCallback onNGOTap;
  final VoidCallback onSupplierTap;
  final VoidCallback onLoginTap;
  final VoidCallback onEmployeeTap;

  const IntroScreen({
    super.key,
    required this.onNGOTap,
    required this.onSupplierTap,
    required this.onLoginTap,
    required this.onEmployeeTap,
  });

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  final int _totalPages = 5;
  String? _selectedRole;

  void _nextPage() {
    if (_currentIndex < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      if (_selectedRole == 'supplier') {
        widget.onSupplierTap();
      } else if (_selectedRole == 'ngo') {
        widget.onNGOTap();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select an option to continue.'),
            backgroundColor: Color(0xFF0D3B2E),
            duration: Duration(seconds: 2),
          ),
        );
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _previousPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentIndex > 0) {
          _previousPage();
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: Stack(
          children: [
            // Global Insane Background Blobs
            Positioned(
              top: -150, left: -100,
              child: ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(width: 400, height: 400, decoration: BoxDecoration(color: const Color(0xFF00B86B).withOpacity(0.3), shape: BoxShape.circle))),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).move(begin: Offset.zero, end: const Offset(40, 40), duration: 6.seconds),
            
            Positioned(
              top: -50, right: -150,
              child: ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
                child: Container(width: 400, height: 400, decoration: BoxDecoration(color: const Color(0xFF0284C7).withOpacity(0.25), shape: BoxShape.circle))),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).move(begin: Offset.zero, end: const Offset(-50, 20), duration: 7.seconds),
            
            Positioned(
              bottom: 50, left: 50,
              child: ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
                child: Container(width: 350, height: 350, decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withOpacity(0.2), shape: BoxShape.circle))),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).move(begin: Offset.zero, end: const Offset(20, -50), duration: 8.seconds),
            
            Positioned(
              bottom: -150, right: -100,
              child: ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(width: 400, height: 400, decoration: BoxDecoration(color: const Color(0xFFF43F5E).withOpacity(0.15), shape: BoxShape.circle))),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).move(begin: Offset.zero, end: const Offset(-30, -30), duration: 5.seconds),

            // Main Content
            SafeArea(
              child: Column(
                children: [
                  // Top App Bar
                  _buildAppBar(context).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),

                  // Page View
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const ClampingScrollPhysics(),
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      children: [
                        _Slide0(
                          onDonate: () {
                            setState(() {
                              _selectedRole = 'supplier';
                            });
                            widget.onSupplierTap();
                          },
                          onRescue: () {
                            setState(() {
                              _selectedRole = 'ngo';
                            });
                            widget.onNGOTap();
                          },
                          onLoginTap: widget.onLoginTap,
                        ),
                        const _Slide1(),
                        const _Slide2(),
                        const _Slide3(),
                        const _Slide4(),
                      ],
                    ),
                  ),

                  // Bottom Navigation
                  _buildBottomNavigation().animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset('assets/images/logo.png', width: 32, height: 32),
              const SizedBox(width: 8),
              Text(
                'ManavSeva',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF00B86B),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),

          // Lang Toggle + Sign In
          Row(
            children: [
              _buildLanguageToggle(context),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: widget.onLoginTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppTheme.glowShadow,
                  ),
                  child: Text(
                    lang.translate('sign_in') ?? 'Sign In',
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
        ],
      ),
    );
  }

  Widget _buildLanguageToggle(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return GestureDetector(
      onTap: () => lang.toggleLanguage(),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFF064E3B), // Dark green background for toggle
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: lang.currentLocale == 'en' ? const Color(0xFF00B86B) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'EN',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: lang.currentLocale == 'hi' ? const Color(0xFF00B86B) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'हिं',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          GestureDetector(
            onTap: _previousPage,
            child: SizedBox(
              width: 80,
              child: Text(
                _currentIndex > 0 ? 'Back' : '',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF064E3B),
                ),
              ),
            ),
          ),

          // Dots (5 dots for all slides)
          Row(
            children: List.generate(
              5,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentIndex == index
                      ? const Color(0xFF00B86B)
                      : const Color(0xFFE2EDE8),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          // Next Button
          GestureDetector(
            onTap: _nextPage,
            child: Container(
              width: 80,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppTheme.glowShadow,
              ),
              child: Center(
                child: Text(
                  'Next',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// SLIDE 0 (Landing Screen Content)
// ---------------------------------------------------------
class _Slide0 extends StatelessWidget {
  final VoidCallback onDonate;
  final VoidCallback onRescue;
  final VoidCallback onLoginTap;

  const _Slide0({
    required this.onDonate,
    required this.onRescue,
    required this.onLoginTap,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Container(
          width: 380, // Fixed width for consistent scaling
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              
              // Wild Multi-Gradient Header
              FittedBox(
                fit: BoxFit.scaleDown,
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF00B86B), Color(0xFF0284C7), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    'ManavSeva',
                    style: GoogleFonts.bricolageGrotesque(
                      fontSize: 56,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -2.5,
                      height: 1.0,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 100.ms, duration: 500.ms).slideX(begin: -0.1, end: 0),
              
              const SizedBox(height: 8),
              
              Text(
                'Share Happiness.\nStop Waste.',
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                  height: 1.05,
                  letterSpacing: -1.5,
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideX(begin: -0.1, end: 0),
              
              const SizedBox(height: 12),
              Text(
                lang.translate('how_would_you_like_to_use') ?? 'How would you like to use the platform today?',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
              
              const SizedBox(height: 32),
              
              // Donate Food Card (Compact)
              _buildOptionCard(
                icon: LucideIcons.store,
                title: lang.translate('i_want_to_donate_food') ?? 'Donate Food',
                subtitle: lang.translate('donate_food_desc') ?? 'For restaurants, bakeries, and caterers with surplus.',
                onTap: onDonate,
                gradient: AppTheme.stat1Gradient,
              ).animate().fadeIn(delay: 400.ms, duration: 500.ms).slideY(begin: 0.1, end: 0),
              
              const SizedBox(height: 16),
              
              // Rescue Food Card (Compact)
              _buildOptionCard(
                icon: LucideIcons.truck,
                title: lang.translate('i_want_to_rescue_food') ?? 'Rescue Food',
                subtitle: lang.translate('rescue_food_desc') ?? 'For NGOs, shelters, and community kitchens.',
                onTap: onRescue,
                gradient: AppTheme.stat2Gradient,
              ).animate().fadeIn(delay: 500.ms, duration: 500.ms).slideY(begin: 0.1, end: 0),
              
              const SizedBox(height: 64), // Extra bottom spacing for the Next button
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required LinearGradient gradient,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 16, right: 12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: gradient.colors.first.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Get Started',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: Icon(
                icon,
                size: 32,
                color: gradient.colors.first,
              ),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: -5, end: 5, duration: 2.seconds),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// SLIDE 1
// ---------------------------------------------------------
class _Slide1 extends StatelessWidget {
  const _Slide1();

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          // Bouncing trusted badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(30),
              boxShadow: AppTheme.softShadow,
              border: Border.all(color: const Color(0xFF00B86B).withOpacity(0.3), width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF00B86B), size: 14),
                const SizedBox(width: 6),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      lang.translate('trusted_network') ?? 'TRUSTED DONATION & RELIEF NETWORK',
                      style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: const Color(0xFF00B86B), letterSpacing: 1.0),
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: -5, end: 5, duration: 2.seconds),
          
          const SizedBox(height: 16),
          
          FittedBox(
            fit: BoxFit.scaleDown,
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF00B86B), Color(0xFF0284C7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                'Share your extra\nthings to help.',
                textAlign: TextAlign.center,
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.0,
                  letterSpacing: -2.0,
                ),
              ),
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.1, end: 0),
          
          const SizedBox(height: 12),
          
          Text(
            lang.translate('hero_subtitle') ?? 'ManavSeva connects generous people with trusted NGOs to share food, clothes, books, and toys with those who need them most.',
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
          
          const SizedBox(height: 24),
          
          // Crazy 3D Floating Image Element
          Expanded(
            flex: 7,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  angle: -0.05,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: AppTheme.heroGradient,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: AppTheme.deepShadow,
                    ),
                  ),
                ),
                Transform.rotate(
                  angle: 0.05,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: AppTheme.glowShadow,
                      image: const DecorationImage(
                        image: AssetImage('assets/images/auth_bg.png'),
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                  ),
                ),
                // Floating elements
                Positioned(
                  top: -10, right: 10,
                  child: _buildFloatingIcon(LucideIcons.heart, const Color(0xFFF43F5E), 1.seconds),
                ),
                Positioned(
                  bottom: 20, left: 5,
                  child: _buildFloatingIcon(LucideIcons.apple, const Color(0xFF10B981), 1.5.seconds),
                ),
                Positioned(
                  bottom: 40, right: -5,
                  child: _buildFloatingIcon(LucideIcons.shirt, const Color(0xFF3B82F6), 1.2.seconds),
                ),
              ],
            ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.2, end: 0),
          ),
          
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildFloatingIcon(IconData icon, Color color, Duration delay) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
        border: Border.all(color: color.withOpacity(0.2), width: 2),
      ),
      child: Icon(icon, color: color, size: 28),
    ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: -8, end: 8, duration: delay);
  }
}

// ---------------------------------------------------------
// SLIDE 2
// ---------------------------------------------------------
class _Slide2 extends StatelessWidget {
  const _Slide2();

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF00B86B), Color(0xFF0284C7)],
            ).createShader(bounds),
            child: Text(
              'HOW IT WORKS',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 4.0,
                color: Colors.white,
              ),
            ),
          ).animate().fadeIn(delay: 100.ms),
          
          const SizedBox(height: 12),
          
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'From your extra\nto someone\'s smile.',
              textAlign: TextAlign.center,
              style: GoogleFonts.bricolageGrotesque(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: AppTheme.primary,
                height: 1.0,
                letterSpacing: -1.0,
              ),
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
          
          const SizedBox(height: 20),
          
          // Steps cleanly spaced, no messy overlaps, but tilted crazily!
          Expanded(
            flex: 12,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: Transform.rotate(
                      angle: -0.05,
                      child: _buildCrazyStep(
                        number: '1',
                        icon: LucideIcons.packagePlus,
                        title: lang.translate('post_donation') ?? 'Post Donation',
                        subtitle: lang.translate('post_donation_desc') ?? 'Add extra items one time or set a recurring pickup.',
                        gradient: AppTheme.stat1Gradient,
                        offsetX: -16.0,
                      ).animate().fadeIn(delay: 300.ms, duration: 500.ms).scale(begin: const Offset(0.8, 0.8)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Center(
                    child: Transform.rotate(
                      angle: 0.05,
                      child: _buildCrazyStep(
                        number: '2',
                        icon: LucideIcons.mapPin,
                        title: lang.translate('find_nearest_ngo') ?? 'Find Nearest NGO',
                        subtitle: lang.translate('find_ngo_desc') ?? 'Platform matches the donation with a nearby trusted NGO.',
                        gradient: AppTheme.stat2Gradient,
                        offsetX: 16.0,
                      ).animate().fadeIn(delay: 400.ms, duration: 500.ms).scale(begin: const Offset(0.8, 0.8)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Center(
                    child: Transform.rotate(
                      angle: -0.05,
                      child: _buildCrazyStep(
                        number: '3',
                        icon: LucideIcons.truck,
                        title: lang.translate('claim_pickup') ?? 'Claim & Pick Up',
                        subtitle: lang.translate('claim_pickup_desc') ?? 'NGOs claim items and arrange pickup while tracking.',
                        gradient: AppTheme.stat3Gradient,
                        offsetX: -16.0,
                      ).animate().fadeIn(delay: 500.ms, duration: 500.ms).scale(begin: const Offset(0.8, 0.8)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(flex: 3),
        ],
      ),
    );
  }

  Widget _buildCrazyStep({
    required String number,
    required IconData icon,
    required String title,
    required String subtitle,
    required LinearGradient gradient,
    required double offsetX,
  }) {
    return Transform.translate(
      offset: Offset(offsetX, 0),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Container(
          width: 340, // Fixed width so they stay proportionate when scaling down
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.bricolageGrotesque(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                            height: 1.2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Massive background number
              Positioned(
                right: -5,
                top: -15,
                child: Text(
                  number,
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 80,
                    fontWeight: FontWeight.w900,
                    color: Colors.white.withOpacity(0.12),
                    height: 1.0,
                  ),
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
// SLIDE 3
// ---------------------------------------------------------
class _Slide3 extends StatelessWidget {
  const _Slide3();

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    
    final String extraText = 'ManavSeva connects kind donors with trusted NGOs so food, clothes, books, toys, and medical supplies reach people who need them most.';

    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Container(
          width: 380,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. MASSIVE FLOATING TITLE
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF00C98B), Color(0xFF0EA5E9)],
                ).createShader(bounds),
                child: Text(
                  lang.translate('our_mission') ?? 'Our Mission',
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -2,
                    height: 1.0,
                  ),
                ),
              ).animate().fadeIn(delay: 100.ms).scaleXY(begin: 0.8, end: 1.0, duration: 800.ms, curve: Curves.easeOutBack),
              
              const SizedBox(height: 40),
              
              // 2. THE FLOATING IMAGE ISLAND
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // Massive glow behind image
                  Container(
                    width: 280, height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF00C98B).withOpacity(0.3), blurRadius: 60, spreadRadius: 20),
                        BoxShadow(color: const Color(0xFF0EA5E9).withOpacity(0.3), blurRadius: 60, spreadRadius: -10),
                      ],
                    ),
                  ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(begin: 1.0, end: 1.1, duration: 2.seconds),
                  
                  // The Image itself (squircle)
                  Transform.rotate(
                    angle: 0.05,
                    child: Container(
                      width: 320,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50), // super rounded
                        border: Border.all(color: Colors.white, width: 6),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 30, offset: const Offset(10, 20)),
                        ],
                        image: const DecorationImage(
                          image: AssetImage('assets/images/Misson.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutBack),
                  
                  // Orbiting Badges
                  Positioned(
                    top: -20, left: 10,
                    child: _buildOrbBadge(LucideIcons.heart, const Color(0xFFF43F5E)),
                  ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: -10, end: 10, duration: 1.8.seconds),
                  
                  Positioned(
                    bottom: -20, right: 10,
                    child: _buildOrbBadge(LucideIcons.globe, const Color(0xFF0EA5E9)),
                  ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: 10, end: -10, duration: 2.2.seconds),
                ],
              ),
              
              const SizedBox(height: 50),
              
              // 3. THE FLOATING TEXT PILL
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF00C98B).withOpacity(0.15), blurRadius: 40, offset: const Offset(0, 20)),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      extraText,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: AppTheme.textPrimary,
                        height: 1.6,
                        fontWeight: FontWeight.w600,
                      ),
                    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms).scaleXY(begin: 0.9, end: 1.0, curve: Curves.easeOutBack),
              
              const SizedBox(height: 30),
              
              // 4. FLOATING TAGS (Not inside any card, just in open space!)
              Wrap(
                spacing: 12,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  _buildFloatingTag(LucideIcons.utensils, 'Food', const Color(0xFFF59E0B)),
                  _buildFloatingTag(LucideIcons.shirt, 'Clothes', const Color(0xFF0EA5E9)),
                  _buildFloatingTag(LucideIcons.book, 'Books', const Color(0xFF8B5CF6)),
                  _buildFloatingTag(LucideIcons.heartPulse, 'Medical', const Color(0xFFF43F5E)),
                ],
              ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2, end: 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrbBadge(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.3), blurRadius: 20, spreadRadius: 5),
        ],
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildFloatingTag(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.inter(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// SLIDE 4
// ---------------------------------------------------------
class _Slide4 extends StatelessWidget {
  const _Slide4();

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Container(
          width: 380,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Massive glowing shield icon at the top
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF00C98B).withOpacity(0.4), blurRadius: 60, spreadRadius: 20),
                        BoxShadow(color: const Color(0xFF0EA5E9).withOpacity(0.4), blurRadius: 60, spreadRadius: 10),
                      ],
                    ),
                  ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(begin: 1.0, end: 1.2, duration: 2.seconds),
                  
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
                      ],
                    ),
                    child: const Icon(LucideIcons.shieldCheck, size: 80, color: Color(0xFF00C98B)),
                  ).animate().fadeIn(delay: 200.ms).scaleXY(begin: 0.5, end: 1.0, curve: Curves.easeOutBack),
                  
                  // Orbiting small elements
                  Positioned(
                    top: -10, left: -10,
                    child: _buildFloatingCheck(const Color(0xFF0EA5E9)),
                  ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: -10, end: 10, duration: 1.5.seconds),
                  
                  Positioned(
                    bottom: 10, right: -20,
                    child: _buildFloatingCheck(const Color(0xFF8B5CF6)),
                  ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: 10, end: -10, duration: 1.8.seconds),
                ],
              ),
              
              const SizedBox(height: 50),
              
              // First Feature Card (Verified NGOs)
              _buildSleekCard(
                icon: LucideIcons.badgeCheck,
                title: lang.translate('verified_ngos') ?? 'Verified NGOs',
                desc: lang.translate('verified_ngos_desc') ?? 'All our partner NGOs are thoroughly vetted to ensure your trust is maintained.',
                accentColor: const Color(0xFF00C98B),
                delay: 400,
              ),
              
              const SizedBox(height: 20),
              
              // Second Feature Card (Help with Dignity)
              _buildSleekCard(
                icon: LucideIcons.heartHandshake,
                title: lang.translate('izzat_ke_saath') ?? 'Help with Dignity',
                desc: lang.translate('izzat_ke_saath_desc') ?? 'We ensure that donations are distributed with the utmost care and respect.',
                accentColor: const Color(0xFF0EA5E9),
                delay: 600,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingCheck(Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Icon(LucideIcons.check, color: color, size: 20),
    );
  }

  Widget _buildSleekCard({required IconData icon, required String title, required String desc, required Color accentColor, required int delay}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: accentColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: accentColor, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  desc,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutBack);
  }
}
