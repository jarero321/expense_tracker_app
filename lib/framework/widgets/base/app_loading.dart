import 'package:flutter/material.dart';
import 'package:expense_tracker_app/framework/theme/app.dart';

class AppLoadingView extends StatelessWidget {
  const AppLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppTheme.COLOR_WHITE,
      body: Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation(AppTheme.COLOR_PRIMARY),
          ),
        ),
      ),
    );
  }
}
