import 'package:flutter/material.dart';
import 'package:photofilters/utils/colors.dart';

class LoadingWidget extends StatelessWidget {
  double marginTop;
  Color? loadingColor;
  double size;
  double strokeWidth;
  LoadingWidget(
      {Key? key,
      this.marginTop = 0,
      this.loadingColor,
      this.size = 30,
      this.strokeWidth = 4})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: marginTop),
            width: size,
            height: size,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(loadingColor == null
                  ? CustomColors.fireDragonBright500
                  : loadingColor!),
              strokeWidth: strokeWidth,
            ),
          )
        ],
      ),
    );
  }
}
