import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../core/models/user_model.dart';
import '../../../core/models/food_post_model.dart';
import '../../../core/services/token_service.dart';
import '../../../core/constants/app_constants.dart';

class SupplierProvider extends ChangeNotifier {
  SupplierProfile? _profile;
  List<FoodPost> _posts = [];
  List<ScheduledPost> _scheduledPosts = [];
  bool _isLoading = false;
  String? _error;

  SupplierProfile? get profile => _profile;
  List<FoodPost> get posts => _posts;
  List<ScheduledPost> get scheduledPosts => _scheduledPosts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  SupplierProvider() {
    _init();
  }

  void _init() {
    // If already logged in, load data
    if (TokenService.hasToken()) {
      loadProfile();
      loadPosts();
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
        if (data['supplierDetails'] != null) {
          final supplierData = data['supplierDetails'] as Map<String, dynamic>;
          _profile = SupplierProfile(
            uid: data['_id'] ?? '',
            businessType: supplierData['businessType'] ?? '',
            entityName: supplierData['legalName'] ?? supplierData['entityName'] ?? '',
            address: supplierData['address'] ?? '',
            city: supplierData['city'] ?? '',
            state: supplierData['state'] ?? '',
            contactNumber: supplierData['mobile'] ?? supplierData['contactNumber'] ?? '',
            website: supplierData['website'],
          );
        }
      }
    } catch (e) {
      _error = 'Failed to load profile';
    }
    _setLoading(false);
  }

  Future<bool> updateProfile(String name, String mobile) async {
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
            'legalName': name,
            'entityName': name,
            'mobile': mobile,
            'contactNumber': mobile,
          }
        }),
      );

      if (response.statusCode == 200) {
        await loadProfile();
        return true;
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
    }
    _setLoading(false);
    return false;
  }

  Future<void> loadPosts() async {
    final token = TokenService.getToken();
    if (token == null) return;

    _setLoading(true);
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/posts/supplier'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> allPostsJson = jsonDecode(response.body);

        _posts = allPostsJson
            .where((json) => json['type'] != 'Scheduled')
            .map((json) => FoodPost.fromJson(json))
            .toList();

        _scheduledPosts = allPostsJson
            .where((json) => json['type'] == 'Scheduled')
            .map((json) => ScheduledPost.fromJson(json))
            .toList();
            
        // Sort posts by creation date descending
        _posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } else {
        _error = 'Failed to load posts';
      }
    } catch (e) {
      _error = 'Failed to load posts';
      debugPrint('Error loading posts: $e');
    }
    _setLoading(false);
  }

  Future<void> loadScheduledPosts() async {
    await loadPosts();
  }

  Future<bool> createFoodPost({
    required double weightKg,
    required bool hasPackaging,
    required String pickupAddress,
    required String shelfLife,
    required String category,
    File? imageFile,
    required DateTime pickupDeadline,
    required String contactName,
    required String contactPhone,
    String? specialInstructions,
  }) async {
    final token = TokenService.getToken();
    if (_profile == null || token == null) return false;

    _setLoading(true);
    try {
      // Extract item name from special instructions if it follows UI standard: "Item: XXX. Time: YYY"
      String itemName = category;
      if (specialInstructions != null && specialInstructions.startsWith('Item: ')) {
        final endIdx = specialInstructions.indexOf('. Time: ');
        if (endIdx != -1) {
          itemName = specialInstructions.substring(6, endIdx);
        } else {
          itemName = specialInstructions.substring(6);
        }
      }

      var request = http.MultipartRequest('POST', Uri.parse('${AppConstants.apiBaseUrl}/posts'));
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['type'] = 'OneTime';
      request.fields['weight'] = weightKg.toString();
      request.fields['packaging'] = hasPackaging.toString(); // passes Boolean as string "true" or "false"
      request.fields['pickupAddress'] = pickupAddress;
      request.fields['city'] = _profile!.city;
      request.fields['district'] = _profile!.city; // default district to city to satisfy backend required validator
      request.fields['state'] = _profile!.state;
      request.fields['shelfLife'] = shelfLife;
      request.fields['category'] = category;
      request.fields['itemName'] = itemName;
      request.fields['pickupDate'] = pickupDeadline.toIso8601String();
      request.fields['contactName'] = contactName;
      request.fields['contactPhone'] = contactPhone;
      if (specialInstructions != null) {
        request.fields['specialInstructions'] = specialInstructions;
      }

      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        await loadPosts();
        _setLoading(false);
        return true;
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Failed to create post. Please try again.';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Failed to create post. Please try again.';
      debugPrint('Error creating post: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> createScheduledPost({
    required double weightKg,
    required bool hasPackaging,
    required String pickupAddress,
    required String shelfLife,
    required String category,
    required String contactName,
    required String contactPhone,
    String? specialInstructions,
    required Map<String, DaySchedule> schedule,
  }) async {
    final token = TokenService.getToken();
    if (_profile == null || token == null) return false;

    _setLoading(true);
    try {
      final scheduleArray = schedule.entries.map((e) => {
        'day': e.key,
        'isActive': e.value.isEnabled,
        'postTime': e.value.postingTime,
        'deadlineTime': e.value.pickupDeadline,
      }).toList();

      String itemName = category;
      if (specialInstructions != null && specialInstructions.startsWith('Item: ')) {
        final endIdx = specialInstructions.indexOf('. Time: ');
        if (endIdx != -1) {
          itemName = specialInstructions.substring(6, endIdx);
        } else {
          itemName = specialInstructions.substring(6);
        }
      }

      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/posts'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'type': 'Scheduled',
          'weight': weightKg,
          'packaging': hasPackaging,
          'pickupAddress': pickupAddress,
          'city': _profile!.city,
          'district': _profile!.city,
          'state': _profile!.state,
          'shelfLife': shelfLife,
          'category': category,
          'itemName': itemName,
          'contactName': contactName,
          'contactPhone': contactPhone,
          'specialInstructions': specialInstructions ?? '',
          'scheduledDays': scheduleArray,
        }),
      );

      if (response.statusCode == 201) {
        await loadPosts();
        _setLoading(false);
        return true;
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Failed to schedule posts.';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Failed to schedule posts. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  Future<void> updatePostStatus(String postId, String newStatus) async {
    final token = TokenService.getToken();
    if (token == null) return;

    try {
      final response = await http.put(
        Uri.parse('${AppConstants.apiBaseUrl}/posts/$postId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': newStatus}),
      );

      if (response.statusCode == 200) {
        await loadPosts();
      } else {
        _error = 'Failed to update status';
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update status';
      notifyListeners();
    }
  }

  Future<void> approveClaim(String postId, String claimId, String ngoId, String ngoName) async {
    final token = TokenService.getToken();
    if (token == null) return;

    try {
      final response = await http.put(
        Uri.parse('${AppConstants.apiBaseUrl}/posts/$postId/claim/manage'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'claimId': claimId,
          'status': 'Approved',
        }),
      );

      if (response.statusCode == 200) {
        await loadPosts();
      } else {
        _error = 'Failed to approve claim';
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to approve claim';
      notifyListeners();
    }
  }

  Future<void> rejectClaim(String claimId) async {
    _error = 'Reject claim requires postId parameter update';
    notifyListeners();
  }

  Stream<List<ClaimRequest>> claimsForPost(String postId) async* {
    // Return a stream that polls or gets the claim requests for a post
    final token = TokenService.getToken();
    if (token == null) {
      yield [];
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/posts/$postId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final postJson = jsonDecode(response.body);
        if (postJson['claims'] != null) {
          final List<dynamic> claimsJson = postJson['claims'];
          final claims = claimsJson.map((c) => ClaimRequest(
            id: c['_id'] ?? '',
            postId: postId,
            ngoId: c['ngoId'] is Map ? c['ngoId']['_id'] : (c['ngoId'] ?? ''),
            ngoName: c['ngoName'] ?? '',
            ngoPhone: c['ngoPhone'] ?? '',
            status: c['status'] ?? 'Pending',
            createdAt: c['createdAt'] != null ? DateTime.parse(c['createdAt']) : DateTime.now(),
          )).toList();
          yield claims;
        } else {
          yield [];
        }
      } else {
        yield [];
      }
    } catch (e) {
      yield [];
    }
  }

  Future<FoodPost?> getPostById(String postId) async {
    final token = TokenService.getToken();
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/posts/$postId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return FoodPost.fromJson(data);
      }
    } catch (e) {
      debugPrint('Error fetching post: $e');
    }
    return null;
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
