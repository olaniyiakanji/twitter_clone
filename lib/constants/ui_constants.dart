import 'package:flutter/material.dart';
import 'package:twitter_clone/constants/assets_constants.dart';
import "package:svg_flutter/svg_flutter.dart";
import 'package:twitter_clone/theme/pallete.dart';

class UIConstants {
  static AppBar appBar() {
    return AppBar(
      title: SvgPicture.asset(
        AssetsConstants.twitterLogo,
        color: Pallete.blueColor,
        height: 30,
      ),
      centerTitle: true,
    );
  }
}
