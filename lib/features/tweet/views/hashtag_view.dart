import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ping_post/features/tweet/controller/tweet_controller.dart';

import '../../../common/error_page.dart';
import '../../../common/loading_page.dart';
import '../../widgets/tweet_card.dart';

class HashtagView extends ConsumerWidget {
  static route(String hashtag) =>
      MaterialPageRoute(builder: (context) => HashtagView(hashtag: hashtag));
  final String hashtag;
  const HashtagView({super.key, required this.hashtag});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(hashtag)),
      body: ref
          .watch(getTweetsByHashtagProvider(hashtag))
          .when(
            data: (tweets) {
              return ListView.builder(
                itemCount: tweets.length,
                itemBuilder: (BuildContext context, int index) {
                  final tweet = tweets[index];
                  return TweetCard(tweet: tweet);
                },
              );
            },
            error: (error, stackTrace) => ErrorText(error: error.toString()),
            loading: () => const Loader(),
          ),
    );
  }
}
