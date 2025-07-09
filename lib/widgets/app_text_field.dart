import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final int? maxLines;
  final bool enabled;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final bool showSuccessState;

  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.maxLines = 1,
    this.enabled = true,
    this.onTap,
    this.suffixIcon,
    this.showSuccessState = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.grey.shade700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          maxLines: maxLines,
          enabled: enabled,
          onTap: onTap,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : Colors.grey.shade900,
            letterSpacing: -0.3,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? Colors.white54 : Colors.grey.shade400,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    color: isDark ? Colors.white54 : Colors.grey.shade500,
                    size: 20,
                  )
                : null,
            suffixIcon: suffixIcon ?? (showSuccessState 
                ? Icon(
                    Icons.check_circle,
                    color: Colors.green.shade500,
                    size: 20,
                  )
                : null),
            filled: true,
            fillColor: enabled 
                ? (isDark ? const Color(0xFF23262F) : Colors.grey.shade50)
                : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: showSuccessState 
                    ? Colors.green.shade400 
                    : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade300),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: prefixIcon != null ? 16 : 16,
            ),
            errorStyle: TextStyle(
              color: Colors.red.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
} 