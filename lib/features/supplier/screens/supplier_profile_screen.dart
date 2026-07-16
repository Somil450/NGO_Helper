import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/supplier_provider.dart';

class SupplierProfileScreen extends StatefulWidget {
  const SupplierProfileScreen({super.key});

  @override
  State<SupplierProfileScreen> createState() => _SupplierProfileScreenState();
}

class _SupplierProfileScreenState extends State<SupplierProfileScreen> {
  bool _isEditingProfile = false;

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _mobileCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final profile = context.read<SupplierProvider>().profile;
      if (profile != null) {
        _nameCtrl.text = profile.entityName;
        _mobileCtrl.text = profile.contactNumber;
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1024;
    final supplierProvider = context.watch<SupplierProvider>();
    final profile = supplierProvider.profile;
    final email = context.read<AuthProvider>().userModel?.email ?? 'contact@supplier.com';
    
    if (!_isEditingProfile && profile != null) {
      _nameCtrl.text = profile.entityName;
      _mobileCtrl.text = profile.contactNumber;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFEF9EF),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 64.0 : 16.0, vertical: 32.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(),
                const SizedBox(height: 24),
                _buildHeaderCard(profile, email),
                const SizedBox(height: 24),
                _buildSectionHeader(LucideIcons.store, 'Business Information', 'Manage your business details'),
                const SizedBox(height: 16),
                _buildProfileSettings(),
                const SizedBox(height: 32),
                _buildSectionHeader(LucideIcons.lock, 'Security & Access', 'Manage password and authentication'),
                const SizedBox(height: 16),
                _buildSecuritySettings(email),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile',
              style: GoogleFonts.bricolageGrotesque(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF064E3B),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Manage your business profile and preferences',
              style: GoogleFonts.bricolageGrotesque(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        if (_isEditingProfile)
          ElevatedButton.icon(
            onPressed: () async {
              final success = await context.read<SupplierProvider>().updateProfile(_nameCtrl.text, _mobileCtrl.text);
              if (success) {
                setState(() => _isEditingProfile = false);
              }
            },
            icon: const Icon(LucideIcons.check, size: 16),
            label: const Text('Save Changes'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF059669),
              foregroundColor: Colors.white,
              elevation: 2,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              textStyle: GoogleFonts.bricolageGrotesque(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
      ],
    );
  }

  Widget _buildHeaderCard(SupplierProfile? profile, String email) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF9EF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.68)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black.withOpacity(0.05)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                profile?.entityName.isNotEmpty == true ? profile!.entityName[0].toUpperCase() : 'S',
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF059669),
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      profile?.entityName ?? 'Unknown Supplier',
                      style: GoogleFonts.bricolageGrotesque(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF064E3B),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: const Color(0xFF059669).withOpacity(0.2)),
                      ),
                      child: Text(
                        'VERIFIED SUPPLIER',
                        style: GoogleFonts.bricolageGrotesque(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF059669), letterSpacing: 0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(email, style: GoogleFonts.bricolageGrotesque(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[500])),
                const SizedBox(height: 8),
                Text(
                  'Address: ${profile?.address ?? "N/A"}',
                  style: GoogleFonts.bricolageGrotesque(fontSize: 13, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF059669).withOpacity(0.1)),
          ),
          child: Icon(icon, color: const Color(0xFF059669), size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.bricolageGrotesque(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF064E3B))),
            Text(subtitle, style: GoogleFonts.bricolageGrotesque(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey[500])),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileSettings() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFEF9EF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (_isEditingProfile)
            Padding(
              padding: const EdgeInsets.all(24),
              child: _buildEditForm(),
            )
          else ...[
            _buildLockedCard(
              icon: LucideIcons.building,
              label: 'BUSINESS NAME',
              value: _nameCtrl.text.isNotEmpty ? _nameCtrl.text : 'Not provided',
              onUnlock: () => setState(() => _isEditingProfile = true),
            ),
            Divider(height: 1, color: Colors.black.withOpacity(0.05)),
            _buildLockedCard(
              icon: LucideIcons.phone,
              label: 'CONTACT NUMBER',
              value: _mobileCtrl.text.isNotEmpty ? _mobileCtrl.text : 'Not provided',
              onUnlock: () => setState(() => _isEditingProfile = true),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSecuritySettings(String email) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFEF9EF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildLockedCard(
            icon: LucideIcons.mail,
            label: 'EMAIL ADDRESS',
            value: email,
            onUnlock: () {}, // Handled by separate logic if needed
            isReadOnly: true,
          ),
          Divider(height: 1, color: Colors.black.withOpacity(0.05)),
          _buildLockedCard(
            icon: LucideIcons.key,
            label: 'PASSWORD',
            value: '••••••••',
            onUnlock: () {}, // Password reset logic
            customActionLabel: 'Update',
          ),
        ],
      ),
    );
  }

  Widget _buildLockedCard({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onUnlock,
    bool isReadOnly = false,
    String? customActionLabel,
  }) {
    return InkWell(
      onTap: isReadOnly ? null : onUnlock,
      hoverColor: isReadOnly ? Colors.transparent : Colors.black.withOpacity(0.01),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black.withOpacity(0.05)),
              ),
              child: Icon(icon, color: Colors.grey[500], size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.bricolageGrotesque(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: GoogleFonts.bricolageGrotesque(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF064E3B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (!isReadOnly)
              TextButton.icon(
                onPressed: onUnlock,
                icon: Icon(LucideIcons.edit2, size: 14),
                label: Text(customActionLabel ?? 'Edit'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF059669),
                  backgroundColor: const Color(0xFFECFDF5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  textStyle: GoogleFonts.bricolageGrotesque(fontSize: 12, fontWeight: FontWeight.w700),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditForm() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildInput('Business Name', _nameCtrl)),
            const SizedBox(width: 24),
            Expanded(child: _buildInput('Contact Mobile', _mobileCtrl)),
          ],
        ),
      ],
    );
  }

  Widget _buildInput(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.bricolageGrotesque(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF064E3B))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.bricolageGrotesque(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF064E3B)),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF059669))),
          ),
        ),
      ],
    );
  }
}
