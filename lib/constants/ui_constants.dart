import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:twiiter_clone/constants/assets_constants.dart';
import 'package:twiiter_clone/features/explore/view/explore_view.dart';
import 'package:twiiter_clone/features/notifications/views/notification_view.dart';
import 'package:twiiter_clone/features/widgets/tweet_list.dart';
import 'package:twiiter_clone/theme/pallete.dart';

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

  static const List<Widget> bottomTabBarPages = [
    TweetList(),
    ExploreView(),
    NotificationView(),
  ];
}
