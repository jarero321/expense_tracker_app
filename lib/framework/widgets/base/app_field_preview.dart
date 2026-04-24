import 'package:flutter/material.dart';
import 'package:expense_tracker_app/framework/theme/app.dart';

class AppFieldPreview extends StatelessWidget {
  final String label;
  final String value;
  final String placeholder;
  final String errorText;
  final IconData trailingIcon;
  final VoidCallback onTap;

  const AppFieldPreview({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.placeholder = 'Selecciona',
    this.errorText = '',
    this.trailingIcon = Icons.expand_more,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText.isNotEmpty;
    final hasValue = value.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.font(
            size: FONT_SIZE.SMALL,
            style: FONT_STYLE.SEMIBOLD,
            color: AppTheme.COLOR_BLACK_LIGHT,
          ),
        ),
        AppTheme.SPACE_VERTICAL,
        Material(
          color: AppTheme.COLOR_CLEAR_SNOW,
          borderRadius: AppTheme.RADIUS_MEDIUM,
          child: InkWell(
            borderRadius: AppTheme.RADIUS_MEDIUM,
            onTap: onTap,
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: AppTheme.RADIUS_MEDIUM,
                border: Border.all(
                  color: hasError
                      ? AppTheme.COLOR_DANGER
                      : AppTheme.COLOR_GRAY_MANATEE,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      hasValue ? value : placeholder,
                      style: AppTheme.font(
                        size: FONT_SIZE.H4,
                        color: hasValue
                            ? AppTheme.COLOR_BLACK
                            : AppTheme.COLOR_NEUTRAL_LIGHT,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    trailingIcon,
                    color: AppTheme.COLOR_BLACK_LIGHT,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            errorText,
            style: AppTheme.font(
              size: FONT_SIZE.SMALL,
              color: AppTheme.COLOR_DANGER,
            ),
          ),
        ],
      ],
    );
  }
}
