import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // === BRAND COLORS ===
  static const Color primary       = Color(0xFF00C98B);
  static const Color primaryDark   = Color(0xFF064E3B);
  static const Color primaryLight  = Color(0xFFD1FAE5);
  static const Color background    = Color(0xFFF4F8F5);
  static const Color surface       = Colors.white;

  static const Color textPrimary   = Color(0xFF0D2B1E);
  static const Color textSecondary = Color(0xFF3D7A60);
  static const Color textMuted     = Color(0xFF94A3B8);

  static const Color amber         = Color(0xFFF59E0B);
  static const Color coral         = Color(0xFFFF6B6B);
  static const Color violet        = Color(0xFF7C3AED);
  static const Color sky           = Color(0xFF0EA5E9);

  // === GRADIENTS ===
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00E096), Color(0xFF00A86B)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF064E3B), Color(0xFF0A7851), Color(0xFF00C98B)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFEDF7F2), Color(0xFFF9FFF9)],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF085A45), Color(0xFF043428)],
  );

  static const LinearGradient stat1Gradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF064E3B), Color(0xFF00C98B)],
  );
  static const LinearGradient stat2Gradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
  );
  static const LinearGradient stat3Gradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B6B), Color(0xFFFFA07A)],
  );
  static const LinearGradient stat4Gradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF0EA5E9), Color(0xFF38BDF8)],
  );

  // === SHADOWS ===
  static List<BoxShadow> get softShadow => [
    BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 8)),
  ];

  static List<BoxShadow> get glowShadow => [
    BoxShadow(color: primary.withOpacity(0.35), blurRadius: 24, offset: const Offset(0, 8)),
  ];

  static List<BoxShadow> get deepShadow => [
    BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 32, offset: const Offset(0, 16)),
    BoxShadow(color: primary.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 4)),
  ];

  static List<BoxShadow> get floatShadow => [
    BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 40, offset: const Offset(0, 20)),
    BoxShadow(color: primary.withOpacity(0.10), blurRadius: 20, offset: const Offset(0, 8)),
  ];

  // === GLASSMORPHISM ===
  static Widget glassContainer({
    required Widget child,
    double borderRadius = 24.0,
    EdgeInsetsGeometry? padding,
    double blur = 10.0,
    Color color = Colors.white,
    double opacity = 0.7,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color.withOpacity(opacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
          ),
          child: child,
        ),
      ),
    );
  }

  // === BOLD STAT CARD ===
  static Widget statCard({
    required String label,
    required String value,
    String? unit,
    required IconData icon,
    required LinearGradient gradient,
    String? badge,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: deepShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge,
                    style: GoogleFonts.inter(
                      fontSize: 10, fontWeight: FontWeight.w700,
                      color: Colors.white, letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white, height: 1.0,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Text(unit, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white70)),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.8))),
        ],
      ),
    );
  }
}


