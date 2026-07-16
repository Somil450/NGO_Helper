import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../core/models/user_model.dart';
import '../../../core/models/food_post_model.dart';
import '../../../core/services/token_service.dart';
import '../../../core/constants/app_constants.dart';

class NGOProvider extends ChangeNotifier {
  NGOProfile? _profile;
  List<FoodPost> _listings = [];
  List<Map<String, dynamic>> _claims = [];
  List<Map<String, dynamic>> _employees = [];
  bool _isLoading = false;
  String? _error;

  NGOProfile? get profile => _profile;
  List<FoodPost> get listings => _listings;
  List<Map<String, dynamic>> get claims => _claims;
  List<Map<String, dynamic>> get employees => _employees;
  bool get isLoading => _isLoading;
  String? get error => _error;

  NGOProvider() {
    _init();
  }

  void _init() {
    if (TokenService.hasToken()) {
      loadProfile();
      loadListings();
      loadClaims();
    }
  }

  Future<void> loadProfile() async {
    final token = TokenService.getToken();
    if (token == null) return;

    _setLoading(true);
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ngoDetails'] != null) {
          final ngoData = data['ngoDetails'] as Map<String, dynamic>;
          _profile = NGOProfile(
            uid: data['_id'] ?? '',
            ngoName: ngoData['name'] ?? ngoData['ngoName'] ?? '',
            missionStatement: ngoData['missionStatement'] ?? ngoData['mission'] ?? '',
            address: ngoData['address'] ?? '',
            city: ngoData['city'] ?? '',
            state: ngoData['state'] ?? '',
            mobileNumber: ngoData['mobile'] ?? ngoData['mobileNumber'] ?? '',
            website: ngoData['website'],
          );
        }
      }
    } catch (e) {
      debugPrint('Error loading NGO profile: $e');
    }
    _setLoading(false);
  }

  Future<void> loadListings() async {
    final token = TokenService.getToken();
    if (token == null) return;

    _setLoading(true);
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/posts'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> listingsJson = jsonDecode(response.body);
        _listings = listingsJson.map((json) => FoodPost.fromJson(json)).toList();
        _listings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } else {
        _error = 'Failed to load listings';
      }
    } catch (e) {
      _error = 'Failed to load listings: $e';
    }
    _setLoading(false);
  }

  Future<bool> claimFood(FoodPost post) async {
    final token = TokenService.getToken();
    if (_profile == null || token == null) return false;

    _setLoading(true);
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/posts/${post.id}/claim'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'notes': 'Requested by ${_profile!.ngoName}',
        }),
      );

      if (response.statusCode == 200) {
        await loadListings();
        await loadClaims();
        _setLoading(false);
        return true;
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Failed to claim food.';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Network error: $e';
      _setLoading(false);
      return false;
    }
  }

  Future<void> loadClaims() async {
    final token = TokenService.getToken();
    if (token == null) return;

    _setLoading(true);
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/posts/ngo/my-claims'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> claimsJson = jsonDecode(response.body);
        final List<Map<String, dynamic>> mappedClaims = [];

        for (var c in claimsJson) {
          // Reconstruct the expected 'post' and 'claim' keys on UI side
          mappedClaims.add({
            'post': {
              '_id': c['id'] ?? '',
              'supplierName': c['supplier'] ?? 'Supplier',
              'itemName': c['itemName'] ?? '',
              'category': c['category'] ?? '',
              'weight': (c['weight'] ?? 0).toDouble(),
              'pickupAddress': c['address'] ?? '',
              'pickupDate': c['date'] ?? '',
              'lat': c['pickupLat'],
              'lng': c['pickupLng'],
              'status': c['status'] == 'Completed' ? 'Claimed' : 'Available',
            },
            'claim': {
              '_id': c['claimId'] ?? '',
              'ngoId': _profile?.uid ?? '',
              'ngoName': _profile?.ngoName ?? '',
              'status': c['status'] ?? 'Pending',
              'timestamp': c['date'] ?? '',
              'notes': '',
            }
          });
        }
        _claims = mappedClaims;
      }
    } catch (e) {
      debugPrint('Error loading claims: $e');
    }
    _setLoading(false);
  }

  Future<void> loadEmployees() async {
    final token = TokenService.getToken();
    if (token == null) return;

    _setLoading(true);
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/employees'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> employeesJson = jsonDecode(response.body);
        _employees = employeesJson.map((e) => e as Map<String, dynamic>).toList();
      }
    } catch (e) {
      debugPrint('Error loading employees: $e');
    }
    _setLoading(false);
  }

  Future<bool> addEmployee(String name, String email, String mobile, String password) async {
    final token = TokenService.getToken();
    if (token == null) return false;

    _setLoading(true);
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/employees'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'mobile': mobile,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        await loadEmployees();
        _setLoading(false);
        return true;
      }
    } catch (e) {
      debugPrint('Error adding employee: $e');
    }
    _setLoading(false);
    return false;
  }

  Future<bool> updateProfile(String name, String mobile, String missionStatement) async {
    final token = TokenService.getToken();
    if (token == null) return false;

    _setLoading(true);
    try {
      final response = await http.put(
        Uri.parse('${AppConstants.apiBaseUrl}/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'details': {
            'name': name,
            'ngoName': name,
            'mobile': mobile,
            'mobileNumber': mobile,
            'missionStatement': missionStatement,
          }
        }),
      );

      if (response.statusCode == 200) {
        await loadProfile();
        _setLoading(false);
        return true;
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
    }
    _setLoading(false);
    return false;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
