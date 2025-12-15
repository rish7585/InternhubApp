import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralized error handling utility
class ErrorHandler {
  /// Shows a user-friendly error message
  static void showError(BuildContext context, dynamic error, {String? customMessage}) {
    String message = customMessage ?? getErrorMessage(error);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  /// Shows a success message
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Shows an info message
  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Converts error to user-friendly message
  static String getErrorMessage(dynamic error) {
    if (error is PostgrestException) {
      return error.message;
    } else if (error is StorageException) {
      return 'Storage error: ${error.message}';
    } else if (error is AuthException) {
      return 'Authentication error: ${error.message}';
    } else if (error is String) {
      return error;
    } else if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return 'An unexpected error occurred. Please try again.';
  }

  /// Wraps async operations with error handling
  static Future<T?> handleAsync<T>({
    required BuildContext context,
    required Future<T> Function() operation,
    String? loadingMessage,
    String? successMessage,
    String? errorMessage,
    bool showLoading = true,
    bool showSuccess = false,
  }) async {
    if (showLoading && loadingMessage != null) {
      showInfo(context, loadingMessage);
    }

    try {
      final result = await operation();
      
      if (showSuccess && successMessage != null) {
        ErrorHandler.showSuccess(context, successMessage);
      }
      
      return result;
    } catch (error) {
      showError(
        context,
        error,
        customMessage: errorMessage,
      );
      return null;
    }
  }
}

