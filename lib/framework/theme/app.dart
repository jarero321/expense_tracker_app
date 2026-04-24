import 'package:flutter/material.dart';

enum FONT_SIZE { H0, H1, H2, H3, H4, PARAGRAPH, SMALL, TINY }

enum FONT_STYLE { REGULAR, BOLD, SEMIBOLD }

enum FONT_DECORATION { UNDERLINE, LINE_THROUGH, OVERLINE, NONE }

class AppTheme {
  static const Color COLOR_BLACK = Color(0xFF0A0C10);
  static const Color COLOR_BLACK_LIGHT = Color(0xFF7F8081);
  static const Color COLOR_WHITE = Color(0xFFFFFFFF);
  static const Color COLOR_CLEAR_SNOW = Color(0xFFFAFAFA);
  static const Color COLOR_NEUTRAL_LIGHT = Color(0xFF969BA0);
  static const Color COLOR_GRAY_HOVER = Color(0xFFC0C1C2);
  static const Color COLOR_GRAY_MANATEE = Color(0xFFEDF0F4);
  static const Color COLOR_GRAY_CHARCOAL = Color(0xFF3E3E42);
  static const Color COLOR_PRIMARY = Color(0xFF4B6BFB);
  static const Color COLOR_PRIMARY_DARK = Color(0xFF1E3FD6);
  static const Color COLOR_PRIMARY_BACKGROUND = Color(0xFFE8EDFF);
  static const Color COLOR_SUCCESS = Color(0xFF00A878);
  static const Color COLOR_DANGER = Color(0xFFD64545);
  static const Color COLOR_DANGER_LIGHT = Color(0xFFFDD4CE);

  static const double _FONT_SIZE_H0 = 38.0;
  static const double _FONT_SIZE_H1 = 32.0;
  static const double _FONT_SIZE_H2 = 24.0;
  static const double _FONT_SIZE_H3 = 18.0;
  static const double _FONT_SIZE_H4 = 16.0;
  static const double _FONT_SIZE_PARAGRAPH = 14.0;
  static const double _FONT_SIZE_SMALL = 12.0;
  static const double _FONT_SIZE_TINY = 10.0;

  static const EdgeInsets MARGINS = EdgeInsets.symmetric(horizontal: 16);
  static const EdgeInsets MARGINS_ALL = EdgeInsets.all(16);

  static const SizedBox SPACE_HORIZONTAL = SizedBox(width: 8);
  static const SizedBox SPACE_HORIZONTAL_2x = SizedBox(width: 16);
  static const SizedBox SPACE_HORIZONTAL_3x = SizedBox(width: 24);

  static const SizedBox SPACE_VERTICAL = SizedBox(height: 8);
  static const SizedBox SPACE_VERTICAL_2x = SizedBox(height: 16);
  static const SizedBox SPACE_VERTICAL_3x = SizedBox(height: 24);
  static const SizedBox SPACE_VERTICAL_4x = SizedBox(height: 32);

  static const BorderRadius RADIUS_SMALL = BorderRadius.all(Radius.circular(8));
  static const BorderRadius RADIUS_MEDIUM = BorderRadius.all(
    Radius.circular(12),
  );
  static const BorderRadius RADIUS_LARGE = BorderRadius.all(
    Radius.circular(20),
  );

  static TextStyle font({
    required FONT_SIZE size,
    FONT_STYLE style = FONT_STYLE.REGULAR,
    FONT_DECORATION decoration = FONT_DECORATION.NONE,
    Color color = COLOR_BLACK,
  }) {
    return TextStyle(
      fontSize: _fontSize(size),
      fontWeight: _fontWeight(style),
      decoration: _fontDecoration(decoration),
      color: color,
      letterSpacing: _letterSpacing(size),
      height: 1.25,
    );
  }

  static double _fontSize(FONT_SIZE size) {
    switch (size) {
      case FONT_SIZE.H0:
        return _FONT_SIZE_H0;
      case FONT_SIZE.H1:
        return _FONT_SIZE_H1;
      case FONT_SIZE.H2:
        return _FONT_SIZE_H2;
      case FONT_SIZE.H3:
        return _FONT_SIZE_H3;
      case FONT_SIZE.H4:
        return _FONT_SIZE_H4;
      case FONT_SIZE.PARAGRAPH:
        return _FONT_SIZE_PARAGRAPH;
      case FONT_SIZE.SMALL:
        return _FONT_SIZE_SMALL;
      case FONT_SIZE.TINY:
        return _FONT_SIZE_TINY;
    }
  }

  static FontWeight _fontWeight(FONT_STYLE style) {
    switch (style) {
      case FONT_STYLE.REGULAR:
        return FontWeight.w400;
      case FONT_STYLE.SEMIBOLD:
        return FontWeight.w600;
      case FONT_STYLE.BOLD:
        return FontWeight.w700;
    }
  }

  static TextDecoration _fontDecoration(FONT_DECORATION decoration) {
    switch (decoration) {
      case FONT_DECORATION.NONE:
        return TextDecoration.none;
      case FONT_DECORATION.UNDERLINE:
        return TextDecoration.underline;
      case FONT_DECORATION.LINE_THROUGH:
        return TextDecoration.lineThrough;
      case FONT_DECORATION.OVERLINE:
        return TextDecoration.overline;
    }
  }

  static double _letterSpacing(FONT_SIZE size) {
    switch (size) {
      case FONT_SIZE.H0:
      case FONT_SIZE.H1:
        return -1.0;
      case FONT_SIZE.H2:
        return -0.24;
      case FONT_SIZE.H3:
        return -0.09;
      case FONT_SIZE.H4:
        return -0.06;
      case FONT_SIZE.PARAGRAPH:
        return -0.07;
      case FONT_SIZE.SMALL:
        return -0.06;
      case FONT_SIZE.TINY:
        return -0.5;
    }
  }
}
