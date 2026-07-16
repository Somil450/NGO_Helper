import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/language_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/ngo_provider.dart';
import '../../../core/models/food_post_model.dart';

class NGOSearchScreen extends StatefulWidget {
  const NGOSearchScreen({super.key});

  @override
  State<NGOSearchScreen> createState() => _NGOSearchScreenState();
}

class _NGOSearchScreenState extends State<NGOSearchScreen> {
  String _searchQuery = '';
  String _activeCategory = 'All';
  String _districtFilter = 'All';
  String _dateFilter = 'All';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<NGOProvider>().loadListings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ngoProvider = context.watch<NGOProvider>();
    final _listings = ngoProvider.listings;

    final filteredPosts = _listings.where((post) {
      if (_searchQuery.isNotEmpty) {
        if (!post.category.toLowerCase().contains(_searchQuery.toLowerCase()) &&
            !post.supplierName.toLowerCase().contains(_searchQuery.toLowerCase())) {
          return false;
        }
      }
      if (_activeCategory != 'All' && post.category != _activeCategory) return false;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
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
                    const SizedBox(height: 20),
                    _buildSearchBarAndFilters(isDesktop),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ngoProvider.isLoading 
                          ? Center(child: CircularProgressIndicator(color: AppTheme.primary))
                          : filteredPosts.isEmpty
                              ? _buildEmptyState()
                              : _buildGridView(filteredPosts, isDesktop),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppTheme.deepShadow,
        image: const DecorationImage(
          image: AssetImage('assets/images/Donor.png'),
          fit: BoxFit.cover,
          alignment: Alignment.centerRight,
          opacity: 0.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('FIND DONATIONS', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1.5)),
          ),
          const SizedBox(height: 10),
          Text(
            context.watch<LanguageProvider>().translate('available_donations'),
            style: GoogleFonts.bricolageGrotesque(
              fontSize: isDesktop ? 32 : 26,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.watch<LanguageProvider>().translate('browse_donations_desc'),
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBarAndFilters(bool isDesktop) {
    Widget searchBar = Container(
      width: isDesktop ? 400 : double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: AppTheme.primary.withOpacity(0.25), width: 1.5),
        boxShadow: AppTheme.softShadow,
      ),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          icon: Icon(LucideIcons.search, size: 20, color: AppTheme.primary),
          hintText: context.watch<LanguageProvider>().translate('search_donations'),
          hintStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF94A3B8)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
      ),
    );

    Widget filtersRow = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildFilterDropdown(
            'Date',
            _dateFilter,
            ['All', 'Today', 'Tomorrow', 'This Week'],
            (val) => setState(() => _dateFilter = val!),
          ),
          SizedBox(width: 12),
          _buildFilterDropdown(
            'District',
            _districtFilter,
            ['All', 'Mumbai', 'Pune', 'Nashik'],
            (val) => setState(() => _districtFilter = val!),
          ),
          SizedBox(width: 12),
          _buildFilterDropdown(
            context.watch<LanguageProvider>().translate('category'),
            _activeCategory,
            ['All', 'Cooked Food', 'Raw Food', 'Packaged Food', 'Bakery'],
            (val) => setState(() => _activeCategory = val!),
          ),
        ],
      ),
    );

    if (isDesktop) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          searchBar,
          filtersRow,
        ],
      );
    } else {
      return Column(
        children: [
          searchBar,
          SizedBox(height: 16),
          filtersRow,
        ],
      );
    }
  }

  Widget _buildFilterDropdown(String prefix, String value, List<String> items, ValueChanged<String?> onChanged) {
    final isActive = value != 'All';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFECFDF5) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? const Color(0xFF059669).withOpacity(0.2) : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          if (!isActive)
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: Icon(
            LucideIcons.chevronDown,
            size: 16,
            color: isActive ? const Color(0xFF059669) : Colors.grey[500],
          ),
          style: GoogleFonts.bricolageGrotesque(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isActive ? const Color(0xFF059669) : const Color(0xFF4B5563),
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(16),
          onChanged: onChanged,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item == 'All' ? '$prefix: All' : item,
                style: GoogleFonts.bricolageGrotesque(
                  fontWeight: FontWeight.w600,
                  color: isActive && item == value ? const Color(0xFF059669) : const Color(0xFF064E3B),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildGridView(List<FoodPost> posts, bool isDesktop) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 4 : 1,
        mainAxisSpacing: 24,
        crossAxisSpacing: 24,
        childAspectRatio: isDesktop ? 0.8 : 0.75,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return _DonationCard(post: posts[index]);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.6)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 4))
          ]
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF9EF),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black.withOpacity(0.04)),
              ),
              child: const Icon(LucideIcons.searchX, size: 32, color: Color(0xFF94A3B8)),
            ),
            SizedBox(height: 24),
            Text(
              context.watch<LanguageProvider>().translate('no_donations_found'),
              style: GoogleFonts.bricolageGrotesque(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF064E3B),
              ),
            ),
            SizedBox(height: 8),
            Text(
              context.watch<LanguageProvider>().translate('try_adjusting_search'),
              style: GoogleFonts.bricolageGrotesque(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[500],
              ),
            ),
            SizedBox(height: 32),
            GestureDetector(
              onTap: () {
                setState(() {
                  _searchQuery = '';
                  _activeCategory = 'All';
                  _dateFilter = 'All';
                  _districtFilter = 'All';
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF059669).withOpacity(0.2)),
                ),
                child: Text(
                  context.watch<LanguageProvider>().translate('clear_filters'),
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF059669),
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

class _DonationCard extends StatefulWidget {
  final FoodPost post;

  const _DonationCard({required this.post});

  @override
  State<_DonationCard> createState() => _DonationCardState();
}

class _DonationCardState extends State<_DonationCard> {
  bool _isClaiming = false;

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final ngoProvider = context.read<NGOProvider>();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Image Placeholder
          Container(
            height: 140,
            decoration: const BoxDecoration(
              color: Color(0xFFFEF9EF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(LucideIcons.image, size: 40, color: Colors.grey[300]),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.clock, size: 14, color: Color(0xFFD97706)),
                        SizedBox(width: 6),
                        Text(
                          'Expires in ${post.shelfLife}',
                          style: GoogleFonts.bricolageGrotesque(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFD97706),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    post.category.toUpperCase(),
                    style: GoogleFonts.bricolageGrotesque(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFD97706),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  post.category,
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF064E3B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 16),
                _buildInfoRow(LucideIcons.package, '${post.weightKg}kg (Serves ~${post.mealsCount})', const Color(0xFF059669)),
                SizedBox(height: 10),
                _buildInfoRow(LucideIcons.store, post.supplierName, Colors.grey[600]!),
                SizedBox(height: 10),
                _buildInfoRow(LucideIcons.mapPin, '${post.supplierCity}, ${post.supplierState}', Colors.grey[600]!),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.black.withOpacity(0.04)),
              ),
            ),
            child: ElevatedButton(
              onPressed: _isClaiming ? null : () async {
                setState(() => _isClaiming = true);
                final success = await ngoProvider.claimFood(post);
                setState(() => _isClaiming = false);
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(context.watch<LanguageProvider>().translate('successfully_claimed'), style: GoogleFonts.bricolageGrotesque()),
                    backgroundColor: const Color(0xFF059669),
                  ));
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(ngoProvider.error ?? 'Failed to claim', style: GoogleFonts.bricolageGrotesque()),
                    backgroundColor: Colors.red,
                  ));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isClaiming 
                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(
                    context.watch<LanguageProvider>().translate('claim_donation'),
                    style: GoogleFonts.bricolageGrotesque(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color iconColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF9EF),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
          ),
          child: Icon(icon, size: 14, color: iconColor),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
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
    );
  }
}
