import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/common/common.dart';
import 'package:twitter_clone/features/tweet/controller/tweet_controller.dart';
import 'package:twitter_clone/features/tweet/widgets/tweet_card.dart';
import 'package:twitter_clone/models/tweet_model.dart';

class TwitterReplyScreen extends ConsumerWidget {
  final Tweet tweet;
  const TwitterReplyScreen({
    super.key,
    required this.tweet,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tweet'),
      ),
      body: Column(
        children: [
          TweetCard(tweet: tweet),
          ref.watch(getRepliesToTweetsProvider(tweet)).when(
                data: (tweets) {
                  return ref.watch(getLatestTweetProvider).when(
                        data: (data) {
                          final latestTweet = Tweet.fromMap(
                              data.data() as Map<String, dynamic>);

                          bool isTweetAlreadyPresent = false;
                          for (final tweetModel in tweets) {
                            if (tweetModel.id == latestTweet.id) {
                              isTweetAlreadyPresent = true;
                              break;
                            }
                          }

                          Widget view = buildExpanded(tweets);

                          if (latestTweet.repliedTo != tweet.id) {
                            return view;
                          }

                          if (isTweetAlreadyPresent) {
                            // get id of original tweet
                            final tweetId = data.id;
                            var tweet = tweets
                                .where((element) => element.id == tweetId)
                                .first;
                            final tweetIndex = tweets.indexOf(tweet);
                            tweets.removeWhere(
                                (element) => element.id == tweetId);

                            tweet = Tweet.fromMap(
                                data.data() as Map<String, dynamic>);
                            tweets.insert(tweetIndex, tweet);
                          } else {
                            // if tweet has just been created
                            tweets.insert(0, latestTweet);
                          }
                          view = buildExpanded(tweets);

                          return view;
                        },
                        error: (error, stackTrace) => ErrorText(
                          error: error.toString(),
                        ),
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
                error: (error, stackTrace) => ErrorText(
                  error: error.toString(),
                ),
                loading: () => const Loader(),
              ),
        ],
      ),
      bottomNavigationBar: TextField(
        onSubmitted: (value) {
          ref.read(tweetControllerProvider.notifier).shareTweet(
            images: [],
            text: value,
            context: context,
            repliedTo: tweet.id,
            repliedToUserId: tweet.uid,
          );
        },
        decoration: const InputDecoration(
          hintText: 'Tweet your reply',
        ),
      ),
    );
  }

  Expanded buildExpanded(List<Tweet> tweets) {
    return Expanded(
      child: ListView.builder(
        itemCount: tweets.length,
        itemBuilder: (BuildContext context, int index) {
          final tweet = tweets[index];
          return TweetCard(tweet: tweet);
        },
      ),
    );
  }

  static route(Tweet tweet) => MaterialPageRoute(
        builder: (context) => TwitterReplyScreen(
          tweet: tweet,
        ),
      );
}
