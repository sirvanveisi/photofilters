import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photofilters/utils/colors.dart';
import 'package:photofilters/utils/font_Style.dart';
import 'package:photofilters/widgets/circle_loading.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    required this.onPressed,
    required this.title,
    this.primary = true,
    this.width,
    this.height,
    this.loading = false,
    this.backgroundColor ,
    this.textColor ,
    this.borderColor=Colors.white ,
    Key? key,
  }) : super(key: key);

  final String title;
  final void Function()? onPressed;
  final bool? primary;
  final bool? loading;
  final double? width;
  final double? height;
  final Color ?backgroundColor;
  final Color? textColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      child: Container(

        height: height ?? 48,
        width: width,
        decoration: BoxDecoration(
          color: backgroundColor ?? (primary == true
              ? CustomColors.thickBlue
              : CustomColors.thickBlue100),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            width: 1,

              color: borderColor),
        ),
        child: Center(
            child: loading == true
                ? LoadingWidget(
              loadingColor: primary == true
                  ? CustomColors.drWhite100
                  : CustomColors.thickBlue,
            )
                : Text(
              title,
              style: CustomTextStyle.headingH3(
                  fontSize: 16,

                  color:textColor ?? (primary == true
                      ? CustomColors.drWhite100
                      : CustomColors.thickBlue),
            )),
      ),
    ));
  }
}
