import 'package:flutter/material.dart';

class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? color;
  final bool isOutlined;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.color,
    this.isOutlined = false,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onPressed != null) {
      _animationController.forward().then((_) {
        _animationController.reverse();
        widget.onPressed!();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = widget.color ?? theme.colorScheme.primary;
    
    if (widget.isOutlined) {
      return AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: SizedBox(
              height: 52,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.isLoading ? null : _handleTap,
                  borderRadius: BorderRadius.circular(12),
                  splashColor: buttonColor.withOpacity(0.2),
                  highlightColor: buttonColor.withOpacity(0.1),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: buttonColor, width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: _buildButtonContent(buttonColor),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: SizedBox(
            height: 52,
            child: Material(
              color: buttonColor,
              borderRadius: BorderRadius.circular(12),
              elevation: 0,
              child: InkWell(
                onTap: widget.isLoading ? null : _handleTap,
                borderRadius: BorderRadius.circular(12),
                splashColor: Colors.white.withOpacity(0.2),
                highlightColor: Colors.white.withOpacity(0.1),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: _buildButtonContent(Colors.white),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildButtonContent(Color textColor) {
    if (widget.isLoading) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: SizedBox(
          height: 20,
          width: 20,
          child: TweenAnimationBuilder<double>(
            key: const ValueKey('loading'),
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1000),
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value * 2 * 3.14159,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              );
            },
            onEnd: () {
              // Restart the animation
              if (widget.isLoading) {
                setState(() {});
              }
            },
          ),
        ),
      );
    }

    if (widget.icon != null) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Row(
          key: const ValueKey('icon_text'),
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, size: 20, color: textColor),
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Text(
        key: const ValueKey('text_only'),
        widget.label,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
      ),
    );
  }
} 