import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/language_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/ngo_provider.dart';

class NGODashboardView extends StatefulWidget {
  final VoidCallback onOpenMenu;
  final VoidCallback onOpenHistory;
  final VoidCallback onOpenMap;

  const NGODashboardView({
    super.key,
    required this.onOpenMenu,
    required this.onOpenHistory,
    required this.onOpenMap,
  });

  @override
  State<NGODashboardView> createState() => _NGODashboardViewState();
}

class _NGODashboardViewState extends State<NGODashboardView> {
  final MapController mapController = MapController();
  bool _isHindi = false;
  
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
                  left: isDesktop ? 32.0 : 16.0,
                  right: isDesktop ? 32.0 : 16.0,
                  top: isDesktop ? 32.0 : 16.0,
                  bottom: 120,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(isDesktop).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0),
                    SizedBox(height: isDesktop ? 32 : 24),
                    _buildStatsGrid(isDesktop).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
                    SizedBox(height: isDesktop ? 32 : 24),
                    if (isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: _buildMapSection(isDesktop).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideX(begin: -0.05, end: 0)),
                          const SizedBox(width: 24),
                          Expanded(flex: 1, child: _buildSidebar(isDesktop, context).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideX(begin: 0.05, end: 0)),
                        ],
                      )
                    else ...[
                      _buildMapSection(isDesktop).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 24),
                      _buildSidebar(isDesktop, context).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
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
          image: AssetImage('assets/images/Ngo.png'),
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
                  child: Text('NGO DASHBOARD', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1.5)),
                ),
                const SizedBox(height: 10),
                Text(
                  _getGreeting() + ' 👋',
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
                  'Manage claims & track nearby surplus',
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


  Widget _buildStatsGrid(bool isDesktop) {
    return Builder(builder: (context) {
      final provider = context.watch<NGOProvider>();
      final listings = provider.listings;
      final totalListings = listings.length;
      final totalWeight = listings.fold<double>(0, (sum, post) => sum + post.weightKg);

      if (isDesktop) {
        return Row(
          children: [
            Expanded(child: _buildStatCard('Available Pickups', '$totalListings', null, LucideIcons.truck, 'Live')),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard('Available Weight', totalWeight.toStringAsFixed(1), 'kg', LucideIcons.packageCheck, 'Ready')),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard('Units Claimed', '0', 'kg', LucideIcons.shoppingBag, 'Total')),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard('Network Partners', '1', null, LucideIcons.users, 'Active')),
          ],
        );
      }

      final isSmallMobile = MediaQuery.of(context).size.width < 450;
      return GridView.count(
        crossAxisCount: isSmallMobile ? 1 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: isSmallMobile ? 2.5 : 1.4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildStatCard('Available Pickups', '$totalListings', null, LucideIcons.truck, 'Live'),
          _buildStatCard('Available Weight', totalWeight.toStringAsFixed(1), 'kg', LucideIcons.packageCheck, 'Ready'),
          _buildStatCard('Units Claimed', '0', 'kg', LucideIcons.shoppingBag, 'Total'),
          _buildStatCard('Partners', '1', null, LucideIcons.users, 'Active'),
        ],
      );
    });
  }

  Widget _buildStatCard(String label, String value, String? unit, IconData icon, String trend) {
    // Pick gradient based on icon/label
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

  Widget _buildMapSection(bool isDesktop) {
    return Container(
      height: isDesktop ? 500 : 350,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          FlutterMap(
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
                    point: const LatLng(19.8450, 74.0000),
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF064E3B),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        'Live Drops',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        'My Pickups',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF4B5563),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(bool isDesktop, BuildContext context) {
    final provider = context.watch<NGOProvider>();
    final listings = provider.listings.take(5).toList();

    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.02)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
                'Nearby Surplus',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111111),
                ),
              ),
              GestureDetector(
                onTap: widget.onOpenMap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    context.watch<LanguageProvider>().translate('view_all'),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF059669),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (provider.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (listings.isEmpty)
            Center(
              child: Text(
                'No surplus available near you.',
                style: GoogleFonts.inter(color: Colors.grey[600]),
              ),
            )
          else
            ...listings.map((post) {
              String initial = post.category.isNotEmpty ? post.category[0].toUpperCase() : 'S';
              String title = post.category;
              if (post.specialInstructions != null && post.specialInstructions!.contains('Item:')) {
                final match = RegExp(r'Item:\s*([^.]+)').firstMatch(post.specialInstructions!);
                if (match != null && match.group(1)!.isNotEmpty) {
                  title = match.group(1)!;
                  initial = title[0].toUpperCase();
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _SurplusListTile(
                  title: title,
                  weight: '${post.weightKg} kg',
                  distance: 'Nearby',
                  initial: initial,
                ),
              );
            }).toList(),
        ],
      ),
    );
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

class _SurplusListTile extends StatelessWidget {
  final String title;
  final String weight;
  final String distance;
  final String initial;

  const _SurplusListTile({
    required this.title,
    required this.weight,
    required this.distance,
    required this.initial,
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
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF4B5563),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                weight,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF059669),
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, size: 12, color: Color(0xFF94A3B8)),
                const SizedBox(width: 4),
                Text(
                  distance,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'ASAP',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF059669),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
