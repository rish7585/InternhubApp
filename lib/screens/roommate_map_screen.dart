import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/roommate_profile.dart';
import '../utils/error_handler.dart';
import '../utils/page_transitions.dart';
import 'chat_screen.dart';
import '../constants/app_spacing.dart';
import '../widgets/empty_state.dart';

class RoommateMapScreen extends StatefulWidget {
  const RoommateMapScreen({super.key});

  @override
  State<RoommateMapScreen> createState() => _RoommateMapScreenState();
}

class _RoommateMapScreenState extends State<RoommateMapScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  List<RoommateProfile> _roommateProfiles = [];
  RoommateProfile? _selectedProfile;
  bool _isLoading = true;
  LatLng _currentLocation = const LatLng(37.7749, -122.4194); // Default to San Francisco

  @override
  void initState() {
    super.initState();
    _loadRoommates();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Try to get user's current location
      // For now, we'll use a default location
      // In production, use geolocator to get actual location
      setState(() {
        _currentLocation = const LatLng(37.7749, -122.4194);
      });
    } catch (e) {
      ErrorHandler.showError(context, e);
    }
  }

  Future<void> _loadRoommates() async {
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // Fetch roommate profiles
      final response = await Supabase.instance.client
          .from('roommate_profiles')
          .select()
          .neq('user_id', user.id);

      final profiles = List<Map<String, dynamic>>.from(response)
          .map((json) => RoommateProfile.fromJson(json))
          .toList();

      // Convert locations to coordinates and create markers
      await _createMarkers(profiles);

      setState(() {
        _roommateProfiles = profiles;
        _isLoading = false;
      });
    } catch (e) {
      ErrorHandler.showError(context, e);
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createMarkers(List<RoommateProfile> profiles) async {
    final Set<Marker> markers = {};

    for (final profile in profiles) {
      LatLng position;

      // If lat/lng exist, use them; otherwise geocode the location
      if (profile.latitude != null && profile.longitude != null) {
        position = LatLng(profile.latitude!, profile.longitude!);
      } else {
        // Geocode location string to coordinates
        try {
          final locations = await locationFromAddress(profile.location);
          if (locations.isNotEmpty) {
            position = LatLng(
              locations.first.latitude,
              locations.first.longitude,
            );
          } else {
            continue; // Skip if geocoding fails
          }
        } catch (e) {
          continue; // Skip if geocoding fails
        }
      }

      markers.add(
        Marker(
          markerId: MarkerId(profile.id),
          position: position,
          infoWindow: InfoWindow(
            title: profile.name,
            snippet: '\$${profile.budget.toStringAsFixed(0)}/month • ${profile.location}',
          ),
          onTap: () {
            _showRoommateBottomSheet(profile);
          },
        ),
      );
    }

    setState(() {
      _markers.clear();
      _markers.addAll(markers);
    });
  }

  void _showRoommateBottomSheet(RoommateProfile profile) {
    setState(() {
      _selectedProfile = profile;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    // Profile header
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.name,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                profile.location,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    
                    // Budget
                    _buildInfoRow(
                      icon: Icons.attach_money,
                      label: 'Budget',
                      value: '\$${profile.budget.toStringAsFixed(0)}/month',
                    ),
                    
                    // School
                    if (profile.school.isNotEmpty)
                      _buildInfoRow(
                        icon: Icons.school,
                        label: 'School',
                        value: profile.school,
                      ),
                    
                    // Company
                    if (profile.company.isNotEmpty)
                      _buildInfoRow(
                        icon: Icons.business,
                        label: 'Company',
                        value: profile.company,
                      ),
                    
                    // Lease Duration
                    _buildInfoRow(
                      icon: Icons.calendar_today,
                      label: 'Lease Duration',
                      value: profile.leaseDuration,
                    ),
                    
                    const SizedBox(height: AppSpacing.md),
                    
                    // Bio
                    Text(
                      'About',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      profile.personalBio,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    
                    // Interests
                    if (profile.interests.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Interests',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: profile.interests.map((interest) {
                          return Chip(
                            label: Text(interest),
                            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          );
                        }).toList(),
                      ),
                    ],
                    
                    const SizedBox(height: AppSpacing.lg),
                    
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                PageTransitions.slideRight(
                                  page: ChatScreen(
                                    otherUserId: profile.userId,
                                    otherUserName: profile.name,
                                    otherUserProfilePic: null,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.message),
                            label: const Text('Message'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              // Could navigate to full profile view
                            },
                            icon: const Icon(Icons.person),
                            label: const Text('View Profile'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(() {
      setState(() {
        _selectedProfile = null;
      });
    });
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Roommates on Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            tooltip: 'My Location',
            onPressed: () {
              _mapController?.animateCamera(
                CameraUpdate.newLatLngZoom(_currentLocation, 14),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : kIsWeb
              ? _buildWebFallback()
              : Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _currentLocation,
                        zoom: 12,
                      ),
                      markers: _markers,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      mapType: MapType.normal,
                      onMapCreated: (controller) {
                        _mapController = controller;
                      },
                    ),
                    // Stats overlay
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          child: Row(
                            children: [
                              Icon(
                                Icons.people,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                '${_roommateProfiles.length} roommates nearby',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildWebFallback() {
    return Column(
      children: [
        // Stats card
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Icon(
                    Icons.people,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '${_roommateProfiles.length} roommates nearby',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: EmptyState(
            icon: Icons.map_outlined,
            title: 'Map View Available on Mobile',
            message: 'The interactive map feature is currently available on iOS and Android devices. On web, you can browse roommates using the list or swipe view.\n\n${_roommateProfiles.length} roommate${_roommateProfiles.length != 1 ? 's' : ''} found nearby.',
            actionButton: _roommateProfiles.isNotEmpty
                ? ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.list),
                    label: const Text('View List'),
                  )
                : null,
          ),
        ),
        // Show roommate list on web
        if (_roommateProfiles.isNotEmpty)
          Container(
            height: 300,
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nearby Roommates',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: ListView.builder(
                    itemCount: _roommateProfiles.length,
                    itemBuilder: (context, index) {
                      final profile = _roommateProfiles[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            child: Icon(
                              Icons.person,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          title: Text(profile.name),
                          subtitle: Text('${profile.location} • \$${profile.budget.toStringAsFixed(0)}/month'),
                          trailing: IconButton(
                            icon: const Icon(Icons.arrow_forward_ios, size: 16),
                            onPressed: () {
                              _showRoommateBottomSheet(profile);
                            },
                          ),
                          onTap: () {
                            _showRoommateBottomSheet(profile);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

