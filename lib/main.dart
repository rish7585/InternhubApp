import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'notifiers/theme_notifier.dart';
import 'notifiers/locale_notifier.dart';
import 'core/app_theme.dart';
import 'screens/main_screen.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'screens/group_chat_screen.dart';
import 'screens/channel_list_screen.dart';
import 'screens/thread_list_screen.dart';
import 'screens/thread_view_screen.dart';
import 'screens/chat_screen.dart';
import 'models/group.dart';
import 'models/channel.dart';
import 'utils/offline_handler.dart';
import 'core/service_locator.dart';
import 'firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Handle background message
  print('Handling a background message: ${message.messageId}');
}

Future<void> saveDeviceTokenToSupabase(String userId) async {
  final token = await FirebaseMessaging.instance.getToken();
  if (token != null) {
    await Supabase.instance.client.from('device_tokens').upsert({
      'user_id': userId,
      'token': token,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}

void setupFCMTokenSync(String userId) {
  // Save token on startup
  saveDeviceTokenToSupabase(userId);

  // Listen for token refresh
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    await Supabase.instance.client.from('device_tokens').upsert({
      'user_id': userId,
      'token': newToken,
      'updated_at': DateTime.now().toIso8601String(),
    });
  });
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<bool> _checkOnboardingStatus() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('onboarding_completed') ?? false;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await Supabase.initialize(
    url: 'https://cdxayouiebaimtkjxxwu.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNkeGF5b3VpZWJhaW10a2p4eHd1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU1ODE2MTQsImV4cCI6MjA4MTE1NzYxNH0.-fisWdGSw3tLtBJAVMKqf8ZUnQmpPZKI7hjpePpuQkA',
  );
  // Initialize offline handler
  await OfflineHandler.initialize();
  
  // Initialize service locator
  serviceLocator.initialize();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => LocaleNotifier()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initFirebaseMessaging();
    _setupNotificationTapHandler();
    _setupOfflineListener();
  }

  void _setupOfflineListener() {
    OfflineHandler.addListener(() {
      if (mounted) {
        final context = navigatorKey.currentContext;
        if (context != null) {
          OfflineHandler.showOfflineBanner(context);
        }
      }
    });
  }

  @override
  void dispose() {
    OfflineHandler.dispose();
    super.dispose();
  }

  void _initFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();
    // Get the token and (optionally) send to your backend
    final token = await messaging.getToken();
    print('FCM Token: $token');
    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        print('Message Notification: ${message.notification!.title}, ${message.notification!.body}');
        // Optionally show a local notification
      }
    });
  }

  void _setupNotificationTapHandler() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final data = message.data;
      if (data['type'] == 'group' && data['group_id'] != null) {
        navigatorKey.currentState?.pushNamed('/group', arguments: data['group_id']);
      } else if (data['type'] == 'channel' && data['channel_id'] != null) {
        navigatorKey.currentState?.pushNamed('/channel', arguments: data['channel_id']);
      } else if (data['type'] == 'thread' && data['thread_id'] != null) {
        navigatorKey.currentState?.pushNamed('/thread', arguments: data['thread_id']);
      } else if (data['type'] == 'dm' && data['dm_user_id'] != null) {
        navigatorKey.currentState?.pushNamed('/dm', arguments: data['dm_user_id']);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeNotifier, LocaleNotifier>(
      builder: (context, themeNotifier, localeNotifier, _) {
    return MaterialApp(
          navigatorKey: navigatorKey,
          title: 'InternHub',
          debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeNotifier.themeMode,
          locale: localeNotifier.locale,
          supportedLocales: const [
            Locale('en'),
            Locale('es'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: FutureBuilder<bool>(
            future: _checkOnboardingStatus(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              
              final hasCompletedOnboarding = snapshot.data ?? false;
              
              if (!hasCompletedOnboarding) {
                return const OnboardingScreen();
              }
              
              return StreamBuilder<AuthState>(
                stream: Supabase.instance.client.auth.onAuthStateChange,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final session = snapshot.data!.session;
                    if (session != null) {
                      // Set up FCM token sync for logged-in user
                      final userId = session.user.id;
                      setupFCMTokenSync(userId);
                      return const MainScreen();
                    }
                  }
                  return const LoginScreen();
                },
              );
            },
          ),
          routes: {
            '/group': (context) {
              final groupId = ModalRoute.of(context)!.settings.arguments as String;
              final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
              return FutureBuilder(
                future: Supabase.instance.client.from('groups').select().eq('id', groupId).maybeSingle(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
                  final group = snapshot.data;
                  if (group == null) return const Scaffold(body: Center(child: Text('Group not found')));
                  return GroupChatScreen(
                    group: Group.fromJson(group),
                    groupChatService: serviceLocator.groupChatService,
                    userId: userId,
                  );
                },
              );
            },
            '/channel': (context) {
              final channelId = ModalRoute.of(context)!.settings.arguments as String;
              final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
              return FutureBuilder(
                future: Supabase.instance.client.from('channels').select().eq('id', channelId).maybeSingle(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
                  final channel = snapshot.data;
                  if (channel == null) return const Scaffold(body: Center(child: Text('Channel not found')));
                  return ThreadListScreen(
                    channel: Channel.fromJson(channel),
                    channelService: serviceLocator.channelService,
                    userId: userId,
                  );
                },
              );
            },
            '/thread': (context) {
              final threadId = ModalRoute.of(context)!.settings.arguments as String;
              final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
              return FutureBuilder(
                future: Supabase.instance.client.from('threads').select().eq('id', threadId).maybeSingle(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
                  final thread = snapshot.data;
                  if (thread == null) return const Scaffold(body: Center(child: Text('Thread not found')));
                  return ThreadViewScreen(
                    thread: Thread.fromJson(thread),
                    channelService: serviceLocator.channelService,
                    userId: userId,
                  );
                },
              );
            },
            '/dm': (context) {
              final userId = ModalRoute.of(context)!.settings.arguments as String;
              return FutureBuilder(
                future: serviceLocator.profileService.getProfile(userId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
                  final profile = snapshot.data;
                  if (profile == null) return const Scaffold(body: Center(child: Text('User not found')));
                  return ChatScreen(
                    otherUserId: profile['id'],
                    otherUserName: ((profile['first_name'] ?? '') + ' ' + (profile['last_name'] ?? '')).trim(),
                    otherUserProfilePic: profile['profile_picture_url'],
                  );
                },
              );
            },
          },
        );
      },
    );
  }
} 
