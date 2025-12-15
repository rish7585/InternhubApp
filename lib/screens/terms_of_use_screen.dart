import 'package:flutter/material.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Use'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms of Use',
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
              '1. Acceptance of Terms',
              'By accessing and using InternHub, you accept and agree to be bound by the terms and provision of this agreement.',
            ),
            
            _buildSection(
              context,
              '2. User Accounts',
              'You are responsible for:\n\n'
              '• Maintaining the confidentiality of your account\n'
              '• All activities that occur under your account\n'
              '• Providing accurate and complete information\n'
              '• Notifying us immediately of any unauthorized use',
            ),
            
            _buildSection(
              context,
              '3. User Conduct',
              'You agree not to:\n\n'
              '• Post offensive, harmful, or illegal content\n'
              '• Harass, abuse, or harm other users\n'
              '• Impersonate others or provide false information\n'
              '• Spam or send unsolicited messages\n'
              '• Violate any applicable laws or regulations',
            ),
            
            _buildSection(
              context,
              '4. Content Ownership',
              'You retain ownership of content you post. By posting, you grant us a license to use, display, and distribute your content on the platform.',
            ),
            
            _buildSection(
              context,
              '5. Prohibited Activities',
              'The following activities are prohibited:\n\n'
              '• Scraping or harvesting user data\n'
              '• Attempting to gain unauthorized access\n'
              '• Interfering with platform operations\n'
              '• Using automated systems to interact with the platform\n'
              '• Reverse engineering or copying the platform',
            ),
            
            _buildSection(
              context,
              '6. Termination',
              'We reserve the right to terminate or suspend your account at any time for violations of these terms or for any other reason we deem necessary.',
            ),
            
            _buildSection(
              context,
              '7. Disclaimer',
              'The platform is provided "as is" without warranties of any kind. We do not guarantee the accuracy, completeness, or usefulness of any information on the platform.',
            ),
            
            _buildSection(
              context,
              '8. Limitation of Liability',
              'To the maximum extent permitted by law, InternHub shall not be liable for any indirect, incidental, special, or consequential damages arising from your use of the platform.',
            ),
            
            _buildSection(
              context,
              '9. Changes to Terms',
              'We reserve the right to modify these terms at any time. Continued use of the platform after changes constitutes acceptance of the new terms.',
            ),
            
            _buildSection(
              context,
              '10. Contact Information',
              'For questions about these Terms of Use, please contact us at:\n\n'
              'Email: legal@internhub.app\n'
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

