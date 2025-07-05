class RoommateProfile {
  final String id;
  final String userId;
  final String name;
  final String phone;
  final String school;
  final String company;
  final String desiredBuilding;
  final String location;
  final double budget;
  final String leaseDuration;
  final List<String> roommatePreferences;
  final String? socialLink;
  final String personalBio;
  final List<String> interests;
  final DateTime createdAt;
  final DateTime updatedAt;

  RoommateProfile({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    required this.school,
    required this.company,
    required this.desiredBuilding,
    required this.location,
    required this.budget,
    required this.leaseDuration,
    required this.roommatePreferences,
    this.socialLink,
    required this.personalBio,
    required this.interests,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'phone': phone,
      'school': school,
      'company': company,
      'desired_building': desiredBuilding,
      'location': location,
      'budget': budget,
      'lease_duration': leaseDuration,
      'roommate_preferences': roommatePreferences,
      'social_link': socialLink,
      'personal_bio': personalBio,
      'interests': interests,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory RoommateProfile.fromJson(Map<String, dynamic> json) {
    return RoommateProfile(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      phone: json['phone'],
      school: json['school'],
      company: json['company'],
      desiredBuilding: json['desired_building'],
      location: json['location'],
      budget: json['budget'].toDouble(),
      leaseDuration: json['lease_duration'],
      roommatePreferences: List<String>.from(json['roommate_preferences']),
      socialLink: json['social_link'],
      personalBio: json['personal_bio'],
      interests: List<String>.from(json['interests']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
} 