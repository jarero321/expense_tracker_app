import 'package:flutter/foundation.dart';
import 'package:expense_tracker_app/app/manager/app_manager.dart';
import 'package:expense_tracker_app/framework/utils/database.dart';

class HomeViewModel extends ChangeNotifier {
  final manager = AppManager();

  bool isLoading = false;

  static String monthKey(int year, int month) {
    final m = month.toString().padLeft(2, '0');
    return '$year-$m';
  }

  static DateTime firstDayOf(int year, int month) => DateTime(year, month, 1);

  static DateTime firstDayOfNext(int year, int month) {
    if (month == 12) return DateTime(year + 1, 1, 1);
    return DateTime(year, month + 1, 1);
  }

  Future<void> init() async {
    isLoading = true;
    notifyListeners();
    await _loadCategories();
    await _loadMonth();
    isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    await _loadCategories();
    await _loadMonth();
    notifyListeners();
  }

  void setFilter(int? categoryId) {
    manager.activeCategoryFilterId = categoryId;
    notifyListeners();
  }

  void stepMonth(int delta) {
    var m = manager.selectedMonth + delta;
    var y = manager.selectedYear;
    if (m < 1) {
      m = 12;
      y -= 1;
    } else if (m > 12) {
      m = 1;
      y += 1;
    }
    manager.selectedMonth = m;
    manager.selectedYear = y;
    _loadMonth();
  }

  Future<void> deleteExpense(int id) async {
    final db = await AppDatabase.instance();
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
    await _loadMonth();
    notifyListeners();
  }

  List<Map<String, dynamic>> get visibleExpenses {
    final filter = manager.activeCategoryFilterId;
    if (filter == null) return manager.expenses;
    return manager.expenses
        .where((e) => e['category_id'] == filter)
        .toList(growable: false);
  }

  Future<void> _loadCategories() async {
    final db = await AppDatabase.instance();
    final rows = await db.query('categories', orderBy: 'name ASC');
    manager.categories = List<Map<String, dynamic>>.from(rows);
  }

  Future<void> _loadMonth() async {
    final db = await AppDatabase.instance();
    final start = firstDayOf(manager.selectedYear, manager.selectedMonth);
    final end = firstDayOfNext(manager.selectedYear, manager.selectedMonth);
    final rows = await db.query(
      'expenses',
      where: 'spent_at >= ? AND spent_at < ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'spent_at DESC',
    );
    manager.expenses = List<Map<String, dynamic>>.from(rows);
    var total = 0;
    for (final e in manager.expenses) {
      total += (e['amount_cents'] as int);
    }
    manager.monthlyTotalCents = total;
  }
}
