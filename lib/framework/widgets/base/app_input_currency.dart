import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expense_tracker_app/framework/theme/app.dart';
import 'package:expense_tracker_app/framework/utils/currency.dart';

class AppInputCurrency extends StatefulWidget {
  final String label;
  final int valueCents;
  final String errorText;
  final ValueChanged<int> onChanged;
  final FocusNode? focusNode;

  const AppInputCurrency({
    super.key,
    required this.label,
    required this.valueCents,
    required this.onChanged,
    this.errorText = '',
    this.focusNode,
  });

  @override
  State<AppInputCurrency> createState() => _AppInputCurrencyState();
}

class _AppInputCurrencyState extends State<AppInputCurrency> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: AppCurrency.formatCents(widget.valueCents),
    );
  }

  @override
  void didUpdateWidget(covariant AppInputCurrency old) {
    super.didUpdateWidget(old);
    if (widget.valueCents != old.valueCents) {
      final expected = AppCurrency.formatCents(widget.valueCents);
      if (expected != _controller.text) {
        _controller.value = TextEditingValue(
          text: expected,
          selection: TextSelection.collapsed(offset: expected.length),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void handleChange(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    final parsed = digits.isEmpty ? 0 : int.tryParse(digits) ?? 0;
    final clamped = parsed > _CurrencyInputFormatter._maxCents
        ? _CurrencyInputFormatter._maxCents
        : parsed;
    widget.onChanged(clamped);
  }

  void snapCursorToEnd() {
    _controller.selection = TextSelection.collapsed(
      offset: _controller.text.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTheme.font(
            size: FONT_SIZE.SMALL,
            style: FONT_STYLE.SEMIBOLD,
            color: AppTheme.COLOR_BLACK_LIGHT,
          ),
        ),
        AppTheme.SPACE_VERTICAL,
        TextField(
          controller: _controller,
          focusNode: widget.focusNode,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: false,
            signed: false,
          ),
          inputFormatters: const [_CurrencyInputFormatter()],
          onChanged: handleChange,
          onTap: snapCursorToEnd,
          textAlign: TextAlign.right,
          style: AppTheme.font(size: FONT_SIZE.H2, style: FONT_STYLE.BOLD),
          decoration: InputDecoration(
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
            widget.errorText,
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

class _CurrencyInputFormatter extends TextInputFormatter {
  static const int _maxCents = 9999999999;

  const _CurrencyInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final parsed = digits.isEmpty ? 0 : int.tryParse(digits) ?? 0;
    final clamped = parsed > _maxCents ? _maxCents : parsed;
    final formatted = AppCurrency.formatCents(clamped);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
