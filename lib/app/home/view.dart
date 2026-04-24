import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker_app/app/add_expense/view.dart';
import 'package:expense_tracker_app/app/categories/view.dart';
import 'package:expense_tracker_app/app/error/view.dart';
import 'package:expense_tracker_app/app/home/model.dart';
import 'package:expense_tracker_app/framework/theme/app.dart';
import 'package:expense_tracker_app/framework/utils/currency.dart';
import 'package:expense_tracker_app/framework/utils/navigator.dart';
import 'package:expense_tracker_app/framework/utils/telemetry.dart';
import 'package:expense_tracker_app/framework/widgets/base/app_alert.dart';
import 'package:expense_tracker_app/framework/widgets/base/app_appbar.dart';
import 'package:expense_tracker_app/framework/widgets/base/app_button.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  static const String tag = 'HomeView';

  late final HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel();
    _bootstrap();
    Telemetry.trackView(tag, 'init');
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    try {
      await _viewModel.init();
    } catch (e, st) {
      Telemetry.trackError(tag, 'bootstrap', e, st);
      if (!mounted) return;
      AppNavigator.navigateAndReplaceAll(view: const ErrorView());
    }
  }

  Future<void> openAddExpense() async {
    Telemetry.trackView(tag, 'button_tap', metadata: {'button_name': 'add'});
    AppNavigator.navigateToWidget(view: const AddExpenseView());
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    await _viewModel.refresh();
  }

  Future<void> openCategoryFilter() async {
    Telemetry.trackView(
      tag,
      'button_tap',
      metadata: {'button_name': 'filter'},
    );
    final reply = await AppNavigator.navigateAndWait(
      view: CategoriesSelectorView(
        selectedId: _viewModel.manager.activeCategoryFilterId,
      ),
    );
    if (reply is! Map<String, dynamic>) return;
    _viewModel.setFilter(reply['id'] as int);
  }

  void clearFilter() {
    Telemetry.trackView(
      tag,
      'button_tap',
      metadata: {'button_name': 'filter_clear'},
    );
    _viewModel.setFilter(null);
  }

  void prevMonth() => _viewModel.stepMonth(-1);
  void nextMonth() => _viewModel.stepMonth(1);

  Future<void> confirmDelete(Map<String, dynamic> expense) async {
    await showAlert(
      context,
      title: 'Borrar gasto',
      body: 'Esta acción no se puede deshacer.',
      continueLabel: 'Borrar',
      continueCallBack: () => _viewModel.deleteExpense(expense['id'] as int),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final monthDate = HomeViewModel.firstDayOf(
          _viewModel.manager.selectedYear,
          _viewModel.manager.selectedMonth,
        );
        final monthLabel = DateFormat.yMMMM('es').format(monthDate);
        final activeFilter = _viewModel.manager.findCategoryById(
          _viewModel.manager.activeCategoryFilterId,
        );
        return Scaffold(
          backgroundColor: AppTheme.COLOR_WHITE,
          appBar: AppAppBar(
            title: 'Mis gastos',
            trailing: IconButton(
              onPressed: openCategoryFilter,
              icon: Icon(
                activeFilter == null
                    ? Icons.filter_list
                    : Icons.filter_list_alt,
                color: activeFilter == null
                    ? AppTheme.COLOR_BLACK
                    : AppTheme.COLOR_PRIMARY,
              ),
            ),
          ),
          body: SafeArea(
            child: _viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: AppTheme.MARGINS_ALL,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _MonthSummary(
                          label: monthLabel,
                          totalCents: _viewModel.manager.monthlyTotalCents,
                          onPrev: prevMonth,
                          onNext: nextMonth,
                        ),
                        if (activeFilter != null) ...[
                          AppTheme.SPACE_VERTICAL_2x,
                          _FilterChip(
                            label: activeFilter['name'] as String,
                            onClear: clearFilter,
                          ),
                        ],
                        AppTheme.SPACE_VERTICAL_2x,
                        Expanded(
                          child: _ExpenseList(
                            items: _viewModel.visibleExpenses,
                            manager: _viewModel.manager,
                            onLongPress: confirmDelete,
                          ),
                        ),
                        AppTheme.SPACE_VERTICAL_2x,
                        AppButton(
                          label: 'Registrar gasto',
                          icon: Icons.add,
                          onPressed: openAddExpense,
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class _MonthSummary extends StatelessWidget {
  final String label;
  final int totalCents;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _MonthSummary({
    required this.label,
    required this.totalCents,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppTheme.MARGINS_ALL,
      decoration: BoxDecoration(
        color: AppTheme.COLOR_PRIMARY_BACKGROUND,
        borderRadius: AppTheme.RADIUS_LARGE,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onPrev,
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTheme.font(
                    size: FONT_SIZE.H4,
                    style: FONT_STYLE.SEMIBOLD,
                    color: AppTheme.COLOR_PRIMARY_DARK,
                  ),
                ),
              ),
              IconButton(
                onPressed: onNext,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          AppTheme.SPACE_VERTICAL,
          Text(
            'Total del mes',
            textAlign: TextAlign.center,
            style: AppTheme.font(
              size: FONT_SIZE.SMALL,
              color: AppTheme.COLOR_GRAY_CHARCOAL,
            ),
          ),
          AppTheme.SPACE_VERTICAL,
          Text(
            AppCurrency.formatCents(totalCents),
            textAlign: TextAlign.center,
            style: AppTheme.font(
              size: FONT_SIZE.H1,
              style: FONT_STYLE.BOLD,
              color: AppTheme.COLOR_PRIMARY_DARK,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onClear;

  const _FilterChip({required this.label, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: AppTheme.COLOR_GRAY_MANATEE,
        borderRadius: AppTheme.RADIUS_LARGE,
        child: InkWell(
          borderRadius: AppTheme.RADIUS_LARGE,
          onTap: onClear,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTheme.font(
                    size: FONT_SIZE.SMALL,
                    style: FONT_STYLE.SEMIBOLD,
                  ),
                ),
                AppTheme.SPACE_HORIZONTAL,
                const Icon(Icons.close, size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpenseList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final dynamic manager;
  final ValueChanged<Map<String, dynamic>> onLongPress;

  const _ExpenseList({
    required this.items,
    required this.manager,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: AppTheme.COLOR_NEUTRAL_LIGHT,
            ),
            AppTheme.SPACE_VERTICAL,
            Text(
              'Sin gastos este mes',
              style: AppTheme.font(
                size: FONT_SIZE.PARAGRAPH,
                color: AppTheme.COLOR_NEUTRAL_LIGHT,
              ),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => AppTheme.SPACE_VERTICAL,
      itemBuilder: (context, index) {
        final expense = items[index];
        final category = manager.findCategoryById(expense['category_id'] as int)
            as Map<String, dynamic>?;
        return _ExpenseRow(
          expense: expense,
          category: category,
          onLongPress: () => onLongPress(expense),
        );
      },
    );
  }
}

class _ExpenseRow extends StatelessWidget {
  final Map<String, dynamic> expense;
  final Map<String, dynamic>? category;
  final VoidCallback onLongPress;

  const _ExpenseRow({
    required this.expense,
    required this.category,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(expense['spent_at'] as String);
    final dateLabel = DateFormat.MMMd('es').format(date);
    final categoryName = category?['name'] as String? ?? 'Sin categoría';
    final colorHex = category?['color_hex'] as String? ?? 'FF7F8081';
    final color = Color(int.parse(colorHex, radix: 16));
    final iconCode = category?['icon_code'] as int? ?? 0xe53f;
    final note = (expense['note'] as String).trim();

    return Material(
      color: AppTheme.COLOR_CLEAR_SNOW,
      borderRadius: AppTheme.RADIUS_MEDIUM,
      child: InkWell(
        borderRadius: AppTheme.RADIUS_MEDIUM,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: AppTheme.RADIUS_SMALL,
                ),
                child: Icon(
                  IconData(iconCode, fontFamily: 'MaterialIcons'),
                  color: color,
                  size: 22,
                ),
              ),
              AppTheme.SPACE_HORIZONTAL_2x,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.isEmpty ? categoryName : note,
                      style: AppTheme.font(
                        size: FONT_SIZE.H4,
                        style: FONT_STYLE.SEMIBOLD,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$categoryName · $dateLabel',
                      style: AppTheme.font(
                        size: FONT_SIZE.SMALL,
                        color: AppTheme.COLOR_BLACK_LIGHT,
                      ),
                    ),
                  ],
                ),
              ),
              AppTheme.SPACE_HORIZONTAL_2x,
              Text(
                AppCurrency.formatCents(expense['amount_cents'] as int),
                style: AppTheme.font(
                  size: FONT_SIZE.H4,
                  style: FONT_STYLE.BOLD,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
