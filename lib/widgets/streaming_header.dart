import 'package:flutter/material.dart';
import 'package:flutter_stream/res/ui_helpers.dart';
import 'package:flutter_stream/res/custom_colors.dart';

class StreamingHeader extends StatelessWidget {
  double mHeightImg;
  double mFontSizeTitle;
  bool mShowDescription;
  Widget mSizedBox;
  Widget mSizedBoxBottom;

  StreamingHeader({
    this.mHeightImg,
    this.mFontSizeTitle,
    this.mShowDescription
  });

  StreamingHeader.small() {
    mHeightImg = 100.0;
    mFontSizeTitle = 30.0;
    mShowDescription = false;
    mSizedBox = UIHelper.verticalSpaceMedium();
    mSizedBoxBottom = UIHelper.verticalSpaceSmall();
  }

  StreamingHeader.medium() {
    mHeightImg = 130.0;
    mFontSizeTitle = 36.0;
    mShowDescription = true;
    mSizedBox = UIHelper.verticalSpaceLarge();
    mSizedBoxBottom = UIHelper.verticalSpaceLarge();
  }

  @override
  Widget build(BuildContext context) {
    final sizeScreen = MediaQuery.of(context).size;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        mSizedBox,
        Container(
          width: sizeScreen.width,
          height: mHeightImg,
          child: Image.asset("assets/icon/icon.png"),
        ),
        UIHelper.verticalSpaceMedium(),
        Text(
          "Streaming Project",
          style: Theme.of(context).textTheme.display4,
          overflow: TextOverflow.ellipsis,
        ),
        UIHelper.verticalSpaceSmall(),
        mSizedBoxBottom,
      ],
    );
  }
}
