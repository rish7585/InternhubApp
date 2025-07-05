import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../screens/login_screen.dart';
import '../notifiers/theme_notifier.dart';
import '../notifiers/locale_notifier.dart';

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
  String userId = Supabase.instance.client.auth.currentUser?.id ?? '';
  String accountCreated = '';

  @override
  void initState() {
    super.initState();
    _fetchAccountInfo();
  }

  Future<void> _fetchAccountInfo() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      setState(() {
        accountCreated = user.createdAt?.toString().split('T').first ?? '';
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(child: const Text('Cancel'), onPressed: () => Navigator.pop(context, false)),
          TextButton(child: const Text('Delete'), onPressed: () => Navigator.pop(context, true)),
        ],
      ),
    );
    if (confirmed == true) {
      // TODO: Implement account deletion logic
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account deletion not implemented.')));
    }
  }

  void _showBlockedUsers() {
    // TODO: Implement blocked users management
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Blocked Users'),
        content: const Text('Blocked users management coming soon.'),
        actions: [TextButton(child: const Text('OK'), onPressed: () => Navigator.pop(context))],
      ),
    );
  }

  void _showFAQ() {
    // TODO: Link to FAQ/help
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('FAQ / Help'),
        content: const Text('FAQ and help coming soon.'),
        actions: [TextButton(child: const Text('OK'), onPressed: () => Navigator.pop(context))],
      ),
    );
  }

  void _contactSupport() {
    // TODO: Implement contact support
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: const Text('Contact support coming soon.'),
        actions: [TextButton(child: const Text('OK'), onPressed: () => Navigator.pop(context))],
      ),
    );
  }

  void _showTerms() {
    // TODO: Link to Terms of Service
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const Text('Terms of Service coming soon.'),
        actions: [TextButton(child: const Text('OK'), onPressed: () => Navigator.pop(context))],
      ),
    );
  }

  void _showPrivacy() {
    // TODO: Link to Privacy Policy
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const Text('Privacy Policy coming soon.'),
        actions: [TextButton(child: const Text('OK'), onPressed: () => Navigator.pop(context))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final localeNotifier = Provider.of<LocaleNotifier>(context);
    String theme = themeNotifier.themeMode.toString().split('.').last;
    String language = localeNotifier.locale.languageCode;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
        children: [
          // Account Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Account', style: Theme.of(context).textTheme.titleMedium),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.badge),
                  title: Text('User ID: $userId'),
                  subtitle: accountCreated.isNotEmpty ? Text('Joined: $accountCreated') : null,
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
            child: Text('Notifications', style: Theme.of(context).textTheme.titleMedium),
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
            child: Text('Privacy & Security', style: Theme.of(context).textTheme.titleMedium),
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
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('2FA coming soon!'))),
                ),
              ],
            ),
          ),

          // App Preferences Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('App Preferences', style: Theme.of(context).textTheme.titleMedium),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.brightness_6),
                  title: const Text('Theme'),
                  trailing: DropdownButton<String>(
                    value: theme,
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
                        style: TextStyle(color: Colors.grey, fontSize: 12),
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
            child: Text('Support & About', style: Theme.of(context).textTheme.titleMedium),
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