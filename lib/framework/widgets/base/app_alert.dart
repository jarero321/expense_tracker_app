import 'package:flutter/material.dart';
import 'package:expense_tracker_app/framework/theme/app.dart';
import 'package:expense_tracker_app/framework/widgets/base/app_button.dart';

Future<void> showAlert(
  BuildContext context, {
  required String title,
  required String body,
  String continueLabel = 'Entendido',
  VoidCallback? continueCallBack,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black54,
    builder: (ctx) => Dialog(
      backgroundColor: AppTheme.COLOR_WHITE,
      shape: const RoundedRectangleBorder(borderRadius: AppTheme.RADIUS_LARGE),
      insetPadding: AppTheme.MARGINS_ALL,
      child: Padding(
        padding: AppTheme.MARGINS_ALL,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: AppTheme.font(
                size: FONT_SIZE.H3,
                style: FONT_STYLE.BOLD,
              ),
            ),
            AppTheme.SPACE_VERTICAL_2x,
            Text(
              body,
              style: AppTheme.font(
                size: FONT_SIZE.PARAGRAPH,
                color: AppTheme.COLOR_GRAY_CHARCOAL,
              ),
            ),
            AppTheme.SPACE_VERTICAL_3x,
            AppButton(
              label: continueLabel,
              onPressed: () {
                Navigator.pop(ctx);
                if (continueCallBack != null) continueCallBack();
              },
            ),
          ],
        ),
      ),
    ),
  );
}
