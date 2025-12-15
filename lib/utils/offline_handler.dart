import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

/// Handles offline state and connectivity monitoring
class OfflineHandler {
  static final Connectivity _connectivity = Connectivity();
  static StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  static bool _isOnline = true;
  static final List<VoidCallback> _listeners = [];

  /// Initialize connectivity monitoring
  static Future<void> initialize() async {
    // Check initial connectivity
    final result = await _connectivity.checkConnectivity();
    _isOnline = result.any((r) => r != ConnectivityResult.none);

    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        final wasOnline = _isOnline;
        _isOnline = results.any((r) => r != ConnectivityResult.none);
        
        if (wasOnline != _isOnline) {
          _notifyListeners();
        }
      },
    );
  }

  /// Dispose connectivity monitoring
  static void dispose() {
    _connectivitySubscription?.cancel();
    _listeners.clear();
  }

  /// Check if device is currently online
  static bool get isOnline => _isOnline;

  /// Add a listener for connectivity changes
  static void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  /// Remove a listener
  static void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  static void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  /// Show offline banner
  static void showOfflineBanner(BuildContext context) {
    if (!_isOnline) {
      ScaffoldMessenger.of(context).showMaterialBanner(
        MaterialBanner(
          content: const Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'No internet connection. Some features may be unavailable.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange.shade700,
          actions: [
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              },
              child: const Text(
                'DISMISS',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
    }
  }
}

