// ignore: unused_import
import 'package:cloud_firestore/cloud_firestore.dart';


class UserModel {
  final String uid;
  final String email;
  final String userType; // 'Supplier', 'NGO', or 'Employee'
  final bool isOnboarded;

  const UserModel({
    required this.uid,
    required this.email,
    required this.userType,
    required this.isOnboarded,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawRole = json['role']?.toString().toLowerCase() ?? '';
    return UserModel(
      uid: json['_id'] ?? '',
      email: json['email'] ?? '',
      userType: rawRole,
      isOnboarded: (rawRole == 'ngo' && json['ngoDetails'] != null && json['ngoDetails']['address'] != null && json['ngoDetails']['address'].toString().isNotEmpty) || 
                   (rawRole == 'supplier' && json['supplierDetails'] != null && json['supplierDetails']['address'] != null && json['supplierDetails']['address'].toString().isNotEmpty) ||
                   (rawRole == 'employee' && json['employeeDetails'] != null),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': uid,
    'email': email,
    'role': userType,
  };
}

class SupplierProfile {
  final String uid;
  final String businessType;
  final String entityName;
  final String address;
  final String city;
  final String state;
  final String contactNumber;
  final String? website;
  final double totalWeightDonated; // in kg
  final int totalMealsDonated;
  final int totalPosts;

  const SupplierProfile({
    required this.uid,
    required this.businessType,
    required this.entityName,
    required this.address,
    required this.city,
    required this.state,
    required this.contactNumber,
    this.website,
    this.totalWeightDonated = 0,
    this.totalMealsDonated = 0,
    this.totalPosts = 0,
  });

  factory SupplierProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SupplierProfile(
      uid: doc.id,
      businessType: data['businessType'] ?? '',
      entityName: data['entityName'] ?? '',
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      contactNumber: data['contactNumber'] ?? '',
      website: data['website'],
      totalWeightDonated: (data['totalWeightDonated'] ?? 0).toDouble(),
      totalMealsDonated: data['totalMealsDonated'] ?? 0,
      totalPosts: data['totalPosts'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'businessType': businessType,
    'entityName': entityName,
    'address': address,
    'city': city,
    'state': state,
    'contactNumber': contactNumber,
    'website': website,
    'totalWeightDonated': totalWeightDonated,
    'totalMealsDonated': totalMealsDonated,
    'totalPosts': totalPosts,
  };

  SupplierProfile copyWith({
    double? totalWeightDonated,
    int? totalMealsDonated,
    int? totalPosts,
  }) {
    return SupplierProfile(
      uid: uid,
      businessType: businessType,
      entityName: entityName,
      address: address,
      city: city,
      state: state,
      contactNumber: contactNumber,
      website: website,
      totalWeightDonated: totalWeightDonated ?? this.totalWeightDonated,
      totalMealsDonated: totalMealsDonated ?? this.totalMealsDonated,
      totalPosts: totalPosts ?? this.totalPosts,
    );
  }
}

class NGOProfile {
  final String uid;
  final String ngoName;
  final String missionStatement;
  final String address;
  final String city;
  final String state;
  final String mobileNumber;
  final String? website;

  const NGOProfile({
    required this.uid,
    required this.ngoName,
    required this.missionStatement,
    required this.address,
    required this.city,
    required this.state,
    required this.mobileNumber,
    this.website,
  });

  factory NGOProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NGOProfile(
      uid: doc.id,
      ngoName: data['ngoName'] ?? '',
      missionStatement: data['missionStatement'] ?? '',
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      mobileNumber: data['mobileNumber'] ?? '',
      website: data['website'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': ngoName,
    'missionStatement': missionStatement,
    'address': address,
    'city': city,
    'state': state,
    'mobileNumber': mobileNumber,
    'website': website,
  };
}
