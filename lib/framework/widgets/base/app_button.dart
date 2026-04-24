import 'package:flutter/material.dart';
import 'package:expense_tracker_app/framework/theme/app.dart';

enum APP_BUTTON_VARIANT { PRIMARY, SECONDARY, DANGER }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final APP_BUTTON_VARIANT variant;
  final bool isLoading;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = APP_BUTTON_VARIANT.PRIMARY,
    this.isLoading = false,
    this.icon,
  });

  Color get _background {
    switch (variant) {
      case APP_BUTTON_VARIANT.PRIMARY:
        return AppTheme.COLOR_PRIMARY;
      case APP_BUTTON_VARIANT.SECONDARY:
        return AppTheme.COLOR_GRAY_MANATEE;
      case APP_BUTTON_VARIANT.DANGER:
        return AppTheme.COLOR_DANGER;
    }
  }

  Color get _foreground {
    switch (variant) {
      case APP_BUTTON_VARIANT.PRIMARY:
      case APP_BUTTON_VARIANT.DANGER:
        return AppTheme.COLOR_WHITE;
      case APP_BUTTON_VARIANT.SECONDARY:
        return AppTheme.COLOR_BLACK;
    }
  }

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || isLoading;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Material(
        color: disabled
            ? _background.withValues(alpha: 0.5)
            : _background,
        borderRadius: AppTheme.RADIUS_MEDIUM,
        child: InkWell(
          borderRadius: AppTheme.RADIUS_MEDIUM,
          onTap: disabled ? null : onPressed,
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(_foreground),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: _foreground, size: 18),
                        AppTheme.SPACE_HORIZONTAL,
                      ],
                      Text(
                        label,
                        style: AppTheme.font(
                          size: FONT_SIZE.H4,
                          style: FONT_STYLE.SEMIBOLD,
                          color: _foreground,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
