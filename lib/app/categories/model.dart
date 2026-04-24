import 'package:flutter/foundation.dart';
import 'package:expense_tracker_app/app/manager/app_manager.dart';
import 'package:expense_tracker_app/framework/utils/database.dart';

class CategoriesViewModel extends ChangeNotifier {
  static const String nameEmptyError = 'El nombre no puede estar vacío';
  static const String nameShortError = 'Mínimo 2 caracteres';
  static const String nameDuplicateError = 'Ya existe una categoría con ese nombre';

  static String validateName(String raw, List<Map<String, dynamic>> existing) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return nameEmptyError;
    if (trimmed.length < 2) return nameShortError;
    final lower = trimmed.toLowerCase();
    for (final c in existing) {
      final current = (c['name'] as String).toLowerCase();
      if (current == lower) return nameDuplicateError;
    }
    return '';
  }

  final manager = AppManager();

  bool isLoading = false;
  String nameDraft = '';
  String nameError = '';

  Future<void> init() async {
    isLoading = true;
    notifyListeners();
    final db = await AppDatabase.instance();
    final rows = await db.query('categories', orderBy: 'name ASC');
    manager.categories = List<Map<String, dynamic>>.from(rows);
    isLoading = false;
    notifyListeners();
  }

  void setNameDraft(String value) {
    nameDraft = value;
    nameError = '';
    notifyListeners();
  }

  Future<bool> addCategory() async {
    final err = validateName(nameDraft, manager.categories);
    if (err.isNotEmpty) {
      nameError = err;
      notifyListeners();
      return false;
    }
    final db = await AppDatabase.instance();
    await db.insert('categories', {
      'name': nameDraft.trim(),
      'color_hex': 'FF7F8081',
      'icon_code': 0xe53f,
    });
    nameDraft = '';
    await _refresh();
    return true;
  }

  Future<void> deleteCategory(int id) async {
    final db = await AppDatabase.instance();
    final inUse = await db.query(
      'expenses',
      where: 'category_id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (inUse.isNotEmpty) {
      throw StateError('Categoría en uso');
    }
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
    await _refresh();
  }

  Future<void> _refresh() async {
    final db = await AppDatabase.instance();
    final rows = await db.query('categories', orderBy: 'name ASC');
    manager.categories = List<Map<String, dynamic>>.from(rows);
    notifyListeners();
  }
}
