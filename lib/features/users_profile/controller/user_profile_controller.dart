import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twiiter_clone/apis/storage_api.dart';
import 'package:twiiter_clone/apis/tweet_api.dart';
import 'package:twiiter_clone/apis/user_api.dart';
import 'package:twiiter_clone/core/utils.dart';
import 'package:twiiter_clone/features/notifications/controller/notification_controller.dart';
import 'package:twiiter_clone/models/tweet_model.dart';
import 'dart:io';
import '../../../core/enums/notification_type_enum.dart';
import '../../../models/user_model.dart';

final UserProfileControllerProvider =
    StateNotifierProvider<UserProfileController, bool>((ref) {
  return UserProfileController(
    tweetAPI: ref.watch(tweetAPIProvider),
    storageAPI: ref.watch(storageAPIProvider),
    userAPI: ref.watch(UserAPIProvider),
    notificationController: ref.watch(notificationControllerProvider.notifier),
  );
});

final getUserTweetsProvider = FutureProvider.family((ref, String uid) async {
  final userProfileController =
      ref.watch(UserProfileControllerProvider.notifier);
  return userProfileController.getUserTweets(uid);
});

final getLatestUserProfileDataProvider = StreamProvider((ref) {
  final userAPI = ref.watch(UserAPIProvider);
  return userAPI.getLatestUserProfileData();
});

class UserProfileController extends StateNotifier<bool> {
  final TweetAPI _tweetAPI;
  final StorageAPI _storageAPI;
  final UserAPI _userAPI;
  final NotificationController _notificationController;
  UserProfileController({
    required TweetAPI tweetAPI,
    required StorageAPI storageAPI,
    required UserAPI userAPI,
    required NotificationController notificationController,
  })  : _tweetAPI = tweetAPI,
        _storageAPI = storageAPI,
        _userAPI = userAPI,
        _notificationController = notificationController,
        super(false);
  Future<List<Tweet>> getUserTweets(String uid) async {
    final tweets = await _tweetAPI.getUserTweet(uid);
    return tweets.map((e) => Tweet.fromMap(e.data)).toList();
  }

  void updateUserProfile(
      {required UserModel userModel,
      required BuildContext context,
      required File? bannerFile,
      required File? profileImageFile}) async {
    state = true;
    if (bannerFile != null) {
      final bannerUrl = await _storageAPI.uploadImage([bannerFile]);
      userModel = userModel.copyWith(
        bannerPic: bannerUrl[0],
      );
    }
    if (profileImageFile != null) {
      final profileImageUrl = await _storageAPI.uploadImage([profileImageFile]);
      userModel = userModel.copyWith(
        profilePic: profileImageUrl[0],
      );
    }
    final res = await _userAPI.updateUserData(userModel);
    state = false;
    res.fold(
        (l) => showSnackBar(context, l.message), (r) => Navigator.pop(context));
  }

  void followUser({
    required UserModel user,
    required BuildContext context,
    required UserModel currentUser,
  }) async {
    if (currentUser.following.contains(user.uid)) {
      user.followers.remove(currentUser.uid);
      currentUser.following.add(user.uid);
    } else {
      user.followers.add(currentUser.uid);
      currentUser.following.add(user.uid);
    }
    user = user.copyWith(followers: user.followers);
    currentUser = currentUser.copyWith(following: currentUser.following);
    final res = await _userAPI.followUser(user);
    res.fold((l) => showSnackBar(context, l.message), (l) async {
      final res2 = await _userAPI.addToFollowing(currentUser);
      res2.fold((l) => showSnackBar(context, l.message), (r) {
        _notificationController.createNotification(
            text: "${currentUser.name} followed you!",
            postId: "",
            notificationType: NotificationType.follow,
            uid: user.uid);
      });
    });
  }
}
