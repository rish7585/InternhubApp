import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/login_screen.dart';
import '../notifiers/theme_notifier.dart';
import '../notifiers/locale_notifier.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  bool messagesNotif = true;
  bool postsNotif = true;
  bool roommateNotif = true;
  bool isProfilePublic = true;
  String userId = '';
  String accountCreated = '';
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _fetchAccountInfo();
  }

  Future<void> _fetchAccountInfo() async {
    final user = _authService.currentUser;
    if (user != null) {
      setState(() {
        userId = user.id;
        accountCreated = user.createdAt.toString().split('T').first;
      });
    }
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      // Show informative message about account deletion
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account deletion feature is under development. Please contact support for assistance.'),
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _logout(BuildContext context) async {
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _showBlockedUsers() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Blocked Users'),
        content: const Text('Blocked users management is coming soon. You\'ll be able to view and manage users you\'ve blocked from messaging you.'),
        actions: [
          TextButton(
            child: const Text('OK'), 
            onPressed: () => Navigator.pop(context)
          ),
        ],
      ),
    );
  }

  void _showFAQ() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('FAQ / Help'),
        content: const Text('Help and FAQ section is coming soon. For now, you can contact support for assistance.'),
        actions: [
          TextButton(
            child: const Text('OK'), 
            onPressed: () => Navigator.pop(context)
          ),
        ],
      ),
    );
  }

  void _contactSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: const Text('Support contact feature is coming soon. For now, please email support@internhub.com for assistance.'),
        actions: [
          TextButton(
            child: const Text('OK'), 
            onPressed: () => Navigator.pop(context)
          ),
        ],
      ),
    );
  }

  void _showTerms() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const Text('Terms of Service are coming soon. This will outline the rules and guidelines for using InternHub.'),
        actions: [
          TextButton(
            child: const Text('OK'), 
            onPressed: () => Navigator.pop(context)
          ),
        ],
      ),
    );
  }

  void _showPrivacy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const Text('Privacy Policy is coming soon. This will explain how we collect, use, and protect your personal information.'),
        actions: [
          TextButton(
            child: const Text('OK'), 
            onPressed: () => Navigator.pop(context)
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final localeNotifier = Provider.of<LocaleNotifier>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    String themeMode = themeNotifier.themeMode.toString().split('.').last;
    String language = localeNotifier.locale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Go back',
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
        children: [
          // Account Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Semantics(
              header: true,
              child: Text(
                'Account', 
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.badge),
                  title: Text(
                    'User ID: $userId',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: accountCreated.isNotEmpty 
                      ? Text(
                          'Joined: $accountCreated',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ) 
                      : null,
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Logout'),
                  onTap: () => _logout(context),
                ),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text('Delete Account'),
                  onTap: () => _confirmDeleteAccount(context),
                ),
              ],
            ),
          ),

          // Notifications Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Semantics(
              header: true,
              child: Text(
                'Notifications', 
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.notifications),
                  title: const Text('Enable Notifications'),
                  value: notificationsEnabled,
                  onChanged: (val) => setState(() => notificationsEnabled = val),
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.message),
                  title: const Text('Messages'),
                  value: messagesNotif,
                  onChanged: notificationsEnabled ? (val) => setState(() => messagesNotif = val) : null,
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.post_add),
                  title: const Text('Posts'),
                  value: postsNotif,
                  onChanged: notificationsEnabled ? (val) => setState(() => postsNotif = val) : null,
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.people),
                  title: const Text('Roommate Requests'),
                  value: roommateNotif,
                  onChanged: notificationsEnabled ? (val) => setState(() => roommateNotif = val) : null,
                ),
              ],
            ),
          ),

          // Privacy & Security Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Semantics(
              header: true,
              child: Text(
                'Privacy & Security', 
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.block),
                  title: const Text('Manage Blocked Users'),
                  onTap: _showBlockedUsers,
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.visibility),
                  title: const Text('Profile Public'),
                  value: isProfilePublic,
                  onChanged: (val) => setState(() => isProfilePublic = val),
                ),
                ListTile(
                  leading: const Icon(Icons.security),
                  title: const Text('Two-Factor Authentication'),
                  subtitle: const Text('Coming soon!'),
                  onTap: () => showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Two-Factor Authentication'),
                      content: const Text('Two-factor authentication is coming soon. This will add an extra layer of security to your account by requiring a second form of verification when signing in.'),
                      actions: [
                        TextButton(
                          child: const Text('OK'), 
                          onPressed: () => Navigator.pop(context)
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // App Preferences Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Semantics(
              header: true,
              child: Text(
                'App Preferences', 
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.brightness_6),
                  title: const Text('Theme'),
                  trailing: DropdownButton<String>(
                    value: themeMode,
                    items: const [
                      DropdownMenuItem(value: 'system', child: Text('System')),
                      DropdownMenuItem(value: 'light', child: Text('Light')),
                      DropdownMenuItem(value: 'dark', child: Text('Dark')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        switch (val) {
                          case 'light':
                            themeNotifier.setTheme(ThemeMode.light);
                            break;
                          case 'dark':
                            themeNotifier.setTheme(ThemeMode.dark);
                            break;
                          default:
                            themeNotifier.setTheme(ThemeMode.system);
                        }
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 72, bottom: 8),
                  child: Builder(
                    builder: (context) {
                      final effectiveBrightness = Theme.of(context).brightness;
                      final effectiveTheme = effectiveBrightness == Brightness.dark ? 'Dark Mode' : 'Light Mode';
                      return Text(
                        'Currently using: $effectiveTheme',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.grey, 
                          fontSize: 12
                        ),
                      );
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Language'),
                  trailing: DropdownButton<String>(
                    value: language,
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'es', child: Text('Spanish')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        localeNotifier.setLocale(Locale(val));
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // Support & About Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Semantics(
              header: true,
              child: Text(
                'Support & About', 
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('FAQ / Help'),
                  onTap: _showFAQ,
                ),
                ListTile(
                  leading: const Icon(Icons.support_agent),
                  title: const Text('Contact Support'),
                  onTap: _contactSupport,
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('App Version 1.0.0'),
                ),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('Terms of Service'),
                  onTap: _showTerms,
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text('Privacy Policy'),
                  onTap: _showPrivacy,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 