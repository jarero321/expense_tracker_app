import 'package:intl/intl.dart';

class AppCurrency {
  static final NumberFormat _pesos = NumberFormat.currency(
    locale: 'es_MX',
    symbol: r'$',
    decimalDigits: 2,
  );

  static String formatCents(int cents) {
    return _pesos.format(cents / 100);
  }

  static int? parseToCents(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'[^0-9.,]'), '').replaceAll(',', '');
    if (cleaned.isEmpty) return null;
    final value = double.tryParse(cleaned);
    if (value == null) return null;
    if (value < 0) return null;
    return (value * 100).round();
  }
}
