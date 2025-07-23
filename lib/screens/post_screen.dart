import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import 'main_screen.dart';
import 'package:confetti/confetti.dart';

/// Post Creation Screen
/// Allows users to create and share a new post, optionally with an image.
class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _authService = AuthService();
  final _profileService = ProfileService();
  final _imagePicker = ImagePicker();
  late ConfettiController _confettiController;
  
  bool _isLoading = false;
  String? _errorMessage;
  Uint8List? _imageBytes;
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _contentController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  /// Loads the current user's profile for post attribution.
  Future<void> _loadProfile() async {
    final user = _authService.currentUser;
    if (user != null) {
      final profile = await _profileService.getProfile(user.id);
      setState(() {
        _profile = profile;
      });
    }
  }

  /// Submits the post to Supabase.
  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final user = _authService.currentUser;
      if (user == null) throw 'User not authenticated';
      
      String? imageUrl;
      if (_imageBytes != null) {
        final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final filePath = 'post_images/$fileName';
        await Supabase.instance.client.storage.from('profile-pic').uploadBinary(
          filePath,
          _imageBytes!,
          fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
        );
        imageUrl = Supabase.instance.client.storage.from('profile-pic').getPublicUrl(filePath);
      }
      
      await Supabase.instance.client.from('posts').insert({
        'user_id': user.id,
        'content': _contentController.text.trim(),
        'image_url': imageUrl,
        'created_at': DateTime.now().toIso8601String(),
      });
      
      if (mounted) {
        setState(() {
          _contentController.clear();
          _imageBytes = null;
        });
        
        // Trigger confetti animation
        _confettiController.play();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post created successfully! 🎉'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Navigate back after a short delay
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MainScreen()),
              (route) => false,
            );
          }
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Picks an image from the gallery for the post.
  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to pick image: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MainScreen()),
              (route) => false,
            );
          },
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Semantics(
                              label: 'Your profile picture',
                              image: true,
                              child: CircleAvatar(
                              radius: 24,
                              backgroundImage: _profile != null && _profile!['profile_picture_url'] != null
                                  ? NetworkImage('${_profile!['profile_picture_url']}?v=${DateTime.now().millisecondsSinceEpoch}')
                                  : null,
                              child: _profile == null || _profile!['profile_picture_url'] == null
                                    ? Icon(
                                        Icons.person, 
                                        size: 24,
                                        color: Theme.of(context).brightness == Brightness.dark 
                                            ? Colors.white 
                                            : Colors.grey.shade600,
                                      )
                                  : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _profile != null
                                    ? '${_profile!['first_name']} ${_profile!['last_name']}'
                                    : 'User',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        if (_errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark 
                                  ? Colors.red.shade900.withValues(alpha: 0.2) 
                                  : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(context).brightness == Brightness.dark 
                                    ? Colors.red.shade400 
                                    : Colors.red.shade200,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Theme.of(context).brightness == Brightness.dark 
                                      ? Colors.red.shade300 
                                      : Colors.red.shade600,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                      color: Theme.of(context).brightness == Brightness.dark 
                                          ? Colors.red.shade300 
                                          : Colors.red.shade700,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        AppTextField(
                          controller: _contentController,
                          maxLines: 4,
                          label: 'What do you want to share?',
                          hint: 'Share something with everyone...',
                          validator: (v) => v == null || v.trim().isEmpty ? 'Post content required' : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Tooltip(
                              message: 'Add image to your post',
                              child: IconButton(
                                onPressed: _pickImage,
                                icon: const Icon(Icons.image),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Add image to your post',
                              style: TextStyle(
                                color: Theme.of(context).brightness == Brightness.dark 
                                    ? Colors.white70 
                                    : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_imageBytes != null)
                          Stack(
                            children: [
                              Semantics(
                                label: 'Selected image for post',
                                image: true,
                                child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(_imageBytes!, height: 180, width: double.infinity, fit: BoxFit.cover),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Tooltip(
                                  message: 'Remove image',
                                child: GestureDetector(
                                  onTap: () => setState(() => _imageBytes = null),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(Icons.close, color: Colors.white, size: 20),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 24),
                        Tooltip(
                          message: 'Create and publish your post',
                          child: AppButton(
                            label: 'Post',
                          onPressed: _isLoading ? null : _submitPost,
                            isLoading: _isLoading,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.1,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),
        ],
      ),
    );
  }
} 