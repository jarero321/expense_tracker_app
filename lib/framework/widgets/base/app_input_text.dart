import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expense_tracker_app/framework/theme/app.dart';

class AppInputText extends StatelessWidget {
  final String label;
  final String value;
  final String errorText;
  final String hint;
  final int maxLength;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final ValueChanged<String> onChanged;
  final FocusNode? focusNode;

  const AppInputText({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.errorText = '',
    this.hint = '',
    this.maxLength = 120,
    this.keyboardType = TextInputType.text,
    this.inputFormatters = const [],
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText.isNotEmpty;
    final controller = TextEditingController(text: value);
    controller.selection = TextSelection.collapsed(offset: value.length);

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
        TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          style: AppTheme.font(size: FONT_SIZE.H4),
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
            filled: true,
            fillColor: AppTheme.COLOR_CLEAR_SNOW,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: AppTheme.RADIUS_MEDIUM,
              borderSide: BorderSide(
                color: hasError
                    ? AppTheme.COLOR_DANGER
                    : AppTheme.COLOR_GRAY_MANATEE,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppTheme.RADIUS_MEDIUM,
              borderSide: BorderSide(
                color: hasError
                    ? AppTheme.COLOR_DANGER
                    : AppTheme.COLOR_GRAY_MANATEE,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppTheme.RADIUS_MEDIUM,
              borderSide: BorderSide(
                color: hasError
                    ? AppTheme.COLOR_DANGER
                    : AppTheme.COLOR_PRIMARY,
                width: 1.5,
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
