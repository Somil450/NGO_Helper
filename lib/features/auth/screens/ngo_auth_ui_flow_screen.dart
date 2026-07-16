import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/glass_auth_widgets.dart';

class NGOAuthUIFlowScreen extends StatefulWidget {
  final VoidCallback onBackToLanding;
  final VoidCallback onComplete;
  final VoidCallback onSwitchRole;

  const NGOAuthUIFlowScreen({
    super.key,
    required this.onBackToLanding,
    required this.onComplete,
    required this.onSwitchRole,
  });

  @override
  State<NGOAuthUIFlowScreen> createState() => _NGOAuthUIFlowScreenState();
}

enum _AuthStep {
  login,
  signup,
  organizationDetails,
  verifyOtp,
}

class _NGOAuthUIFlowScreenState extends State<NGOAuthUIFlowScreen> {
  _AuthStep _step = _AuthStep.login;
  String _email = '';
  String _password = '';
  String _phone = '';
  Map<String, dynamic>? _pendingDetails;

  void _goTo(_AuthStep step) => setState(() => _step = step);

  void _onBack() {
    switch (_step) {
      case _AuthStep.login:
      case _AuthStep.signup:
        widget.onBackToLanding();
        break;
      case _AuthStep.organizationDetails:
        _goTo(_AuthStep.signup);
        break;
      case _AuthStep.verifyOtp:
        _goTo(_AuthStep.organizationDetails);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _onBack();
      },
      child: Scaffold(
        body: GlassBackground(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.05, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: _buildCurrentFormView(),
        ),
      ),
    ),
    );
  }

  Widget _buildCurrentFormView() {
    switch (_step) {
      case _AuthStep.login:
        return _LoginView(
          key: const ValueKey('loginView'),
          onSignUpTap: () => _goTo(_AuthStep.signup),
          onSwitchRole: widget.onSwitchRole,
          onLoginSuccess: widget.onComplete,
        );
      case _AuthStep.signup:
        return _SignUpView(
          key: const ValueKey('signUpView'),
          onLoginTap: () => _goTo(_AuthStep.login),
          onOrganizationDetailsTap: (email, password) {
            _email = email;
            _password = password;
            _goTo(_AuthStep.organizationDetails);
          },
          onLoginSuccess: widget.onComplete,
        );
      case _AuthStep.organizationDetails:
        return _OrganizationDetailsView(
          key: const ValueKey('organizationDetailsView'),
          onBack: () => _goTo(_AuthStep.signup),
          onComplete: (String phone, Map<String, dynamic> details) async {
            _phone = phone;
            _pendingDetails = details;
            
            final auth = context.read<AuthProvider>();
            final success = await auth.sendPhoneOtp(_phone);
            if (success && mounted) {
              _goTo(_AuthStep.verifyOtp);
            } else if (auth.error != null && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(auth.error!), backgroundColor: Colors.red),
              );
              auth.clearError();
            }
          },
        );
      case _AuthStep.verifyOtp:
        return _OTPView(
          key: const ValueKey('otpView'),
          phone: _phone,
          onBack: () => _goTo(_AuthStep.organizationDetails),
          onComplete: (String otp) async {
            final auth = context.read<AuthProvider>();
            final success = await auth.verifyPhoneOtpAndSignUp(
              otp: otp,
              email: _email,
              password: _password,
              userType: 'ngo',
              details: _pendingDetails,
            );
            
            if (success && mounted) {
              await auth.signOut();
              _goTo(_AuthStep.login);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration Successful! Please login.')));
            } else if (auth.error != null && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(auth.error!), backgroundColor: Colors.red),
              );
              auth.clearError();
            }
          },
        );
    }
  }
}

// -----------------------------------------------------------------------------
// VIEWS
// -----------------------------------------------------------------------------

class _LoginView extends StatefulWidget {
  final VoidCallback onSignUpTap;
  final VoidCallback onSwitchRole;
  final VoidCallback onLoginSuccess;

  const _LoginView({
    super.key,
    required this.onSignUpTap,
    required this.onSwitchRole,
    required this.onLoginSuccess,
  });

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    
    return SingleChildScrollView(
      child: GlassContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Welcome Back!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white),
            ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 8),
            Text(
              'Log in to your NGO account to track your impact.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: Colors.white.withOpacity(0.7)),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 32),
            GlassRoleToggle(isNgo: true, onSwitchRole: widget.onSwitchRole)
                .animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 32),
            const GlassLabel(text: 'Email').animate().fadeIn(delay: 400.ms, duration: 400.ms),
            GlassInputBox(hintText: 'Enter your Email', controller: _emailController, keyboardType: TextInputType.emailAddress)
              .animate().fadeIn(delay: 450.ms, duration: 400.ms).slideX(begin: 0.05, end: 0),
            const SizedBox(height: 20),
            const GlassLabel(text: 'Password').animate().fadeIn(delay: 500.ms, duration: 400.ms),
            GlassInputBox(hintText: 'Enter your Password', controller: _passwordController, obscureText: true, showTrailingEye: true)
              .animate().fadeIn(delay: 550.ms, duration: 400.ms).slideX(begin: 0.05, end: 0),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text('Forgot Password?', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF10B981), fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 32),
            GlowingButton(
              text: 'Log In',
              isLoading: authProvider.isLoading,
              onTap: () async {
                final email = _emailController.text.trim();
                final password = _passwordController.text;
                if (email.isEmpty || password.isEmpty) return;
                final success = await authProvider.signInWithEmail(email: email, password: password, expectedUserType: 'ngo');
                if (success && mounted) {
                  widget.onLoginSuccess();
                } else if (authProvider.error != null && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(authProvider.error!), backgroundColor: Colors.red));
                  authProvider.clearError();
                }
              }
            ).animate().fadeIn(delay: 650.ms, duration: 400.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(child: Divider(color: Colors.white.withOpacity(0.2))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Or Continue with', style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withOpacity(0.5))),
                ),
                Expanded(child: Divider(color: Colors.white.withOpacity(0.2))),
              ],
            ),
            const SizedBox(height: 24),
            GlassSocialLogins(
               onGoogleTap: () async {
                  final auth = context.read<AuthProvider>();
                  final success = await auth.signInWithGoogle(userType: 'ngo', isLogin: true);
                  if (success && mounted) {
                    if (auth.isOnboarded) {
                       widget.onLoginSuccess();
                    }
                  } else if (auth.error != null && mounted) {
                    if (auth.error == 'REQUIRES_PASSWORD') {
                      _showLinkAccountDialog(context, auth, 'ngo', widget.onLoginSuccess);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.error!)));
                      auth.clearError();
                    }
                  }
               }
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: widget.onSignUpTap,
              child: Center(
                child: RichText(
                  text: TextSpan(
                    text: 'Don\'t Have an Account? ',
                    style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withOpacity(0.7)),
                    children: [
                      TextSpan(
                        text: 'Sign Up',
                        style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF10B981), fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignUpView extends StatefulWidget {
  final VoidCallback onLoginTap;
  final void Function(String, String) onOrganizationDetailsTap;
  final VoidCallback onLoginSuccess;

  const _SignUpView({
    super.key,
    required this.onLoginTap,
    required this.onOrganizationDetailsTap,
    required this.onLoginSuccess,
  });

  @override
  State<_SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<_SignUpView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: GlassContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Create NGO Account',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Join the SurplusShare network.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: Colors.white.withOpacity(0.7)),
            ),
            const SizedBox(height: 32),
            const GlassLabel(text: 'Email'),
            GlassInputBox(hintText: 'Enter your Email', controller: _emailController, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 20),
            const GlassLabel(text: 'Password'),
            GlassInputBox(hintText: 'Enter your Password', controller: _passwordController, obscureText: true, showTrailingEye: true),
            const SizedBox(height: 20),
            const GlassLabel(text: 'Confirm Password'),
            GlassInputBox(hintText: 'Confirm your Password', controller: _confirmPasswordController, obscureText: true, showTrailingEye: true),
            const SizedBox(height: 32),
            GlowingButton(
              text: 'Organization Details',
              onTap: () {
                 final email = _emailController.text.trim();
                 final password = _passwordController.text;
                 if (email.isNotEmpty && password.isNotEmpty && password == _confirmPasswordController.text) {
                   widget.onOrganizationDetailsTap(email, password);
                 } else if (password != _confirmPasswordController.text) {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
                 }
              }
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(child: Divider(color: Colors.white.withOpacity(0.2))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Or Continue with', style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withOpacity(0.5))),
                ),
                Expanded(child: Divider(color: Colors.white.withOpacity(0.2))),
              ],
            ),
            const SizedBox(height: 24),
            GlassSocialLogins(
              onGoogleTap: () async {
                 final auth = context.read<AuthProvider>();
                 final success = await auth.signInWithGoogle(userType: 'ngo', isLogin: false);
                 if (success && mounted) {
                   if (auth.isOnboarded) {
                     widget.onLoginSuccess();
                   } else {
                     widget.onOrganizationDetailsTap('', '');
                   }
                 } else if (auth.error != null && mounted) {
                    if (auth.error == 'REQUIRES_PASSWORD') {
                      _showLinkAccountDialog(context, auth, 'ngo', widget.onLoginSuccess);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.error!)));
                      auth.clearError();
                    }
                 }
              }
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: widget.onLoginTap,
              child: Center(
                child: RichText(
                  text: TextSpan(
                    text: 'Already Have an Account? ',
                    style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withOpacity(0.7)),
                    children: [
                      TextSpan(
                        text: 'Login',
                        style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF10B981), fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrganizationDetailsView extends StatefulWidget {
  final VoidCallback onBack;
  final void Function(String phone, Map<String, dynamic> details) onComplete;
  
  const _OrganizationDetailsView({super.key, required this.onBack, required this.onComplete});
  
  @override
  State<_OrganizationDetailsView> createState() => _OrganizationDetailsViewState();
}

class _OrganizationDetailsViewState extends State<_OrganizationDetailsView> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _missionCtrl = TextEditingController();
  
  String? _selectedState;
  String? _selectedTown;
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: GlassContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: widget.onBack,
                  child: const Icon(LucideIcons.chevronLeft, size: 24, color: Colors.white),
                ),
                Expanded(
                  child: Text('Organization Details', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
                const SizedBox(width: 24),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Please enter all the information required below',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withOpacity(0.7)),
            ),
            const SizedBox(height: 24),
            const GlassLabel(text: 'Organization Name'),
            GlassInputBox(hintText: 'Enter your Org name', controller: _nameCtrl),
            const SizedBox(height: 16),
            const GlassLabel(text: 'Contact Number'),
            GlassInputBox(hintText: '+91', controller: _phoneCtrl, keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const GlassLabel(text: 'State'),
                      GlassDropdownBox(hintText: 'State', items: const ['Maharashtra', 'Delhi', 'Karnataka'], value: _selectedState, onChanged: (v) => setState(()=>_selectedState = v)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const GlassLabel(text: 'Pin Code'),
                      GlassInputBox(hintText: 'eg 827111', controller: _pinCtrl, keyboardType: TextInputType.number),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const GlassLabel(text: 'City / Town'),
                      GlassDropdownBox(hintText: 'Town', value: _selectedTown, items: const ['Pune', 'Mumbai', 'Nashik'], onChanged: (v) => setState(()=>_selectedTown = v)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const GlassLabel(text: 'Street Address'),
                      GlassInputBox(hintText: 'Building, Street', controller: _streetCtrl),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const GlassLabel(text: 'Confirm Location'),
            Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              clipBehavior: Clip.hardEdge,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: const LatLng(19.8450, 74.0000),
                  initialZoom: 12.5,
                  interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.manavseva',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: const LatLng(19.8450, 74.0000),
                        width: 40,
                        height: 40,
                        child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const GlassLabel(text: 'Mission Statement'),
            GlassInputBox(hintText: 'Briefly describe your focus...', controller: _missionCtrl),
            const SizedBox(height: 24),
            GlowingButton(
              text: 'Send Verification OTP',
              onTap: () {
                 final phone = _phoneCtrl.text.trim();
                 final details = {
                    'ngoName': _nameCtrl.text.trim(),
                    'phone': phone,
                    'state': _selectedState ?? '',
                    'town': _selectedTown ?? '',
                    'pin': _pinCtrl.text.trim(),
                    'streetAddress': _streetCtrl.text.trim(),
                    'mission': _missionCtrl.text.trim(),
                 };
                 widget.onComplete(phone, details);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _OTPBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  
  const _OTPBox({required this.controller, required this.focusNode, required this.onChanged});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
        decoration: const InputDecoration(counterText: '', border: InputBorder.none),
      ),
    );
  }
}

class _OTPView extends StatefulWidget {
  final String phone;
  final VoidCallback onBack;
  final void Function(String) onComplete;
  
  const _OTPView({super.key, required this.phone, required this.onBack, required this.onComplete});
  
  @override
  State<_OTPView> createState() => _OTPViewState();
}

class _OTPViewState extends State<_OTPView> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: GlassContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: widget.onBack,
                  child: const Icon(LucideIcons.chevronLeft, size: 24, color: Colors.white),
                ),
                Expanded(
                  child: Text('Phone Verification', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
                const SizedBox(width: 24),
              ],
            ),
            const SizedBox(height: 48),
            Text(
              'Enter 6 digit verification code sent to your\nphone number',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.8)),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.phone.isEmpty ? '+91 0000000000' : widget.phone,
                  style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF10B981), fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                const Icon(LucideIcons.pencil, size: 14, color: Color(0xFF10B981)),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return _OTPBox(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  onChanged: (value) {
                    if (value.isNotEmpty && index < 5) {
                      _focusNodes[index + 1].requestFocus();
                    } else if (value.isEmpty && index > 0) {
                      _focusNodes[index - 1].requestFocus();
                    }
                    
                    if (index == 5 && value.isNotEmpty) {
                      final otp = _controllers.map((e) => e.text).join();
                      if (otp.length == 6) {
                        widget.onComplete(otp);
                      }
                    }
                  },
                );
              }),
            ),
            const SizedBox(height: 48),
            Text(
              'Resend Code',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF10B981), fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

void _showLinkAccountDialog(BuildContext context, AuthProvider auth, String expectedUserType, VoidCallback onSuccess) {
  final pwdController = TextEditingController();
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: const Color(0xFF031611),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.white.withOpacity(0.1))),
        title: Text(
          'Link Google Account',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'An account with ${auth.pendingGoogleEmail} already exists. Please enter your password to link your Google account.',
              style: GoogleFonts.inter(fontSize: 14, color: Colors.white.withOpacity(0.7)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pwdController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Password',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF10B981))),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              auth.clearError();
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () async {
              final pwd = pwdController.text;
              if (pwd.isEmpty) return;
              final success = await auth.linkPendingGoogleAccount(password: pwd, expectedUserType: expectedUserType);
              if (success && ctx.mounted) {
                Navigator.pop(ctx);
                onSuccess();
              } else if (auth.error != null && ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(auth.error!)));
                auth.clearError();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Link Account', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      );
    },
  );
}
