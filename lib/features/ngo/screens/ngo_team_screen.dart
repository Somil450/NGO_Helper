import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/language_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/ngo_provider.dart';

class NGOTeamScreen extends StatefulWidget {
  const NGOTeamScreen({super.key});

  @override
  State<NGOTeamScreen> createState() => _NGOTeamScreenState();
}

class _NGOTeamScreenState extends State<NGOTeamScreen> {
  bool _showAddForm = false;
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _mobileCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<NGOProvider>().loadEmployees();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _mobileCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ngoProvider = context.watch<NGOProvider>();
    final _employees = ngoProvider.employees;

    return Scaffold(
      backgroundColor: const Color(0xFFFEF9EF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(),
              SizedBox(height: 24),
              if (_showAddForm) ...[
                _buildAddForm(),
                SizedBox(height: 24),
              ],
              _buildEmployeesTable(_employees),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 16,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.watch<LanguageProvider>().translate('team_members'),
              style: GoogleFonts.bricolageGrotesque(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF064E3B),
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 4),
            Text(
              context.watch<LanguageProvider>().translate('manage_team'),
              style: GoogleFonts.bricolageGrotesque(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => setState(() => _showAddForm = !_showAddForm),
          icon: Icon(_showAddForm ? LucideIcons.x : LucideIcons.plus, size: 16),
          label: Text(_showAddForm ? context.watch<LanguageProvider>().translate('cancel') : 'Add Employee'),
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

  Widget _buildAddForm() {
    return Container(
      padding: const EdgeInsets.all(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF059669).withOpacity(0.1)),
                ),
                child: const Icon(LucideIcons.userPlus, color: Color(0xFF059669), size: 20),
              ),
              SizedBox(width: 16),
              Text(
                context.watch<LanguageProvider>().translate('add_new_employee'),
                style: GoogleFonts.bricolageGrotesque(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF064E3B)),
              ),
            ],
          ),
          SizedBox(height: 24),
              Column(
                children: [
                  _buildInput('Full Name', 'John Doe', _nameCtrl),
                  SizedBox(height: 16),
                  _buildInput('Email Address', 'john@ngo.org', _emailCtrl),
                  SizedBox(height: 16),
                  _buildInput('Mobile Number', '+91 9876543210', _mobileCtrl),
                  SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Password', style: GoogleFonts.bricolageGrotesque(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF064E3B))),
                      SizedBox(height: 8),
                      Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey[200]!),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: TextField(
                                  controller: _passwordCtrl,
                                  obscureText: true,
                                  style: GoogleFonts.bricolageGrotesque(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF064E3B)),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: '••••••••',
                                    hintStyle: GoogleFonts.bricolageGrotesque(fontSize: 14, color: Colors.grey[400]),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.all(4),
                              decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(12)),
                              child: IconButton(icon: const Icon(LucideIcons.refreshCw, size: 18), onPressed: () {}, color: const Color(0xFF059669)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () async {
                final success = await context.read<NGOProvider>().addEmployee(_nameCtrl.text, _emailCtrl.text, _mobileCtrl.text, _passwordCtrl.text);
                if (success) {
                  setState(() {
                    _showAddForm = false;
                    _nameCtrl.clear();
                    _emailCtrl.clear();
                    _mobileCtrl.clear();
                    _passwordCtrl.clear();
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                foregroundColor: Colors.white,
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: GoogleFonts.bricolageGrotesque(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              child: Text(context.watch<LanguageProvider>().translate('create_employee_account')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.bricolageGrotesque(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF064E3B))),
        SizedBox(height: 8),
        SizedBox(
          height: 52,
          child: TextField(
            controller: controller,
            style: GoogleFonts.bricolageGrotesque(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF064E3B)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.bricolageGrotesque(fontSize: 14, color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF059669))),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmployeesTable(List<Map<String, dynamic>> employees) {
    if (employees.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Icon(LucideIcons.users, size: 48, color: Colors.grey[300]),
            SizedBox(height: 16),
            Text(context.watch<LanguageProvider>().translate('no_employees_found'), style: GoogleFonts.bricolageGrotesque(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF064E3B))),
            SizedBox(height: 8),
            Text(context.watch<LanguageProvider>().translate('add_team_members'), style: GoogleFonts.bricolageGrotesque(fontSize: 14, color: Colors.grey[500])),
          ],
        ),
      );
    }

    return Column(
      children: employees.map((emp) {
        final date = DateTime.tryParse(emp['createdAt'] ?? '') ?? DateTime.now();
        final formattedDate = '${date.day}/${date.month}/${date.year}';
        final isActive = emp['isActive'] == true;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        (emp['name'] as String?)?.isNotEmpty == true ? (emp['name'] as String)[0].toUpperCase() : 'E',
                        style: GoogleFonts.bricolageGrotesque(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF059669)),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(emp['name'] ?? 'Unknown', style: GoogleFonts.bricolageGrotesque(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF064E3B)), overflow: TextOverflow.ellipsis),
                        SizedBox(height: 4),
                        Text(emp['email'] ?? '', style: GoogleFonts.bricolageGrotesque(fontSize: 13, color: Colors.grey[500]), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.moreVertical, size: 20, color: Colors.grey),
                    onPressed: () {},
                  ),
                ],
              ),
              SizedBox(height: 16),
              Divider(color: Colors.grey[100]),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.watch<LanguageProvider>().translate('mobile').toUpperCase(), style: GoogleFonts.bricolageGrotesque(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey[400])),
                      SizedBox(height: 4),
                      Text(emp['mobile'] ?? '', style: GoogleFonts.bricolageGrotesque(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF064E3B))),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isActive ? 'ACTIVE' : 'INACTIVE',
                      style: GoogleFonts.bricolageGrotesque(fontSize: 11, fontWeight: FontWeight.w800, color: isActive ? const Color(0xFF059669) : Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
