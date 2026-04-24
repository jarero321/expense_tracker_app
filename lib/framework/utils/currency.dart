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
}
