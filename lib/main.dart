import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:expense_tracker_app/app/home/view.dart';
import 'package:expense_tracker_app/framework/theme/app.dart';
import 'package:expense_tracker_app/framework/utils/navigator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      navigatorObservers: [AppRouteObserver.routeObserver],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es')],
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppTheme.COLOR_WHITE,
        primaryColor: AppTheme.COLOR_PRIMARY,
        fontFamily: 'Roboto',
      ),
      home: const HomeView(),
    );
  }
}
