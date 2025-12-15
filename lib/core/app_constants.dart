/// App-wide constants
class AppConstants {
  AppConstants._();

  // API Configuration
  static const String supabaseUrl = 'https://cdxayouiebaimtkjxxwu.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNkeGF5b3VpZWJhaW10a2p4eHd1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU1ODE2MTQsImV4cCI6MjA4MTE1NzYxNH0.-fisWdGSw3tLtBJAVMKqf8ZUnQmpPZKI7hjpePpuQkA';

  // Pagination
  static const int postsPerPage = 10;
  static const int roommatesPerPage = 20;
  static const int messagesPerPage = 50;

  // Image Settings
  static const int profileImageMaxSize = 800;
  static const int postImageMaxSize = 1200;
  static const int imageQuality = 85;

  // Storage Buckets
  static const String profilePicBucket = 'profile-pic';
  static const String chatMediaBucket = 'chat-media';

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Debounce Times
  static const Duration searchDebounce = Duration(milliseconds: 500);
  static const Duration typingDebounce = Duration(milliseconds: 1000);
}

