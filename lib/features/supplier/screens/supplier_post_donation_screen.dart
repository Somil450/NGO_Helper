import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/language_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/supplier_provider.dart';

class SupplierPostDonationScreen extends StatefulWidget {
  final VoidCallback onPostSuccess;
  const SupplierPostDonationScreen({super.key, required this.onPostSuccess});

  @override
  State<SupplierPostDonationScreen> createState() => _SupplierPostDonationScreenState();
}

class _SupplierPostDonationScreenState extends State<SupplierPostDonationScreen> {
  String _selectedCategory = 'Prepared Meal';
  final _categories = ['Prepared Meal', 'Dairy', 'Meat/Protein', 'Bakery/Grains', 'Produce'];

  final _itemNameController = TextEditingController();
  final _weightController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _itemNameController.dispose();
    _weightController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.watch<LanguageProvider>().translate('post_donation_title'),
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF111111),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Upload placeholder
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE7E7E7), style: BorderStyle.solid),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.add_photo_alternate, color: Color(0xFF059669), size: 32),
                  ),
                  SizedBox(height: 12),
                  Text(
                    context.watch<LanguageProvider>().translate('upload_photo'),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF059669),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    context.watch<LanguageProvider>().translate('show_food_donating'),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Category
            Text(
              context.watch<LanguageProvider>().translate('category'),
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111111),
              ),
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF059669) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: isSelected ? null : Border.all(color: const Color(0xFFE7E7E7)),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF059669).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : null,
                    ),
                    child: Text(
                      cat,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : const Color(0xFF111111),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 24),

            // Item Name
            _buildInputField('Item Name', 'e.g. 50 Loaves of Bread', _itemNameController),
            SizedBox(height: 16),
            
            // Weight
            _buildInputField('Estimated Weight', 'e.g. 10 kg', _weightController),
            SizedBox(height: 16),
            
            // Pickup Window
            Row(
              children: [
                Expanded(child: _buildInputField('Start Time', '12:00 PM', _startTimeController)),
                SizedBox(width: 16),
                Expanded(child: _buildInputField('End Time', '02:00 PM', _endTimeController)),
              ],
            ),
            SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () async {
                  if (_itemNameController.text.isEmpty || _weightController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.watch<LanguageProvider>().translate('please_fill_fields'))));
                    return;
                  }
                  
                  setState(() => _isLoading = true);
                  
                  // Parse weight
                  double weight = 0;
                  try {
                     weight = double.parse(_weightController.text.replaceAll(RegExp(r'[^0-9.]'), ''));
                  } catch (e) {
                     weight = 10;
                  }

                  final provider = context.read<SupplierProvider>();
                  final success = await provider.createFoodPost(
                    weightKg: weight,
                    hasPackaging: true,
                    pickupAddress: provider.profile?.address ?? '123 default st',
                    shelfLife: '1 Day',
                    category: _selectedCategory,
                    pickupDeadline: DateTime.now().add(const Duration(hours: 4)),
                    contactName: provider.profile?.entityName ?? 'Supplier',
                    contactPhone: provider.profile?.contactNumber ?? '9999999999',
                    specialInstructions: 'Item: ${_itemNameController.text}. Time: ${_startTimeController.text} to ${_endTimeController.text}',
                  );
                  
                  if (mounted) {
                    setState(() => _isLoading = false);
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.watch<LanguageProvider>().translate('donation_posted'))));
                      widget.onPostSuccess();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.error ?? 'Failed to post donation')));
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        context.watch<LanguageProvider>().translate('post_donation_title'),
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111111),
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: Colors.grey[400], fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}
