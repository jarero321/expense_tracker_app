import 'package:flutter/foundation.dart';
import 'package:expense_tracker_app/app/manager/app_manager.dart';
import 'package:expense_tracker_app/framework/utils/database.dart';

class AddExpenseViewModel extends ChangeNotifier {
  static const String amountZeroError = 'Ingresa un monto mayor a cero';
  static const String categoryEmptyError = 'Selecciona una categoría';
  static const String dateEmptyError = 'Selecciona la fecha';
  static const String noteLongError = 'Máximo 80 caracteres';

  static String validateAmount(int cents) =>
      cents <= 0 ? amountZeroError : '';

  static String validateNote(String raw) =>
      raw.length > 80 ? noteLongError : '';

  final manager = AppManager();

  int amountCents = 0;
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

  void setAmount(int cents) {
    amountCents = cents;
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
    amountError = validateAmount(amountCents);
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
        'amount_cents': amountCents,
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
