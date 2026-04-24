import 'package:flutter/material.dart';
import 'package:expense_tracker_app/framework/theme/app.dart';
import 'package:expense_tracker_app/framework/utils/navigator.dart';
import 'package:expense_tracker_app/framework/utils/telemetry.dart';
import 'package:expense_tracker_app/framework/widgets/base/app_button.dart';

class ErrorView extends StatefulWidget {
  const ErrorView({super.key});

  @override
  State<ErrorView> createState() => _ErrorViewState();
}

class _ErrorViewState extends State<ErrorView> {
  static const String tag = 'ErrorView';

  @override
  void initState() {
    super.initState();
    Telemetry.trackView(tag, 'init');
  }

  void retry() {
    Telemetry.trackView(tag, 'button_tap', metadata: {'button_name': 'retry'});
    AppNavigator.navigateAndReplaceAll(view: const _Bootstrapper());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.COLOR_WHITE,
      body: SafeArea(
        child: Padding(
          padding: AppTheme.MARGINS_ALL,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.error_outline,
                size: 72,
                color: AppTheme.COLOR_DANGER,
              ),
              AppTheme.SPACE_VERTICAL_3x,
              Text(
                'Algo salió mal',
                textAlign: TextAlign.center,
                style: AppTheme.font(
                  size: FONT_SIZE.H2,
                  style: FONT_STYLE.BOLD,
                ),
              ),
              AppTheme.SPACE_VERTICAL,
              Text(
                'No pudimos cargar tus gastos. Intenta nuevamente.',
                textAlign: TextAlign.center,
                style: AppTheme.font(
                  size: FONT_SIZE.PARAGRAPH,
                  color: AppTheme.COLOR_GRAY_CHARCOAL,
                ),
              ),
              AppTheme.SPACE_VERTICAL_4x,
              AppButton(label: 'Reintentar', onPressed: retry),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bootstrapper extends StatelessWidget {
  const _Bootstrapper();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppTheme.COLOR_WHITE,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
