import 'package:flutter/material.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'roommate_finder_screen.dart';

class CreateRoommateProfileScreen extends StatefulWidget {
  const CreateRoommateProfileScreen({Key? key}) : super(key: key);

  @override
  State<CreateRoommateProfileScreen> createState() => _CreateRoommateProfileScreenState();
}

class _CreateRoommateProfileScreenState extends State<CreateRoommateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;
  
  // Form controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _schoolController = TextEditingController();
  final _companyController = TextEditingController();
  final _desiredBuildingController = TextEditingController();
  final _locationController = TextEditingController();
  final _socialLinkController = TextEditingController();
  final _personalBioController = TextEditingController();
  
  // Form values
  double _budget = 1500;
  String _leaseDuration = '12 months';
  List<String> _selectedPreferences = [];
  List<String> _selectedInterests = [];
  
  // Available options
  final List<String> _leaseDurations = [
    '3 months',
    '6 months',
    '12 months',
    '18 months',
    '24 months',
  ];
  
  final List<String> _preferenceOptions = [
    'Non-smoker',
    'Pet-friendly',
    'Professional',
    'Student',
    'Early riser',
    'Night owl',
    'Clean and organized',
    'Social',
    'Quiet',
    'LGBTQ+ friendly',
  ];
  
  final List<String> _interestOptions = [
    'Reading',
    'Gaming',
    'Sports',
    'Music',
    'Cooking',
    'Travel',
    'Fitness',
    'Art',
    'Technology',
    'Photography',
    'Dancing',
    'Hiking',
    'Movies',
    'Fashion',
    'Food',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Roommate Profile'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildProgressIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildBasicInfoPage(),
                  _buildLocationAndBudgetPage(),
                  _buildPreferencesPage(),
                  _buildBioAndInterestsPage(),
                ],
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(4, (index) {
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: index <= _currentPage ? Colors.indigo : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBasicInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Basic Information',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          AppTextField(
            controller: _nameController,
            label: 'Full Name *',
            hint: 'Enter your full name',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _phoneController,
            label: 'Phone Number *',
            hint: 'Enter your phone number',
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              if (value.length < 10) {
                return 'Please enter a valid phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _schoolController,
            label: 'School/University *',
            hint: 'Enter your school or university',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your school';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _companyController,
            label: 'Company/Employer *',
            hint: 'Enter your company or employer',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your company';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLocationAndBudgetPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Location & Budget',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          AppTextField(
            controller: _desiredBuildingController,
            label: 'Desired Building *',
            hint: 'Enter desired building name',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter desired building';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _locationController,
            label: 'Location *',
            hint: 'Enter city and state',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter location';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Monthly Budget',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${_budget.toInt()}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo),
          ),
          Slider(
            value: _budget,
            min: 500,
            max: 5000,
            divisions: 45,
            label: '\$${_budget.toInt()}',
            onChanged: (value) {
              setState(() {
                _budget = value;
              });
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Lease Duration',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _leaseDuration,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            items: _leaseDurations.map((duration) {
              return DropdownMenuItem(
                value: duration,
                child: Text(duration),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _leaseDuration = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Roommate Preferences',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Select all that apply:',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _preferenceOptions.map((preference) {
              final isSelected = _selectedPreferences.contains(preference);
              return FilterChip(
                label: Text(preference),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedPreferences.add(preference);
                    } else {
                      _selectedPreferences.remove(preference);
                    }
                  });
                },
                selectedColor: Colors.indigo[100],
                checkmarkColor: Colors.indigo,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBioAndInterestsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bio & Interests',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          AppTextField(
            controller: _personalBioController,
            label: 'Personal Bio *',
            hint: 'Tell potential roommates about yourself...',
            maxLines: 4,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your bio';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _socialLinkController,
            label: 'Social Link (Optional)',
            hint: 'Instagram, LinkedIn, etc.',
          ),
          const SizedBox(height: 24),
          const Text(
            'Interests (Optional)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _interestOptions.map((interest) {
              final isSelected = _selectedInterests.contains(interest);
              return FilterChip(
                label: Text(interest),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedInterests.add(interest);
                    } else {
                      _selectedInterests.remove(interest);
                    }
                  });
                },
                selectedColor: Colors.indigo[100],
                checkmarkColor: Colors.indigo,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: AppButton(
                label: 'Previous',
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 16),
          Expanded(
            child: AppButton(
              label: _currentPage < 3 ? 'Next' : 'Create Profile',
              onPressed: () {
                if (_currentPage < 3) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } else {
                  _submitProfile();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _submitProfile() async {
    if (_formKey.currentState!.validate()) {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated!'), backgroundColor: Colors.red),
        );
        return;
      }
      try {
        await Supabase.instance.client.from('roommate_profiles').insert({
          'user_id': user.id,
          'name': _nameController.text,
          'phone': _phoneController.text,
          'school': _schoolController.text,
          'company': _companyController.text,
          'desired_building': _desiredBuildingController.text,
          'location': _locationController.text,
          'budget': _budget,
          'lease_duration': _leaseDuration,
          'roommate_preferences': _selectedPreferences,
          'social_link': _socialLinkController.text.isEmpty ? null : _socialLinkController.text,
          'personal_bio': _personalBioController.text,
          'interests': _selectedInterests,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Roommate profile created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const RoommateFinderScreen()),
            (route) => false,
          );
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create profile: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _schoolController.dispose();
    _companyController.dispose();
    _desiredBuildingController.dispose();
    _locationController.dispose();
    _socialLinkController.dispose();
    _personalBioController.dispose();
    _pageController.dispose();
    super.dispose();
  }
} 