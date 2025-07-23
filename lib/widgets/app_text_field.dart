import 'package:flutter/material.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int? maxLines;
  final bool enabled;

  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _focusAnimationController;
  late Animation<double> _focusAnimation;

  @override
  void initState() {
    super.initState();
    _focusAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _focusAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _focusAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _focusAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _focusAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _focusAnimation.value,
          child: Focus(
            onFocusChange: (hasFocus) {
              if (hasFocus) {
                _focusAnimationController.forward();
              } else {
                _focusAnimationController.reverse();
              }
            },
            child: TextFormField(
              controller: widget.controller,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              maxLines: widget.maxLines,
              enabled: widget.enabled,
              validator: widget.validator,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                labelText: widget.label,
                hintText: widget.hint,
                prefixIcon: widget.prefixIcon != null
                    ? Icon(
                        widget.prefixIcon,
                        color: isDark ? Colors.white70 : Colors.grey.shade600,
                      )
                    : null,
                filled: true,
                fillColor: isDark ? Colors.grey[850] : Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white24 : Colors.black26,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white24 : Colors.black26,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.red.shade400,
                    width: 2,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.red.shade400,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} 