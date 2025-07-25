import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ping_post/common/common.dart';
import 'package:ping_post/common/loading_page.dart';
import 'package:ping_post/features/auth/controller/auth_controller.dart';
import 'package:ping_post/features/users_profile/controller/user_profile_controller.dart';
import 'package:ping_post/features/users_profile/view/edit_profile_view.dart';
import 'package:ping_post/features/users_profile/widget/follow_count.dart';
import 'package:ping_post/features/widgets/tweet_card.dart';
import 'package:ping_post/theme/pallete.dart';

import '../../../constants/appwrite_constants.dart';
import '../../../constants/assets_constants.dart';
import '../../../models/tweet_model.dart';
import '../../../models/user_model.dart';
import '../../tweet/controller/tweet_controller.dart';

class UserProfle extends ConsumerWidget {
  final UserModel user;
  const UserProfle({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserDetailsProvider).value;
    return currentUser == null
        ? const Loader()
        : NestedScrollView(
            headerSliverBuilder: (context, innerBoxScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 150,
                  floating: true,
                  snap: true,
                  flexibleSpace: Stack(
                    children: [
                      Positioned.fill(
                        child: user.bannerPic.isEmpty
                            ? Container(color: Pallete.blueColor)
                            : Image.network(
                                user.bannerPic,
                                fit: BoxFit.fitWidth,
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(user.profilePic),
                          radius: 45,
                        ),
                      ),
                      Container(
                        alignment: Alignment.bottomRight,
                        margin: EdgeInsets.all(20),
                        child: OutlinedButton(
                          onPressed: () {
                            if (currentUser.uid == user.uid) {
                              Navigator.push(context, EditProfileView.route());
                            } else {
                              ref
                                  .read(UserProfileControllerProvider.notifier)
                                  .followUser(
                                    user: user,
                                    context: context,
                                    currentUser: currentUser,
                                  );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: Pallete.whiteColor),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 25),
                          ),
                          child: Text(
                            currentUser.uid == user.uid
                                ? "Edit Profile"
                                : currentUser.following.contains(user.uid)
                                ? "unfollow"
                                : "Follow",
                            style: TextStyle(color: Pallete.whiteColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(8),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Row(
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (user.isTwitterBlue)
                            Padding(
                              padding: const EdgeInsets.only(left: 3.0),
                              child: SvgPicture.asset(
                                AssetsConstants.verifiedIcon,
                              ),
                            ),
                        ],
                      ),
                      Text(
                        "@${user.name}",
                        style: const TextStyle(
                          fontSize: 17,
                          color: Pallete.greyColor,
                        ),
                      ),
                      Text(user.bio, style: const TextStyle(fontSize: 17)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          FollowCount(
                            count: user.following.length,
                            text: "following",
                          ),
                          const SizedBox(width: 15),
                          FollowCount(
                            count: user.followers.length,
                            text: "followers",
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Divider(color: Pallete.whiteColor),
                    ]),
                  ),
                ),
              ];
            },
            body: ref
                .watch(getUserTweetsProvider(user.uid))
                .when(
                  data: (tweets) {
                    return ref
                        .watch(getLatestTweetProvider)
                        .when(
                          data: (data) {
                            final latestTweet = Tweet.fromMap(data.payload);
                            bool isTweetAlreadyPresent = false;
                            for (final tweetModel in tweets) {
                              if (tweetModel.id == latestTweet.id) {
                                isTweetAlreadyPresent = true;
                                break;
                              }
                            }
                            if (!isTweetAlreadyPresent) {
                              if (data.events.contains(
                                "databases.*.collections.${AppwriteConstants.tweetsCollection}.documents.*.create",
                              )) {
                                tweets.insert(0, Tweet.fromMap(data.payload));
                              } else if (data.events.contains(
                                "databases.*.collections.${AppwriteConstants.tweetsCollection}.documents.*.update",
                              )) {
                                final startingPoint = data.events[0]
                                    .lastIndexOf("documents.");
                                final endPoint = data.events[0].lastIndexOf(
                                  ".update",
                                );
                                final tweetId = data.events[0].substring(
                                  startingPoint + 10,
                                  endPoint,
                                );

                                var tweet = tweets
                                    .where((element) => element.id == tweetId)
                                    .first;
                                final tweetIndex = tweets.indexOf(tweet);
                                tweets.removeWhere(
                                  (element) => element.id == tweetId,
                                );
                                tweet = Tweet.fromMap(data.payload);
                                tweets.insert(tweetIndex, tweet);
                              }
                            }
                            return Expanded(
                              child: ListView.builder(
                                itemCount: tweets.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final tweet = tweets[index];
                                  return TweetCard(tweet: tweet);
                                },
                              ),
                            );
                          },
                          error: (error, stackTrace) =>
                              ErrorText(error: error.toString()),
                          loading: () {
                            return Expanded(
                              child: ListView.builder(
                                itemCount: tweets.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final tweet = tweets[index];
                                  return TweetCard(tweet: tweet);
                                },
                              ),
                            );
                          },
                        );
                  },
                  error: (error, st) => ErrorText(error: error.toString()),
                  loading: () => const Loader(),
                ),
          );
  }
}
