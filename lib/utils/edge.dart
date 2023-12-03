import 'package:flutter/material.dart';

abstract class CustomEdge {
  static SizedBox vSeparator = const SizedBox(height: 10);
  static SizedBox vSeparatorSmall = const SizedBox(height: 5);
  static SizedBox vSeparator2x = const SizedBox(height: 20);
  static SizedBox vSeparator3x = const SizedBox(height: 30);
  static SizedBox vSeparator4x = const SizedBox(height:40);
  static SizedBox vSeparator6x = const SizedBox(height: 60);
  static SizedBox hSeparator = const SizedBox(width: 10);
  static SizedBox hSeparatorSmall = const SizedBox(width: 5);
  static SizedBox hSeparator2x = const SizedBox(width: 20);
  static SizedBox hSeparator3x = const SizedBox(width: 30);
  static SizedBox hSeparator6x = const SizedBox(width: 60);
  static const EdgeInsets horizPrimary = EdgeInsets.symmetric(horizontal: 16);
  static const EdgeInsets horizLarge = EdgeInsets.symmetric(horizontal: 26);
  static const EdgeInsets horizPrimarySmall =
      EdgeInsets.symmetric(horizontal: 6);
  static const EdgeInsets vertPrimary = EdgeInsets.symmetric(vertical: 16);
  static const EdgeInsets vertSmall = EdgeInsets.symmetric(vertical: 6);

  static const EdgeInsets primary = EdgeInsets.all(16);
  static const EdgeInsets small = EdgeInsets.all(5);
  static const EdgeInsets medium = EdgeInsets.all(10);
  static const EdgeInsets large = EdgeInsets.all(26);
  static const EdgeInsets branItem = EdgeInsets.fromLTRB(16, 26, 16, 5);

  static const EdgeInsets tab = EdgeInsets.only(top: 10, bottom: 5);
}
