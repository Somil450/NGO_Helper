import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/language_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/ngo_provider.dart';

class NGOHistoryScreen extends StatefulWidget {
  const NGOHistoryScreen({super.key});

  @override
  State<NGOHistoryScreen> createState() => _NGOHistoryScreenState();
}

class _NGOHistoryScreenState extends State<NGOHistoryScreen> {
  String _activeTab = 'All';

  final List<String> _tabs = ['All', 'Claimed', 'Out For Pickup', 'Completed'];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<NGOProvider>().loadClaims();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ngoProvider = context.watch<NGOProvider>();
    final _claims = ngoProvider.claims;

    final filteredClaims = _claims.where((claimData) {
      final claim = claimData['claim'];
      if (_activeTab == 'All') return true;
      if (_activeTab == 'Claimed' && claim['status'] == 'Pending') return true;
      return claim['status'] == _activeTab;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFEF9EF),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 1024;
            
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 64.0 : 16.0,
                vertical: isDesktop ? 32.0 : 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(isDesktop),
                  SizedBox(height: 32),
                  _buildTabs(),
                  SizedBox(height: 32),
                  Expanded(
                    child: filteredClaims.isEmpty
                        ? _buildEmptyState()
                        : _buildGridView(filteredClaims, isDesktop),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (!isDesktop) ...[
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: const Icon(LucideIcons.arrowLeft, size: 24, color: Color(0xFF064E3B)),
              ),
              SizedBox(width: 12),
            ],
            Text(
              context.watch<LanguageProvider>().translate('my_claims_pickups'),
              style: GoogleFonts.bricolageGrotesque(
                fontSize: isDesktop ? 28 : 24,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF064E3B),
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          context.watch<LanguageProvider>().translate('track_manage_claims'),
          style: GoogleFonts.bricolageGrotesque(
            fontSize: isDesktop ? 14 : 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black.withOpacity(0.04), width: 2),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: _tabs.map((tab) {
            final isActive = _activeTab == tab;
            return GestureDetector(
              onTap: () => setState(() => _activeTab = tab),
              child: Container(
                padding: const EdgeInsets.only(bottom: 12, right: 32, left: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isActive ? const Color(0xFF059669) : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  tab,
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 15,
                    fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                    color: isActive ? const Color(0xFF064E3B) : Colors.grey[400],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildGridView(List<Map<String, dynamic>> claims, bool isDesktop) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 3 : 1,
        mainAxisSpacing: 24,
        crossAxisSpacing: 24,
        childAspectRatio: isDesktop ? 1.4 : 1.2,
      ),
      itemCount: claims.length,
      itemBuilder: (context, index) {
        return _ClaimCard(claim: claims[index]);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF9EF),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 4),
            )
          ]
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black.withOpacity(0.05)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(LucideIcons.clipboardList, size: 32, color: Color(0xFF94A3B8)),
            ),
            SizedBox(height: 24),
            Text(
              'No $_activeTab Claims Found',
              style: GoogleFonts.bricolageGrotesque(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF064E3B),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'You don\'t have any claims matching this status yet.',
              style: GoogleFonts.bricolageGrotesque(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF059669),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                'Browse Donations',
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: 14,
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
}

class _ClaimCard extends StatelessWidget {
  final Map<String, dynamic> claim;

  const _ClaimCard({required this.claim});

  @override
  Widget build(BuildContext context) {
    final claimData = claim['claim'];
    final postData = claim['post'];
    final status = claimData['status'] ?? 'Pending';
    Color badgeColor;
    Color badgeBgColor;
    Color dotColor;
    String badgeText;

    if (status == 'Approved' || status == 'Pending') {
      if (claimData['assignedEmployee'] != null) {
        badgeColor = const Color(0xFFD97706);
        badgeBgColor = const Color(0xFFFEF3C7);
        dotColor = const Color(0xFFF59E0B);
        badgeText = 'ASSIGNED';
      } else {
        badgeColor = const Color(0xFF064E3B);
        badgeBgColor = const Color(0xFFDAECCB);
        dotColor = const Color(0xFF415030);
        badgeText = status.toUpperCase();
      }
    } else if (status == 'Out For Pickup') {
      badgeColor = const Color(0xFF1E3A8A);
      badgeBgColor = const Color(0xFFDBEAFE);
      dotColor = const Color(0xFF3B82F6);
      badgeText = 'OUT FOR PICKUP';
    } else {
      badgeColor = const Color(0xFF059669);
      badgeBgColor = const Color(0xFFECFDF5);
      dotColor = const Color(0xFF059669);
      badgeText = 'COMPLETED';
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFEF9EF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.68)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: badgeBgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: dotColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            badgeText,
                            style: GoogleFonts.bricolageGrotesque(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: badgeColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      claimData['timestamp'] != null 
                        ? (() {
                            // Can be Firestore Timestamp or String
                            DateTime? date;
                            if (claimData['timestamp'] is String) {
                               date = DateTime.tryParse(claimData['timestamp']);
                            } else {
                               try {
                                 date = claimData['timestamp'].toDate();
                               } catch (e) {
                                 date = null;
                               }
                            }
                            return date != null ? '${date.day}/${date.month}/${date.year}' : '';
                          })()
                        : 'Unknown Date',
                      style: GoogleFonts.bricolageGrotesque(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  postData['category'] ?? postData['title'] ?? 'Donation',
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF064E3B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black.withOpacity(0.05)),
                      ),
                      child: const Icon(LucideIcons.package, size: 16, color: Color(0xFF6B7280)),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '${postData['weightKg'] ?? postData['quantity'] ?? '10'} kg',
                      style: GoogleFonts.bricolageGrotesque(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4B5563),
                      ),
                    ),
                    SizedBox(width: 24),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black.withOpacity(0.05)),
                      ),
                      child: const Icon(LucideIcons.store, size: 16, color: Color(0xFF6B7280)),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        postData['supplierName'] ?? 'Supplier',
                        style: GoogleFonts.bricolageGrotesque(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF4B5563),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              border: Border(
                top: BorderSide(color: Colors.black.withOpacity(0.04)),
              ),
            ),
            child: Row(
              children: [
                if (status == 'Approved' || status == 'Pending') ...[
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black.withOpacity(0.05)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        context.watch<LanguageProvider>().translate('cancel'),
                        style: GoogleFonts.bricolageGrotesque(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF064E3B),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF064E3B).withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        context.watch<LanguageProvider>().translate('assign_employee'),
                        style: GoogleFonts.bricolageGrotesque(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF059669).withOpacity(0.2)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        context.watch<LanguageProvider>().translate('view_details'),
                        style: GoogleFonts.bricolageGrotesque(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF059669),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
