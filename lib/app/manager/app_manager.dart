class AppManager {
  static final AppManager _instance = AppManager._internal();
  AppManager._internal();
  factory AppManager() => _instance;

  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> expenses = [];

  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  int? activeCategoryFilterId;

  int monthlyTotalCents = 0;

  bool didBootstrap = false;

  void reset() {
    categories = [];
    expenses = [];
    activeCategoryFilterId = null;
    monthlyTotalCents = 0;
    didBootstrap = false;
  }

  Map<String, dynamic>? findCategoryById(int? id) {
    if (id == null) return null;
    for (final c in categories) {
      if (c['id'] == id) return c;
    }
    return null;
  }
}
