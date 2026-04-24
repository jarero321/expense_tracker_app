import 'package:flutter/foundation.dart';
import 'package:expense_tracker_app/app/manager/app_manager.dart';
import 'package:expense_tracker_app/framework/utils/currency.dart';
import 'package:expense_tracker_app/framework/utils/database.dart';

class AddExpenseViewModel extends ChangeNotifier {
  static const String amountEmptyError = 'Ingresa el monto';
  static const String amountInvalidError = 'Monto no válido';
  static const String amountZeroError = 'El monto debe ser mayor a cero';
  static const String categoryEmptyError = 'Selecciona una categoría';
  static const String dateEmptyError = 'Selecciona la fecha';
  static const String noteLongError = 'Máximo 80 caracteres';

  static String validateAmount(String raw) {
    if (raw.trim().isEmpty) return amountEmptyError;
    final cents = AppCurrency.parseToCents(raw);
    if (cents == null) return amountInvalidError;
    if (cents == 0) return amountZeroError;
    return '';
  }

  static String validateNote(String raw) {
    if (raw.length > 80) return noteLongError;
    return '';
  }

  final manager = AppManager();

  String amountDraft = '';
  String noteDraft = '';
  int? categoryIdDraft;
  DateTime? spentAtDraft;

  String amountError = '';
  String noteError = '';
  String categoryError = '';
  String dateError = '';

  bool isSaving = false;

  void init() {
    spentAtDraft = DateTime.now();
  }

  void setAmount(String value) {
    amountDraft = value;
    amountError = '';
    notifyListeners();
  }

  void setNote(String value) {
    noteDraft = value;
    noteError = validateNote(value);
    notifyListeners();
  }

  void setCategory(Map<String, dynamic> category) {
    categoryIdDraft = category['id'] as int;
    categoryError = '';
    notifyListeners();
  }

  void setSpentAt(DateTime date) {
    spentAtDraft = date;
    dateError = '';
    notifyListeners();
  }

  bool _refreshAllErrors() {
    amountError = validateAmount(amountDraft);
    noteError = validateNote(noteDraft);
    categoryError = categoryIdDraft == null ? categoryEmptyError : '';
    dateError = spentAtDraft == null ? dateEmptyError : '';
    notifyListeners();
    return amountError.isEmpty &&
        noteError.isEmpty &&
        categoryError.isEmpty &&
        dateError.isEmpty;
  }

  Future<void> save() async {
    if (!_refreshAllErrors()) {
      throw StateError('validation');
    }
    isSaving = true;
    notifyListeners();
    try {
      final db = await AppDatabase.instance();
      await db.insert('expenses', {
        'amount_cents': AppCurrency.parseToCents(amountDraft),
        'note': noteDraft.trim(),
        'category_id': categoryIdDraft,
        'spent_at': spentAtDraft!.toIso8601String(),
      });
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
