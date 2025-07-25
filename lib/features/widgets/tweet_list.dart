import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ping_post/common/common.dart';
import 'package:ping_post/features/tweet/controller/tweet_controller.dart';
import 'package:ping_post/features/widgets/tweet_card.dart';
import 'package:ping_post/models/tweet_model.dart';

import '../../constants/appwrite_constants.dart';

class TweetList extends ConsumerWidget {
  const TweetList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(getTweetProvider)
        .when(
          data: (tweets) {
            return ref
                .watch(getLatestTweetProvider)
                .when(
                  data: (data) {
                    if (data.events.contains(
                      "databases.*.collections.${AppwriteConstants.tweetsCollection}.documents.*.create",
                    )) {
                      tweets.insert(0, Tweet.fromMap(data.payload));
                    } else if (data.events.contains(
                      "databases.*.collections.${AppwriteConstants.tweetsCollection}.documents.*.update",
                    )) {
                      final startingPoint = data.events[0].lastIndexOf(
                        "documents.",
                      );
                      final endPoint = data.events[0].lastIndexOf(".update");
                      final tweetId = data.events[0].substring(
                        startingPoint + 10,
                        endPoint,
                      );

                      var tweet = tweets
                          .where((element) => element.id == tweetId)
                          .first;
                      final tweetIndex = tweets.indexOf(tweet);
                      tweets.removeWhere((element) => element.id == tweetId);
                      tweet = Tweet.fromMap(data.payload);
                      tweets.insert(tweetIndex, tweet);
                    }
                    return ListView.builder(
                      itemCount: tweets.length,
                      itemBuilder: (BuildContext context, int index) {
                        final tweet = tweets[index];
                        return TweetCard(tweet: tweet);
                      },
                    );
                  },
                  error: (error, stackTrace) =>
                      ErrorText(error: error.toString()),
                  loading: () {
                    return ListView.builder(
                      itemCount: tweets.length,
                      itemBuilder: (BuildContext context, int index) {
                        final tweet = tweets[index];
                        return TweetCard(tweet: tweet);
                      },
                    );
                  },
                );
          },
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader(),
        );
  }
}
