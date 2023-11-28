// ignore: file_names
import 'package:flutter/material.dart';
import 'package:photofilters/utils/colors.dart';
import 'package:photofilters/utils/font_size.dart';
import 'package:photofilters/utils/local_path.dart';

class CustomTextStyle {
  static TextStyle headingH3({
    Color color = CustomColors.dark,
    double fontSize = FontSize.heading3,
  }) {
    return TextStyle(
        fontFamily: LocalPath.yekan,
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.w500);
  }

  static TextStyle headingH5(
      {Color color = CustomColors.dark,
      double fontsize = FontSize.heading5,
      FontWeight? fontWeight=FontWeight.w600}) {
    return TextStyle(
        fontFamily: LocalPath.yekan,
        color: color,
        fontSize: fontsize,
        fontWeight:fontWeight);
  }

  static TextStyle headingH6(
      {Color color = CustomColors.dark,
      double fontsize = FontSize.heading6,
      FontWeight? fontWeight}) {
    return TextStyle(
        fontFamily: LocalPath.yekan,
        color: color,
        fontSize: fontsize,
        fontWeight: fontWeight ?? FontWeight.w600);
  }

  static TextStyle headingH5WithUnderLine(
      {Color color = CustomColors.dark, double fontSize = FontSize.heading5}) {
    return TextStyle(
        fontFamily: LocalPath.yekan,
        color: color,
        fontSize: fontSize,
        decoration: TextDecoration.underline,
        decorationColor: color,
        decorationStyle: TextDecorationStyle.solid,
        fontWeight: FontWeight.w500);
  }

  static TextStyle badge(
      {Color color = CustomColors.dark,
      double fontSize = FontSize.badge2Strong}) {
    return TextStyle(
        fontFamily: LocalPath.yekan,
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.w700);
  }

  static TextStyle badge3(
      {Color color = CustomColors.dark,
      double fontSize = FontSize.badge3Strong,
      FontWeight fontWeight = FontWeight.w700}) {
    return TextStyle(
        fontFamily: LocalPath.yekan,
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight);
  }

  static TextStyle inlineSmall(
      {Color color = CustomColors.dark,
      double fontSize = FontSize.heading6,
      FontWeight? fontWeight}) {
    return TextStyle(
        fontFamily: LocalPath.yekan,
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight ?? FontWeight.w400);
  }
}
