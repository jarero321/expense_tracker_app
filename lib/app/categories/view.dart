import 'package:flutter/material.dart';
import 'package:expense_tracker_app/app/categories/model.dart';
import 'package:expense_tracker_app/framework/theme/app.dart';
import 'package:expense_tracker_app/framework/utils/telemetry.dart';
import 'package:expense_tracker_app/framework/widgets/base/app_alert.dart';
import 'package:expense_tracker_app/framework/widgets/base/app_appbar.dart';
import 'package:expense_tracker_app/framework/widgets/base/app_button.dart';
import 'package:expense_tracker_app/framework/widgets/base/app_input_text.dart';

class CategoriesSelectorView extends StatefulWidget {
  final int? selectedId;

  const CategoriesSelectorView({super.key, this.selectedId});

  @override
  State<CategoriesSelectorView> createState() => _CategoriesSelectorViewState();
}

class _CategoriesSelectorViewState extends State<CategoriesSelectorView> {
  static const String tag = 'CategoriesSelectorView';

  late final CategoriesViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = CategoriesViewModel();
    _viewModel.init();
    Telemetry.trackView(tag, 'init');
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void exit() {
    Telemetry.trackView(tag, 'GoBack');
    Navigator.pop(context);
  }

  void selectCategory(Map<String, dynamic> category) {
    Telemetry.trackView(
      tag,
      'button_tap',
      metadata: {'button_name': 'category', 'value': category['name']},
    );
    Navigator.pop(context, category);
  }

  Future<void> createFromDraft() async {
    final ok = await _viewModel.addCategory();
    if (!mounted || !ok) return;
    Telemetry.trackView(tag, 'button_tap', metadata: {'button_name': 'create'});
    FocusManager.instance.primaryFocus?.unfocus();
  }

  Future<void> confirmDelete(Map<String, dynamic> category) async {
    try {
      await _viewModel.deleteCategory(category['id'] as int);
    } catch (e) {
      if (!mounted) return;
      await showAlert(
        context,
        title: 'No se puede borrar',
        body: 'Hay gastos registrados con esta categoría.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppTheme.COLOR_WHITE,
          appBar: AppAppBar(title: 'Categorías', onBack: exit),
          body: SafeArea(
            child: Padding(
              padding: AppTheme.MARGINS_ALL,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _CreateField(viewModel: _viewModel, onSubmit: createFromDraft),
                  AppTheme.SPACE_VERTICAL_3x,
                  Text(
                    'Existentes',
                    style: AppTheme.font(
                      size: FONT_SIZE.SMALL,
                      style: FONT_STYLE.SEMIBOLD,
                      color: AppTheme.COLOR_BLACK_LIGHT,
                    ),
                  ),
                  AppTheme.SPACE_VERTICAL,
                  Expanded(
                    child: _viewModel.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _List(
                            items: _viewModel.manager.categories,
                            selectedId: widget.selectedId,
                            onSelect: selectCategory,
                            onDelete: confirmDelete,
                          ),
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

class _CreateField extends StatelessWidget {
  final CategoriesViewModel viewModel;
  final VoidCallback onSubmit;

  const _CreateField({required this.viewModel, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInputText(
          label: 'Nueva categoría',
          value: viewModel.nameDraft,
          errorText: viewModel.nameError,
          hint: 'Ej. Suscripciones',
          onChanged: viewModel.setNameDraft,
          maxLength: 40,
        ),
        AppTheme.SPACE_VERTICAL_2x,
        AppButton(
          label: 'Agregar',
          icon: Icons.add,
          onPressed: viewModel.nameDraft.trim().isEmpty ? null : onSubmit,
        ),
      ],
    );
  }
}

class _List extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final int? selectedId;
  final ValueChanged<Map<String, dynamic>> onSelect;
  final ValueChanged<Map<String, dynamic>> onDelete;

  const _List({
    required this.items,
    required this.selectedId,
    required this.onSelect,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          'Aún no hay categorías',
          style: AppTheme.font(
            size: FONT_SIZE.PARAGRAPH,
            color: AppTheme.COLOR_NEUTRAL_LIGHT,
          ),
        ),
      );
    }
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => AppTheme.SPACE_VERTICAL,
      itemBuilder: (context, index) {
        final category = items[index];
        final isSelected = selectedId == category['id'];
        return _Row(
          category: category,
          isSelected: isSelected,
          onSelect: () => onSelect(category),
          onDelete: () => onDelete(category),
        );
      },
    );
  }
}

class _Row extends StatelessWidget {
  final Map<String, dynamic> category;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onDelete;

  const _Row({
    required this.category,
    required this.isSelected,
    required this.onSelect,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse(category['color_hex'] as String, radix: 16));
    return Material(
      color: isSelected
          ? AppTheme.COLOR_PRIMARY_BACKGROUND
          : AppTheme.COLOR_CLEAR_SNOW,
      borderRadius: AppTheme.RADIUS_MEDIUM,
      child: InkWell(
        borderRadius: AppTheme.RADIUS_MEDIUM,
        onTap: onSelect,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: AppTheme.RADIUS_SMALL,
                ),
                child: Icon(
                  IconData(
                    category['icon_code'] as int,
                    fontFamily: 'MaterialIcons',
                  ),
                  color: color,
                  size: 20,
                ),
              ),
              AppTheme.SPACE_HORIZONTAL_2x,
              Expanded(
                child: Text(
                  category['name'] as String,
                  style: AppTheme.font(
                    size: FONT_SIZE.H4,
                    style: FONT_STYLE.SEMIBOLD,
                  ),
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppTheme.COLOR_BLACK_LIGHT,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
