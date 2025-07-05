import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> createProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String bio,
    required String company,
    required String location,
    String? profilePictureUrl,
  }) async {
    try {
      await _supabase.from('profiles').upsert({
        'id': userId,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'bio': bio,
        'company': company,
        'location': location,
        'profile_picture_url': profilePictureUrl,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (error) {
      throw _handleError(error);
    }
  }

  Future<Map<String, dynamic>?> getProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return response;
    } catch (error) {
      throw _handleError(error);
    }
  }

  Future<bool> hasProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('id')
          .eq('id', userId)
          .maybeSingle();
      return response != null;
    } catch (error) {
      throw _handleError(error);
    }
  }

  Future<String?> uploadProfilePicture(String userId, Uint8List imageBytes) async {
    try {
      final fileExt = 'jpg';
      final fileName = '$userId.$fileExt';
      final filePath = 'profile_pictures/$fileName';

      await _supabase.storage.from('profile-pic').uploadBinary(
        filePath,
        imageBytes,
        fileOptions: const FileOptions(
          contentType: 'image/jpeg',
          upsert: true,
        ),
      );

      final imageUrl = _supabase.storage.from('profile-pic').getPublicUrl(filePath);
      return imageUrl;
    } catch (error) {
      throw _handleError(error);
    }
  }

  String _handleError(dynamic error) {
    print('Supabase error: $error'); // Debug print
    if (error is PostgrestException) {
      return error.message;
    } else if (error is String) {
      return error;
    }
    return 'An unexpected error occurred';
  }
} 