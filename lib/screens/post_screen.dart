import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _authService = AuthService();
  final _profileService = ProfileService();
  final _imagePicker = ImagePicker();
  
  bool _isLoading = false;
  String? _errorMessage;
  Uint8List? _imageBytes;
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = _authService.currentUser;
    if (user != null) {
      final profile = await _profileService.getProfile(user.id);
      setState(() {
        _profile = profile;
      });
    }
  }

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post created!')),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

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
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Post')),
      body: SingleChildScrollView(
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
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: _profile != null && _profile!['profile_picture_url'] != null
                              ? NetworkImage('${_profile!['profile_picture_url']}?v=${DateTime.now().millisecondsSinceEpoch}')
                              : null,
                          child: _profile == null || _profile!['profile_picture_url'] == null
                              ? const Icon(Icons.person, size: 24)
                              : null,
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
                      Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
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
                    if (_imageBytes != null)
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(_imageBytes!, height: 180, width: double.infinity, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
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
                        ],
                      ),
                    const SizedBox(height: 24),
                    AppButton(
                      label: 'Post',
                      onPressed: _isLoading ? null : _submitPost,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 