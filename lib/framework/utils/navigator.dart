import 'package:flutter/material.dart';

class AppRouteObserver {
  static final RouteObserver<PageRoute> routeObserver =
      RouteObserver<PageRoute>();
}

class AppNavigator {
  static BuildContext get _rootContext {
    final navigator = AppRouteObserver.routeObserver.navigator;
    if (navigator == null) {
      throw StateError('AppRouteObserver is not attached to a Navigator');
    }
    return navigator.context;
  }

  static void navigateToWidget({required Widget view, BuildContext? context}) {
    try {
      Navigator.push(
        context ?? _rootContext,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => view,
          transitionDuration: Duration.zero,
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<dynamic> navigateAndWait({required Widget view}) async {
    try {
      return await Navigator.push(
        _rootContext,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => view,
          transitionDuration: Duration.zero,
          opaque: false,
          barrierColor: Colors.black54,
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  static void navigateAndReplaceAll({
    required Widget view,
    BuildContext? context,
  }) {
    try {
      Navigator.pushAndRemoveUntil(
        context ?? _rootContext,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => view,
          transitionDuration: Duration.zero,
        ),
        (route) => false,
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
