import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

// -----------------------------------------------------------------------------
// DYNAMIC GLASS BACKGROUND
// -----------------------------------------------------------------------------
class GlassBackground extends StatelessWidget {
  final Widget child;
  const GlassBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base Deep Gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF031611), // Extremely dark green
                Color(0xFF063A29), // Deep emerald
                Color(0xFF021B13), // Almost black
              ],
            ),
          ),
        ),
        // Floating Abstract Elements
        Positioned(
          top: -100,
          right: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF10B981).withOpacity(0.15),
              boxShadow: [
                BoxShadow(color: const Color(0xFF10B981).withOpacity(0.2), blurRadius: 100, spreadRadius: 50),
              ],
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
           .moveY(begin: -20, end: 20, duration: 4.seconds)
           .scaleXY(begin: 1, end: 1.1, duration: 5.seconds),
        ),
        Positioned(
          bottom: -50,
          left: -50,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF059669).withOpacity(0.2),
              boxShadow: [
                BoxShadow(color: const Color(0xFF059669).withOpacity(0.2), blurRadius: 80, spreadRadius: 40),
              ],
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
           .moveX(begin: -20, end: 20, duration: 5.seconds)
           .scaleXY(begin: 1, end: 1.2, duration: 6.seconds),
        ),
        // Content
        SafeArea(child: child),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// FROSTED GLASS CONTAINER (FORM WRAPPER)
// -----------------------------------------------------------------------------
class GlassContainer extends StatelessWidget {
  final Widget child;
  const GlassContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 10)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
            child: child,
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// GLASS INPUT BOX
// -----------------------------------------------------------------------------
class GlassLabel extends StatelessWidget {
  final String text;
  const GlassLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white.withOpacity(0.9),
        ),
      ),
    );
  }
}

class GlassInputBox extends StatefulWidget {
  final String hintText;
  final bool showTrailingEye;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;

  const GlassInputBox({
    super.key,
    required this.hintText,
    this.showTrailingEye = false,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
  });

  @override
  State<GlassInputBox> createState() => _GlassInputBoxState();
}

class _GlassInputBoxState extends State<GlassInputBox> {
  late bool _obscureText;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _isFocused ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isFocused ? const Color(0xFF10B981) : Colors.white.withOpacity(0.2),
          width: _isFocused ? 1.5 : 1.0,
        ),
        boxShadow: _isFocused
            ? [BoxShadow(color: const Color(0xFF10B981).withOpacity(0.2), blurRadius: 10, spreadRadius: 1)]
            : [],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              obscureText: _obscureText,
              keyboardType: widget.keyboardType,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.4),
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          if (widget.showTrailingEye)
            GestureDetector(
              onTap: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
              child: Icon(
                _obscureText ? LucideIcons.eyeOff : LucideIcons.eye,
                color: Colors.white.withOpacity(0.6),
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// GLASS DROPDOWN BOX
// -----------------------------------------------------------------------------
class GlassDropdownBox extends StatelessWidget {
  final String hintText;
  final String? value;
  final ValueChanged<String?> onChanged;
  final List<String> items;
  
  const GlassDropdownBox({
    super.key,
    required this.hintText, 
    this.value, 
    required this.onChanged, 
    required this.items,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: const Color(0xFF063A29), // Dark green dropdown
          hint: Text(hintText, style: GoogleFonts.inter(fontSize: 14, color: Colors.white.withOpacity(0.4))),
          icon: Icon(LucideIcons.chevronDown, color: Colors.white.withOpacity(0.6), size: 16),
          isExpanded: true,
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: GoogleFonts.inter(fontSize: 14, color: Colors.white)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// GLASS SOCIAL LOGINS
// -----------------------------------------------------------------------------
class GlassSocialLogins extends StatelessWidget {
  final VoidCallback? onGoogleTap;
  const GlassSocialLogins({super.key, this.onGoogleTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
              borderRadius: BorderRadius.circular(26),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.apple, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('Apple', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: onGoogleTap,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                border: Border.all(color: Colors.white.withOpacity(0.15)),
                borderRadius: BorderRadius.circular(26),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/google.png', width: 18, height: 18, errorBuilder: (_,__,___) => const Icon(Icons.g_mobiledata, size: 24, color: Colors.blue)),
                  const SizedBox(width: 8),
                  Text('Google', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// GLOWING PRIMARY BUTTON
// -----------------------------------------------------------------------------
class GlowingButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isLoading;
  
  const GlowingButton({super.key, required this.text, this.onTap, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF059669)],
          ),
          borderRadius: BorderRadius.circular(27),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: isLoading
          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : Text(text, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PREMIUM ROLE TOGGLE
// -----------------------------------------------------------------------------
class GlassRoleToggle extends StatelessWidget {
  final bool isNgo;
  final VoidCallback onSwitchRole;
  
  const GlassRoleToggle({super.key, required this.isNgo, required this.onSwitchRole});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Stack(
        children: [
          // Animated slider background
          AnimatedAlign(
            alignment: isNgo ? Alignment.centerLeft : Alignment.centerRight,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                  boxShadow: [
                    BoxShadow(color: Colors.white.withOpacity(0.1), blurRadius: 10),
                  ],
                ),
              ),
            ),
          ),
          // Texts
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () { if (!isNgo) onSwitchRole(); },
                  child: Container(
                    alignment: Alignment.center,
                    color: Colors.transparent, // For hit testing
                    child: Text('NGO', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: isNgo ? Colors.white : Colors.white.withOpacity(0.5))),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () { if (isNgo) onSwitchRole(); },
                  child: Container(
                    alignment: Alignment.center,
                    color: Colors.transparent, // For hit testing
                    child: Text('Donor', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: !isNgo ? Colors.white : Colors.white.withOpacity(0.5))),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
