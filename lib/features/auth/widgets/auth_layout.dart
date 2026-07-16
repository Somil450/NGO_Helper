import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthLayout extends StatelessWidget {
  final Widget formContent;
  final bool isReversed;
  final Color brandingBackgroundColor;
  final String title;
  final String subtitle;
  final int? activeStage;
  final String topRightText;
  final String topRightLinkText;
  final VoidCallback onTopRightLinkTap;

  const AuthLayout({
    super.key,
    required this.formContent,
    this.isReversed = false,
    required this.brandingBackgroundColor,
    required this.title,
    required this.subtitle,
    this.activeStage,
    required this.topRightText,
    required this.topRightLinkText,
    required this.onTopRightLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    // Header takes ~28% of screen, rest is form
    final headerHeight = screenHeight * 0.28;

    return Scaffold(
      backgroundColor: const Color(0xFF064e3b),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Animated background behind header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: headerHeight + 60,
            child: const _AuthAnimatedBackground(),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Compact Header ──
                SizedBox(
                  height: headerHeight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  alignment: Alignment.center,
                                  child: Image.asset(
                                    'assets/images/logo.png',
                                    width: 22,
                                    height: 22,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.volunteer_activism,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'ManavSeva',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: onTopRightLinkTap,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      topRightText,
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: Colors.white.withOpacity(0.8),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      topRightLinkText,
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF6EE7B7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Title
                        Text(
                          title,
                          style: GoogleFonts.inter(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.1,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.7),
                            height: 1.4,
                          ),
                        ),
                        if (activeStage != null) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _StageChip(label: 'Account', active: activeStage! >= 1, done: activeStage! > 1),
                              const SizedBox(width: 6),
                              Container(width: 16, height: 1, color: Colors.white.withOpacity(0.3)),
                              const SizedBox(width: 6),
                              _StageChip(label: 'Details', active: activeStage! >= 2, done: false),
                            ],
                          ),
                        ],
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                // ── Form Card ──
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAF8),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x20000000),
                          blurRadius: 24,
                          offset: Offset(0, -4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width - 48,
                            ),
                            child: formContent,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StageChip extends StatelessWidget {
  final String label;
  final bool active;
  final bool done;

  const _StageChip({required this.label, required this.active, required this.done});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFF059669)
            : Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: active ? const Color(0xFF059669) : Colors.white.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (done)
            const Icon(Icons.check, size: 10, color: Colors.white)
          else
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active ? Colors.white : Colors.white.withOpacity(0.5),
              ),
            ),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: active ? Colors.white : Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthAnimatedBackground extends StatefulWidget {
  const _AuthAnimatedBackground();

  @override
  State<_AuthAnimatedBackground> createState() => _AuthAnimatedBackgroundState();
}

class _AuthAnimatedBackgroundState extends State<_AuthAnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _BackgroundPainter(_controller.value),
        );
      },
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final double animationValue;
  _BackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Dark green gradient background
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF064e3b), Color(0xFF065f46)],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    // Animated blobs
    final paint1 = Paint()
      ..color = const Color(0xFF059669).withOpacity(0.25)
      ..style = PaintingStyle.fill;

    final x1 = size.width * 0.8 + math.cos(animationValue * 2 * math.pi) * size.width * 0.15;
    final y1 = size.height * 0.2 + math.sin(animationValue * 2 * math.pi) * size.height * 0.15;
    canvas.drawCircle(Offset(x1, y1), size.width * 0.4, paint1);

    final paint2 = Paint()
      ..color = const Color(0xFF34d399).withOpacity(0.12)
      ..style = PaintingStyle.fill;
    final x2 = size.width * 0.1 + math.sin(animationValue * 2 * math.pi) * size.width * 0.1;
    final y2 = size.height * 0.75 + math.cos(animationValue * 2 * math.pi) * size.height * 0.1;
    canvas.drawCircle(Offset(x2, y2), size.width * 0.35, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
