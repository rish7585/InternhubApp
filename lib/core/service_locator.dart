import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../services/group_chat_service.dart';
import '../services/channel_service.dart';

/// Service Locator for dependency injection
/// Provides centralized access to all services
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  // Services
  late final AuthService authService;
  late final ProfileService profileService;
  late final GroupChatService groupChatService;
  late final ChannelService channelService;

  // Supabase client
  SupabaseClient get supabase => Supabase.instance.client;

  /// Initialize all services
  void initialize() {
    final client = Supabase.instance.client;
    
    authService = AuthService();
    profileService = ProfileService();
    groupChatService = GroupChatService(client: client);
    channelService = ChannelService(client: client);
  }

  /// Get service instance (for future extensibility)
  T getService<T>() {
    if (T == AuthService) return authService as T;
    if (T == ProfileService) return profileService as T;
    if (T == GroupChatService) return groupChatService as T;
    if (T == ChannelService) return channelService as T;
    throw Exception('Service of type $T not found');
  }
}

/// Global service locator instance
final serviceLocator = ServiceLocator();

