import 'package:cloud_firestore/cloud_firestore.dart';

class FoodPost {
  final String id;
  final String supplierId;
  final String supplierName;
  final String supplierCity;
  final String supplierState;
  final double weightKg;
  final bool hasPackaging;
  final String pickupAddress;
  final String shelfLife;
  final String category;
  final String? imageUrl;
  final DateTime pickupDeadline;
  final String contactName;
  final String contactPhone;
  final String? specialInstructions;
  final String status; // active, claimed, expired
  final bool isScheduled;
  final DateTime createdAt;
  final String? claimedByNgoId;
  final String? claimedByNgoName;

  const FoodPost({
    required this.id,
    required this.supplierId,
    required this.supplierName,
    required this.supplierCity,
    required this.supplierState,
    required this.weightKg,
    required this.hasPackaging,
    required this.pickupAddress,
    required this.shelfLife,
    required this.category,
    this.imageUrl,
    required this.pickupDeadline,
    required this.contactName,
    required this.contactPhone,
    this.specialInstructions,
    required this.status,
    this.isScheduled = false,
    required this.createdAt,
    this.claimedByNgoId,
    this.claimedByNgoName,
  });

  int get mealsCount => (weightKg * 1000 / 400).floor();

  factory FoodPost.fromJson(Map<String, dynamic> json) {
    return FoodPost(
      id: json['_id'] ?? '',
      supplierId: json['supplierId'] is Map ? json['supplierId']['_id'] : (json['supplierId'] ?? ''),
      supplierName: json['supplierId'] is Map ? (json['supplierId']['supplierDetails']?['legalName'] ?? '') : '',
      supplierCity: json['city'] ?? '',
      supplierState: json['state'] ?? '',
      weightKg: (json['weight'] ?? 0).toDouble(),
      hasPackaging: json['packaging'] == 'Packaged',
      pickupAddress: json['pickupAddress'] ?? '',
      shelfLife: json['shelfLife'] ?? '',
      category: json['category'] ?? '',
      imageUrl: json['image'],
      pickupDeadline: json['pickupDate'] != null ? DateTime.parse(json['pickupDate']) : DateTime.now(),
      contactName: json['contactName'] ?? '',
      contactPhone: json['contactPhone'] ?? '',
      specialInstructions: json['specialInstructions'],
      status: json['status'] ?? 'Active',
      isScheduled: json['type'] == 'Scheduled',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      claimedByNgoId: null, // Derived later if needed
      claimedByNgoName: null,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': isScheduled ? 'Scheduled' : 'OneTime',
    'weight': weightKg,
    'packaging': hasPackaging ? 'Packaged' : 'Unpackaged',
    'pickupAddress': pickupAddress,
    'city': supplierCity,
    'state': supplierState,
    'shelfLife': shelfLife,
    'category': category,
    'image': imageUrl,
    'pickupDate': pickupDeadline.toIso8601String(),
    'contactName': contactName,
    'contactPhone': contactPhone,
    'specialInstructions': specialInstructions,
    'status': status,
  };

  FoodPost copyWith({
    String? status,
    String? claimedByNgoId,
    String? claimedByNgoName,
  }) {
    return FoodPost(
      id: id,
      supplierId: supplierId,
      supplierName: supplierName,
      supplierCity: supplierCity,
      supplierState: supplierState,
      weightKg: weightKg,
      hasPackaging: hasPackaging,
      pickupAddress: pickupAddress,
      shelfLife: shelfLife,
      category: category,
      imageUrl: imageUrl,
      pickupDeadline: pickupDeadline,
      contactName: contactName,
      contactPhone: contactPhone,
      specialInstructions: specialInstructions,
      status: status ?? this.status,
      isScheduled: isScheduled,
      createdAt: createdAt,
      claimedByNgoId: claimedByNgoId ?? this.claimedByNgoId,
      claimedByNgoName: claimedByNgoName ?? this.claimedByNgoName,
    );
  }
}

class ScheduledPost {
  final String id;
  final String supplierId;
  final String supplierName;
  final String supplierCity;
  final String supplierState;
  final double weightKg;
  final bool hasPackaging;
  final String pickupAddress;
  final String shelfLife;
  final String category;
  final String contactName;
  final String contactPhone;
  final String? specialInstructions;
  final Map<String, DaySchedule> schedule; 
  final bool isActive;
  final DateTime createdAt;

  const ScheduledPost({
    required this.id,
    required this.supplierId,
    required this.supplierName,
    required this.supplierCity,
    required this.supplierState,
    required this.weightKg,
    required this.hasPackaging,
    required this.pickupAddress,
    required this.shelfLife,
    required this.category,
    required this.contactName,
    required this.contactPhone,
    this.specialInstructions,
    required this.schedule,
    required this.isActive,
    required this.createdAt,
  });

  factory ScheduledPost.fromJson(Map<String, dynamic> json) {
    Map<String, DaySchedule> scheduleMap = {};
    if (json['scheduledDays'] != null) {
      for (var day in json['scheduledDays']) {
        scheduleMap[day['day']] = DaySchedule.fromJson(day);
      }
    }
    
    return ScheduledPost(
      id: json['_id'] ?? '',
      supplierId: json['supplierId'] is Map ? json['supplierId']['_id'] : (json['supplierId'] ?? ''),
      supplierName: json['supplierId'] is Map ? (json['supplierId']['supplierDetails']?['legalName'] ?? '') : '',
      supplierCity: json['city'] ?? '',
      supplierState: json['state'] ?? '',
      weightKg: (json['weight'] ?? 0).toDouble(),
      hasPackaging: json['packaging'] == 'Packaged',
      pickupAddress: json['pickupAddress'] ?? '',
      shelfLife: json['shelfLife'] ?? '',
      category: json['category'] ?? '',
      contactName: json['contactName'] ?? '',
      contactPhone: json['contactPhone'] ?? '',
      specialInstructions: json['specialInstructions'],
      schedule: scheduleMap,
      isActive: json['status'] == 'Active',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}

class DaySchedule {
  final bool isEnabled;
  final String postingTime; // HH:mm
  final String pickupDeadline; // HH:mm

  const DaySchedule({
    required this.isEnabled,
    required this.postingTime,
    required this.pickupDeadline,
  });

  factory DaySchedule.fromJson(Map<String, dynamic> json) {
    return DaySchedule(
      isEnabled: json['isActive'] ?? false,
      postingTime: json['postTime'] ?? '09:00',
      pickupDeadline: json['deadlineTime'] ?? '12:00',
    );
  }
}


class ClaimRequest {
  final String id;
  final String postId;
  final String ngoId;
  final String ngoName;
  final String ngoPhone;
  final String status; // pending, approved, rejected
  final DateTime createdAt;

  const ClaimRequest({
    required this.id,
    required this.postId,
    required this.ngoId,
    required this.ngoName,
    required this.ngoPhone,
    required this.status,
    required this.createdAt,
  });

  factory ClaimRequest.fromJson(Map<String, dynamic> json) {
    return ClaimRequest(
      id: json['_id'] ?? '',
      postId: json['postId'] ?? '',
      ngoId: json['ngoId'] ?? '',
      ngoName: json['ngoName'] ?? '',
      ngoPhone: json['ngoPhone'] ?? '',
      status: json['status'] ?? 'Pending',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'postId': postId,
    'ngoId': ngoId,
    'ngoName': ngoName,
    'ngoPhone': ngoPhone,
    'status': status,
  };
}
