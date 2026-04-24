import 'package:flutter/material.dart';
import 'package:expense_tracker_app/framework/theme/app.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;

  const AppAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.COLOR_WHITE,
      surfaceTintColor: AppTheme.COLOR_WHITE,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: onBack == null
          ? null
          : IconButton(
              onPressed: onBack,
              icon: const Icon(
                Icons.chevron_left,
                color: AppTheme.COLOR_BLACK,
              ),
            ),
      title: Text(
        title,
        style: AppTheme.font(size: FONT_SIZE.H4, style: FONT_STYLE.SEMIBOLD),
      ),
      actions: [
        if (trailing != null) trailing!,
        AppTheme.SPACE_HORIZONTAL,
      ],
    );
  }
}
