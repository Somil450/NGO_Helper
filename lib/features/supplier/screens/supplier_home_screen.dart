import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import 'supplier_dashboard_view.dart';
import 'supplier_post_donation_screen.dart';
import 'supplier_history_screen.dart';
import 'supplier_profile_screen.dart';

class SupplierHomeScreen extends StatefulWidget {
  final VoidCallback onOpenMenu;

  const SupplierHomeScreen({
    super.key,
    required this.onOpenMenu,
  });

  @override
  State<SupplierHomeScreen> createState() => _SupplierHomeScreenState();
}

class _SupplierHomeScreenState extends State<SupplierHomeScreen> {
  int _currentIndex = 0;

  final List<_NavItem> _navItems = const [
    _NavItem(icon: LucideIcons.layoutDashboard, label: 'Home'),
    _NavItem(icon: LucideIcons.plusCircle, label: 'Post'),
    _NavItem(icon: LucideIcons.history, label: 'History'),
    _NavItem(icon: LucideIcons.user, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 1024;
        return Scaffold(
          backgroundColor: AppTheme.background,
          extendBody: true,
          bottomNavigationBar: isDesktop ? null : _buildFloatingBottomNav(),
          body: Container(
            decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  if (isDesktop) _buildDesktopSidebar(),
                  Expanded(
                    child: IndexedStack(
                      index: _currentIndex,
                      children: [
                        SupplierDashboardView(
                          onOpenMenu: widget.onOpenMenu,
                          onOpenPostDonation: () => setState(() => _currentIndex = 1),
                        ),
                        SupplierPostDonationScreen(
                          onPostSuccess: () => setState(() => _currentIndex = 0),
                        ),
                        const SupplierHistoryScreen(),
                        const SupplierProfileScreen(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingBottomNav() {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          gradient: AppTheme.heroGradient,
          borderRadius: BorderRadius.circular(36),
          boxShadow: AppTheme.floatShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_navItems.length, (index) {
            final item = _navItems[index];
            final isActive = _currentIndex == index;
            return GestureDetector(
              onTap: () => setState(() => _currentIndex = index),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white.withOpacity(0.2) : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item.icon, size: 22, color: isActive ? Colors.white : Colors.white.withOpacity(0.55)),
                    if (isActive) ...[
                      const SizedBox(height: 3),
                      Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                    ],
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildDesktopSidebar() {
    final lang = context.watch<LanguageProvider>();
    return Container(
      width: 280,
      decoration: const BoxDecoration(
        gradient: AppTheme.heroGradient,
        boxShadow: [BoxShadow(color: Color(0x40064E3B), blurRadius: 40, offset: Offset(8, 0))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.12))),
            ),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppTheme.glowShadow),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset('assets/images/logo.png', errorBuilder: (c, e, s) => const Icon(Icons.store, color: Color(0xFF00C98B), size: 28)),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ManavSeva', style: GoogleFonts.bricolageGrotesque(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.3), borderRadius: BorderRadius.circular(8)),
                      child: Text('SUPPLIER PORTAL', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1.2)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildSidebarItem(LucideIcons.layoutDashboard, lang.translate('dashboard'), 0),
                  _buildSidebarItem(LucideIcons.plusCircle, 'Post Donation', 1),
                  _buildSidebarItem(LucideIcons.history, lang.translate('history'), 2),
                  _buildSidebarItem(LucideIcons.user, 'Profile', 3),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.read<AuthProvider>().signOut(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.logOut, size: 18, color: Color(0xFFFF6B6B)),
                          const SizedBox(width: 12),
                          Text(lang.translate('sign_out'), style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFFFF6B6B))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(gradient: AppTheme.primaryGradient, shape: BoxShape.circle),
                  child: Center(child: Text('T', style: GoogleFonts.bricolageGrotesque(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TC Hunter', style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                      Text('Supplier', style: GoogleFonts.inter(color: Colors.white60, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String label, int index) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withOpacity(0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isActive ? Border.all(color: Colors.white.withOpacity(0.25)) : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: isActive ? Colors.white : Colors.white60),
            const SizedBox(width: 14),
            Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: isActive ? FontWeight.w700 : FontWeight.w500, color: isActive ? Colors.white : Colors.white60)),
            if (isActive) ...[
              const Spacer(),
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
            ],
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
