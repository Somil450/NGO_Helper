import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/language_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/supplier_provider.dart';

class SupplierDashboardView extends StatefulWidget {
  final VoidCallback onOpenMenu;
  final VoidCallback onOpenPostDonation;

  const SupplierDashboardView({
    super.key,
    required this.onOpenMenu,
    required this.onOpenPostDonation,
  });

  @override
  State<SupplierDashboardView> createState() => _SupplierDashboardViewState();
}

class _SupplierDashboardViewState extends State<SupplierDashboardView> {
  final MapController mapController = MapController();
  
  final LatLng _center = const LatLng(19.8450, 74.0000);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 1024;
          
          return Container(
            decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.only(
                  left: isDesktop ? 64.0 : 16.0,
                  right: isDesktop ? 64.0 : 16.0,
                  top: isDesktop ? 32.0 : 16.0,
                  bottom: 120,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(isDesktop).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0),
                    SizedBox(height: isDesktop ? 40 : 24),
                    
                    if (isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(child: _buildStatsGrid(isDesktop, context).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideX(begin: -0.05, end: 0)),
                          const SizedBox(width: 32),
                          _buildActionButtons(isDesktop).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideX(begin: 0.05, end: 0),
                        ],
                      )
                    else ...[
                      _buildStatsGrid(isDesktop, context).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 24),
                      _buildActionButtons(isDesktop).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
                    ],

                    SizedBox(height: isDesktop ? 40 : 24),

                    if (isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildMapSection(isDesktop).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideX(begin: -0.05, end: 0),
                          ),
                          const SizedBox(width: 32),
                          Expanded(
                            flex: 1,
                            child: _buildRecentActivity(isDesktop, context).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideX(begin: 0.05, end: 0),
                          ),
                        ],
                      )
                    else ...[
                      _buildMapSection(isDesktop).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 24),
                      _buildRecentActivity(isDesktop, context).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
                    ]
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppTheme.deepShadow,
        image: const DecorationImage(
          image: AssetImage('assets/images/Donor.png'),
          fit: BoxFit.cover,
          alignment: Alignment.centerRight,
          opacity: 0.18,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('SUPPLIER DASHBOARD', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1.5)),
                ),
                const SizedBox(height: 10),
                Text(
                  _getGreeting() + ', Partner 👋',
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: isDesktop ? 32 : 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  'Manage your drops & track NGO pickups live',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white70),
                ),
              ],
            ),
          ),
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(LucideIcons.bell, size: 22, color: Colors.white),
                Positioned(
                  top: 10, right: 12,
                  child: Container(width: 8, height: 8, decoration: BoxDecoration(color: AppTheme.coral, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(bool isDesktop, BuildContext context) {
    final provider = context.watch<SupplierProvider>();
    final posts = provider.posts;
    
    // Calculate stats
    final totalDrops = posts.length;
    final totalUnits = posts.fold<double>(0, (sum, post) => sum + post.weightKg);
    final activeDrops = posts.where((p) => p.status == 'Available').length;
    final livePickups = posts.where((p) => p.status == 'Claimed').length;
    if (isDesktop) {
      return Row(
        children: [
          Expanded(child: _buildStatCard('Total Drops', '$totalDrops', null, LucideIcons.package, 'Lifetime')),
          SizedBox(width: 24),
          Expanded(child: _buildStatCard('Units Donated', totalUnits.toStringAsFixed(1), 'kg', LucideIcons.trendingUp, 'Total')),
          const SizedBox(width: 24),
          Expanded(child: _buildStatCard('Active Drops', '$activeDrops', null, LucideIcons.truck, context.watch<LanguageProvider>().translate('status_pending'))),
          const SizedBox(width: 24),
          Expanded(child: _buildStatCard('Live Pickups', '$livePickups', null, LucideIcons.mapPin, 'Ongoing')),
        ],
      );
    }

    final isSmallMobile = MediaQuery.of(context).size.width < 450;
    return GridView.count(
      crossAxisCount: isSmallMobile ? 1 : 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: isSmallMobile ? 2.5 : 1.2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard('Total Drops', '$totalDrops', null, LucideIcons.package, 'Lifetime'),
        _buildStatCard('Units Donated', totalUnits.toStringAsFixed(1), 'kg', LucideIcons.trendingUp, 'Total'),
        _buildStatCard('Active Drops', '$activeDrops', null, LucideIcons.truck, context.watch<LanguageProvider>().translate('status_pending')),
        _buildStatCard('Live Pickups', '$livePickups', null, LucideIcons.mapPin, 'Ongoing'),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, String? unit, IconData icon, String trend) {
    final gradients = [AppTheme.stat1Gradient, AppTheme.stat2Gradient, AppTheme.stat3Gradient, AppTheme.stat4Gradient];
    final gradIdx = label.hashCode.abs() % 4;
    return AppTheme.statCard(
      label: label,
      value: value,
      unit: unit,
      icon: icon,
      gradient: gradients[gradIdx],
      badge: trend,
    );
  }



  Widget _buildActionButtons(bool isDesktop) {
    if (isDesktop) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOutlinedButton('Schedule Drop', LucideIcons.calendar),
          const SizedBox(width: 16),
          _buildFilledButton('Post Donation', LucideIcons.plusSquare, widget.onOpenPostDonation),
        ],
      );
    }
    
    return Row(
      children: [
        Expanded(child: _buildOutlinedButton('Schedule', LucideIcons.calendar)),
        const SizedBox(width: 12),
        Expanded(child: _buildFilledButton('Donate', LucideIcons.plusSquare, widget.onOpenPostDonation)),
      ],
    );
  }

  Widget _buildOutlinedButton(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.primary.withOpacity(0.5), width: 1.5),
        borderRadius: BorderRadius.circular(50),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryDark),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilledButton(String text, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(50),
          boxShadow: AppTheme.glowShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection(bool isDesktop) {
    return Container(
      height: isDesktop ? 500 : 350,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: _center,
          initialZoom: 12.5,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.manavseva',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: const LatLng(20.5937, 78.9629),
                width: 40,
                height: 40,
                child: const Icon(Icons.location_on, color: Colors.red, size: 40),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(bool isDesktop, BuildContext context) {
    final provider = context.watch<SupplierProvider>();
    final posts = provider.posts.take(5).toList(); // Show top 5 recent posts

    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF064E3B),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF9EF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  context.watch<LanguageProvider>().translate('view_all'),
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFD97706),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          if (provider.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (posts.isEmpty)
            Center(
              child: Text(
                'No activity yet.',
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            )
          else
            ...posts.map((post) {
              Color badgeColor;
              Color badgeBgColor;
              String statusText = post.status.toUpperCase();
              
              if (post.status == 'Available') {
                badgeColor = const Color(0xFF059669);
                badgeBgColor = const Color(0xFFECFDF5);
              } else if (post.status == 'Claimed') {
                badgeColor = const Color(0xFF1E3A8A);
                badgeBgColor = const Color(0xFFDBEAFE);
                statusText = 'CLAIMED';
              } else {
                badgeColor = const Color(0xFF64748B);
                badgeBgColor = const Color(0xFFF1F5F9);
              }

              // Try to extract initial from special instructions (which has item name)
              String initial = post.category.isNotEmpty ? post.category[0].toUpperCase() : 'F';
              String title = post.category;
              String subtitle = 'Donated ${post.weightKg} kg';
              
              if (post.specialInstructions != null && post.specialInstructions!.contains('Item:')) {
                final match = RegExp(r'Item:\s*([^.]+)').firstMatch(post.specialInstructions!);
                if (match != null && match.group(1)!.isNotEmpty) {
                  title = match.group(1)!;
                  initial = title[0].toUpperCase();
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: _ActivityListTile(
                  title: title,
                  subtitle: subtitle,
                  time: _timeAgo(post.createdAt),
                  initial: initial,
                  badgeText: statusText,
                  badgeColor: badgeColor,
                  badgeBgColor: badgeBgColor,
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }
}

class _ActivityListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final String initial;
  final String badgeText;
  final Color badgeColor;
  final Color badgeBgColor;

  const _ActivityListTile({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.initial,
    required this.badgeText,
    required this.badgeColor,
    required this.badgeBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFFEF9EF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black.withOpacity(0.04)),
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: GoogleFonts.bricolageGrotesque(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFD97706),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.bricolageGrotesque(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF064E3B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    time,
                    style: GoogleFonts.bricolageGrotesque(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badgeText,
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: badgeColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
