import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker_app/app/add_expense/model.dart';
import 'package:expense_tracker_app/app/categories/view.dart';
import 'package:expense_tracker_app/app/error/view.dart';
import 'package:expense_tracker_app/app/manager/app_manager.dart';
import 'package:expense_tracker_app/framework/theme/app.dart';
import 'package:expense_tracker_app/framework/utils/navigator.dart';
import 'package:expense_tracker_app/framework/utils/telemetry.dart';
import 'package:expense_tracker_app/framework/widgets/base/app_alert.dart';
import 'package:expense_tracker_app/framework/widgets/base/app_appbar.dart';
import 'package:expense_tracker_app/framework/widgets/base/app_button.dart';
import 'package:expense_tracker_app/framework/widgets/base/app_field_preview.dart';
import 'package:expense_tracker_app/framework/widgets/base/app_input_currency.dart';
import 'package:expense_tracker_app/framework/widgets/base/app_input_text.dart';

class AddExpenseView extends StatefulWidget {
  const AddExpenseView({super.key});

  @override
  State<AddExpenseView> createState() => _AddExpenseViewState();
}

class _AddExpenseViewState extends State<AddExpenseView> {
  static const String tag = 'AddExpenseView';

  late final AddExpenseViewModel _viewModel;
  final FocusNode _amountFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _viewModel = AddExpenseViewModel();
    _viewModel.init();
    Telemetry.trackView(tag, 'init');
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  void exit() {
    Telemetry.trackView(tag, 'GoBack');
    Navigator.pop(context);
  }

  Future<void> pickCategory() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final reply = await AppNavigator.navigateAndWait(
      view: CategoriesSelectorView(selectedId: _viewModel.categoryIdDraft),
    );
    if (reply is! Map<String, dynamic>) return;
    _viewModel.setCategory(reply);
    Telemetry.trackView(
      tag,
      'button_tap',
      metadata: {'button_name': 'category', 'value': reply['name']},
    );
  }

  Future<void> pickDate() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _viewModel.spentAtDraft ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      locale: const Locale('es'),
    );
    if (picked == null) return;
    _viewModel.setSpentAt(picked);
    Telemetry.trackView(
      tag,
      'button_tap',
      metadata: {'button_name': 'date', 'value': picked.toIso8601String()},
    );
  }

  Future<void> save() async {
    Telemetry.trackView(
      tag,
      'button_tap',
      metadata: {'button_name': 'save'},
    );
    try {
      await _viewModel.save();
      if (!mounted) return;
      Navigator.pop(context, true);
    } on StateError catch (e) {
      if (e.message == 'validation') return;
      if (!mounted) return;
      await showAlert(
        context,
        title: 'No se pudo guardar',
        body: 'Revisa los datos e intenta de nuevo.',
      );
    } catch (e, st) {
      Telemetry.trackError(tag, 'save', e, st);
      if (!mounted) return;
      AppNavigator.navigateAndReplaceAll(view: const ErrorView());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final categoryLabel = AppManager()
                .findCategoryById(_viewModel.categoryIdDraft)?['name']
                as String? ??
            '';
        final dateLabel = _viewModel.spentAtDraft == null
            ? ''
            : DateFormat.yMMMMd('es').format(_viewModel.spentAtDraft!);
        return Scaffold(
          backgroundColor: AppTheme.COLOR_WHITE,
          appBar: AppAppBar(title: 'Nuevo gasto', onBack: exit),
          body: SafeArea(
            child: Padding(
              padding: AppTheme.MARGINS_ALL,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        AppInputCurrency(
                          label: 'Monto',
                          valueCents: _viewModel.amountCents,
                          errorText: _viewModel.amountError,
                          focusNode: _amountFocus,
                          onChanged: _viewModel.setAmount,
                        ),
                        AppTheme.SPACE_VERTICAL_2x,
                        AppFieldPreview(
                          label: 'Categoría',
                          value: categoryLabel,
                          errorText: _viewModel.categoryError,
                          onTap: pickCategory,
                        ),
                        AppTheme.SPACE_VERTICAL_2x,
                        AppFieldPreview(
                          label: 'Fecha',
                          value: dateLabel,
                          errorText: _viewModel.dateError,
                          trailingIcon: Icons.calendar_today,
                          onTap: pickDate,
                        ),
                        AppTheme.SPACE_VERTICAL_2x,
                        AppInputText(
                          label: 'Nota',
                          value: _viewModel.noteDraft,
                          errorText: _viewModel.noteError,
                          hint: 'Opcional',
                          maxLength: 80,
                          onChanged: _viewModel.setNote,
                        ),
                      ],
                    ),
                  ),
                  AppButton(
                    label: 'Guardar gasto',
                    isLoading: _viewModel.isSaving,
                    onPressed: _viewModel.isSaving ? null : save,
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
