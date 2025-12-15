import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last Updated: ${DateTime.now().toString().split(' ')[0]}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            
            _buildSection(
              context,
              '1. Information We Collect',
              'We collect information that you provide directly to us, including:\n\n'
              '• Account information (name, email, phone number)\n'
              '• Profile information (bio, company, location, profile pictures)\n'
              '• Content you post (posts, messages, roommate profiles)\n'
              '• Location data (when you enable location services)\n'
              '• Device information (for push notifications)',
            ),
            
            _buildSection(
              context,
              '2. How We Use Your Information',
              'We use the information we collect to:\n\n'
              '• Provide and improve our services\n'
              '• Connect you with other users\n'
              '• Send you notifications and updates\n'
              '• Ensure platform safety and security\n'
              '• Analyze usage patterns to improve user experience',
            ),
            
            _buildSection(
              context,
              '3. Information Sharing',
              'We do not sell your personal information. We may share your information:\n\n'
              '• With other users as part of the platform\'s core functionality\n'
              '• With service providers who assist in operating our platform\n'
              '• When required by law or to protect our rights\n'
              '• In connection with a business transfer (merger, acquisition)',
            ),
            
            _buildSection(
              context,
              '4. Data Security',
              'We implement appropriate technical and organizational measures to protect your personal information. However, no method of transmission over the internet is 100% secure.',
            ),
            
            _buildSection(
              context,
              '5. Your Rights',
              'You have the right to:\n\n'
              '• Access your personal data\n'
              '• Correct inaccurate data\n'
              '• Delete your account and data\n'
              '• Opt-out of certain data processing\n'
              '• Export your data',
            ),
            
            _buildSection(
              context,
              '6. Contact Us',
              'If you have questions about this Privacy Policy, please contact us at:\n\n'
              'Email: privacy@internhub.app\n'
              'Address: [Your Company Address]',
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

