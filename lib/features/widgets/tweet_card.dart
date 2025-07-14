import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:like_button/like_button.dart';
import 'package:twiiter_clone/common/error_page.dart';
import 'package:twiiter_clone/common/loading_page.dart';
import 'package:twiiter_clone/constants/assets_constants.dart';
import 'package:twiiter_clone/core/enums/tweet_type_enum.dart';
import 'package:twiiter_clone/features/auth/controller/auth_controller.dart';
import 'package:twiiter_clone/features/tweet/controller/tweet_controller.dart';
import 'package:twiiter_clone/features/tweet/views/twitter_reply_screen.dart';
import 'package:twiiter_clone/features/users_profile/view/user_profile_view.dart';
import 'package:twiiter_clone/features/widgets/carousel_image.dart';
import 'package:twiiter_clone/features/widgets/hashtag_text.dart';
import 'package:twiiter_clone/features/widgets/tweet_icon_button.dart';
import 'package:twiiter_clone/models/tweet_model.dart';
import 'package:twiiter_clone/theme/pallete.dart';
import 'package:timeago/timeago.dart' as timeago;

class TweetCard extends ConsumerWidget {
  final Tweet tweet;
  const TweetCard({super.key, required this.tweet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserDetailsProvider).value;
    return currentUser == null
        ? const SizedBox()
        : ref.watch(userDetailProvider(tweet.uid)).when(
            data: (user) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    TwitterReplyScreen.route(tweet),
                  );
                },
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.all(10),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context, UserProfileView.route(user));
                            },
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(user.profilePic),
                              radius: 35,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (tweet.retweetedBy.isNotEmpty)
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      AssetsConstants.retweetIcon,
                                      color: Pallete.greyColor,
                                      height: 20,
                                    ),
                                    const SizedBox(
                                      width: 2,
                                    ),
                                    Text(
                                      "${tweet.retweetedBy} retweeted",
                                      style: const TextStyle(
                                        color: Pallete.greyColor,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                      ),
                                    )
                                  ],
                                ),
                              Row(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                        right: user.isTwitterBlue ? 1 : 5),
                                    child: Text(
                                      user.name,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 19),
                                    ),
                                  ),
                                  if (user.isTwitterBlue)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 5.0),
                                      child: SvgPicture.asset(
                                          AssetsConstants.verifiedIcon),
                                    ),
                                  Text(
                                    "@${user.name} . ${timeago.format(tweet.tweetAt, locale: "en_short")}",
                                    style: TextStyle(
                                        color: Pallete.greyColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17),
                                  ),
                                ],
                              ),
                              if (tweet.repliedTo.isNotEmpty)
                                ref
                                    .watch(
                                        getTweetByIdProvider(tweet.repliedTo))
                                    .when(
                                      data: (repliedToTweet) {
                                        final repliedToUser = ref
                                            .watch(
                                              userDetailProvider(
                                                  repliedToTweet.uid),
                                            )
                                            .value;
                                        return RichText(
                                          text: TextSpan(
                                            text: "replying to",
                                            style: TextStyle(
                                                color: Pallete.greyColor,
                                                fontSize: 16),
                                            children: [
                                              TextSpan(
                                                text:
                                                    " @${repliedToUser!.name}",
                                                style: TextStyle(
                                                    color: Pallete.blueColor,
                                                    fontSize: 16),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      error: (error, st) =>
                                          ErrorText(error: error.toString()),
                                      loading: () => const SizedBox(),
                                    ),
                              HashtagText(text: tweet.text),
                              if (tweet.tweetType == TweetType.image)
                                CarouselImage(imageLinks: tweet.imageLinks),
                              if (tweet.link.isNotEmpty) ...[
                                const SizedBox(
                                  height: 4,
                                ),
                                AnyLinkPreview(
                                  displayDirection:
                                      UIDirection.uiDirectionHorizontal,
                                  link: ("https://${tweet.link}"),
                                ),
                              ],
                              Container(
                                margin: EdgeInsets.only(top: 10, right: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TweetIconButton(
                                      pathName: AssetsConstants.viewsIcon,
                                      text: (tweet.commentIds.length +
                                              tweet.reshareCount +
                                              tweet.likes.length)
                                          .toString(),
                                      onTap: () {},
                                    ),
                                    TweetIconButton(
                                        pathName: AssetsConstants.commentIcon,
                                        text: (tweet.commentIds.length)
                                            .toString(),
                                        onTap: () {}),
                                    TweetIconButton(
                                        pathName: AssetsConstants.retweetIcon,
                                        text: (tweet.reshareCount).toString(),
                                        onTap: () {
                                          ref
                                              .read(tweetControllerProvider
                                                  .notifier)
                                              .reshareTweet(
                                                tweet,
                                                currentUser,
                                                context,
                                              );
                                        }),
                                    LikeButton(
                                      onTap: (isLiked) async {
                                        ref
                                            .read(tweetControllerProvider
                                                .notifier)
                                            .likeTweet(tweet, currentUser);
                                        return !isLiked;
                                      },
                                      size: 25,
                                      isLiked:
                                          tweet.likes.contains(currentUser.uid),
                                      likeBuilder: (isLiked) {
                                        return isLiked
                                            ? SvgPicture.asset(
                                                AssetsConstants.likeFilledIcon,
                                                color: Pallete.redColor,
                                              )
                                            : SvgPicture.asset(
                                                AssetsConstants
                                                    .likeOutlinedIcon,
                                                color: Pallete.greyColor,
                                              );
                                      },
                                      likeCount: tweet.likes.length,
                                      countBuilder: (likeCount, isLiked, text) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(left: 2.0),
                                          child: Text(
                                            text,
                                            style: TextStyle(
                                              color: isLiked
                                                  ? Pallete.redColor
                                                  : Pallete.whiteColor,
                                              fontSize: 16,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                        onPressed: () {},
                                        icon: Icon(
                                          Icons.share_outlined,
                                          size: 25,
                                          color: Pallete.greyColor,
                                        ))
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 1,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                      color: Pallete.greyColor,
                    )
                  ],
                ),
              );
            },
            error: (error, stackTrace) => ErrorText(
                  error: error.toString(),
                ),
            loading: () => const Loader());
  }
}
