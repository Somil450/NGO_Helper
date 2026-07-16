class AppConstants {
  static const String apiBaseUrl = 'http://localhost:4000/api';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String suppliersCollection = 'suppliers';
  static const String ngosCollection = 'ngos';
  static const String foodPostsCollection = 'food_posts';
  static const String scheduledPostsCollection = 'scheduled_posts';
  static const String claimsCollection = 'claims';

  // User Types
  static const String userTypeSupplier = 'supplier';
  static const String userTypeNGO = 'ngo';

  // Food Categories
  static const List<String> foodCategories = [
    'Prepared Meals',
    'Bakery / Grains',
    'Produce',
    'Dairy',
    'Meat / Protein',
  ];

  // Business Types
  static const List<String> businessTypes = [
    'Restaurant',
    'Corporate Cafeteria',
    'Event Organizer',
    'Catering Company',
    'Wholesaler',
  ];

  // Shelf Life Options
  static const List<String> shelfLifeOptions = [
    '1 hour',
    '2 hours',
    '3 hours',
    '4 hours',
    '6 hours',
    '8 hours',
    '12 hours',
    '24 hours',
  ];

  // Post Statuses
  static const String statusActive = 'active';
  static const String statusClaimed = 'claimed';
  static const String statusExpired = 'expired';

  // Meals calculation
  static const double gramsPerMeal = 400.0;

  // Indian States
  static const List<String> indianStates = [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar',
    'Chhattisgarh', 'Goa', 'Gujarat', 'Haryana',
    'Himachal Pradesh', 'Jharkhand', 'Karnataka', 'Kerala',
    'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya',
    'Mizoram', 'Nagaland', 'Odisha', 'Punjab',
    'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana',
    'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal',
    'Andaman and Nicobar Islands', 'Chandigarh',
    'Dadra and Nagar Haveli and Daman and Diu',
    'Delhi', 'Jammu and Kashmir', 'Ladakh',
    'Lakshadweep', 'Puducherry',
  ];
}
