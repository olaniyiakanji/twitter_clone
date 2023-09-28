import 'package:appwrite/appwrite.dart' as appwrite;
import 'package:appwrite/models.dart' as model;
import 'package:cloud_firestore/cloud_firestore.dart' as firebase;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:twitter_clone/constants/appwrite_constants.dart';
import 'package:twitter_clone/core/core.dart';
import 'package:twitter_clone/core/providers.dart';
import 'package:twitter_clone/models/tweet_model.dart';

final tweetAPIProvider = Provider((ref) {
  return FirebaseTweetAPI(
    db: ref.watch(firebaseFirestoreProvider),
  );
});

abstract class IAppwriteTweetAPI {
  FutureEither<model.Document> shareTweet(Tweet tweet);
  Future<List<model.Document>> getTweets();
  Stream<appwrite.RealtimeMessage> getLatestTweet();
  FutureEither<model.Document> likeTweet(Tweet tweet);
  FutureEither<model.Document> updateReshareCount(Tweet tweet);
  Future<List<model.Document>> getRepliesToTweet(Tweet tweet);
  Future<model.Document> getTweetById(String id);
  Future<List<model.Document>> getUserTweets(String uid);
  Future<List<model.Document>> getTweetsByHashtag(String hashtag);
}

abstract class IFirebaseTweetAPI {
  FutureEither<firebase.DocumentSnapshot> shareTweet(Tweet tweet);
  Future<List<firebase.DocumentSnapshot>> getTweets();
  Stream<firebase.DocumentSnapshot> getLatestTweet();
  FutureEitherVoid likeTweet(Tweet tweet);
  FutureEitherVoid updateReshareCount(Tweet tweet);
  Future<List<firebase.DocumentSnapshot>> getRepliesToTweet(Tweet tweet);
  Future<firebase.DocumentSnapshot> getTweetById(String id);
  Future<List<firebase.DocumentSnapshot>> getUserTweets(String uid);
  Future<List<firebase.DocumentSnapshot>> getTweetsByHashtag(String hashtag);
}

abstract class TweetAPI {}

class AppwriteTweetAPI extends TweetAPI implements IAppwriteTweetAPI {
  final appwrite.Databases _db;
  final appwrite.Realtime _realtime;
  AppwriteTweetAPI(
      {required appwrite.Databases db, required appwrite.Realtime realtime})
      : _db = db,
        _realtime = realtime;

  @override
  FutureEither<model.Document> shareTweet(Tweet tweet) async {
    try {
      final document = await _db.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.tweetsCollection,
        documentId: appwrite.ID.unique(),
        data: tweet.toMap(),
      );
      return right(document);
    } on appwrite.AppwriteException catch (e, st) {
      return left(
        Failure(
          e.message ?? 'Some unexpected error occurred',
          st,
        ),
      );
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  Future<List<model.Document>> getTweets() async {
    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.tweetsCollection,
      queries: [
        appwrite.Query.orderDesc('tweetedAt'),
      ],
    );
    return documents.documents;
  }

  @override
  Stream<appwrite.RealtimeMessage> getLatestTweet() {
    return _realtime.subscribe([
      'databases.${AppwriteConstants.databaseId}.collections.${AppwriteConstants.tweetsCollection}.documents'
    ]).stream;
  }

  @override
  FutureEither<model.Document> likeTweet(Tweet tweet) async {
    try {
      final document = await _db.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.tweetsCollection,
        documentId: tweet.id,
        data: {
          'likes': tweet.likes,
        },
      );
      return right(document);
    } on appwrite.AppwriteException catch (e, st) {
      return left(
        Failure(
          e.message ?? 'Some unexpected error occurred',
          st,
        ),
      );
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  FutureEither<model.Document> updateReshareCount(Tweet tweet) async {
    try {
      final document = await _db.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.tweetsCollection,
        documentId: tweet.id,
        data: {
          'reshareCount': tweet.reshareCount,
        },
      );
      return right(document);
    } on appwrite.AppwriteException catch (e, st) {
      return left(
        Failure(
          e.message ?? 'Some unexpected error occurred',
          st,
        ),
      );
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  Future<List<model.Document>> getRepliesToTweet(Tweet tweet) async {
    final document = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.tweetsCollection,
      queries: [
        appwrite.Query.equal('repliedTo', tweet.id),
      ],
    );
    return document.documents;
  }

  @override
  Future<model.Document> getTweetById(String id) async {
    return _db.getDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.tweetsCollection,
      documentId: id,
    );
  }

  @override
  Future<List<model.Document>> getUserTweets(String uid) async {
    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.tweetsCollection,
      queries: [
        appwrite.Query.equal('uid', uid),
      ],
    );
    return documents.documents;
  }

  @override
  Future<List<model.Document>> getTweetsByHashtag(String hashtag) async {
    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.tweetsCollection,
      queries: [
        appwrite.Query.search('hashtags', hashtag),
      ],
    );
    return documents.documents;
  }
}

class FirebaseTweetAPI extends TweetAPI implements IFirebaseTweetAPI {
  final firebase.FirebaseFirestore _db;

  firebase.CollectionReference<Map<String, dynamic>> get _tweets {
    return _db.collection('tweets');
  }

  FirebaseTweetAPI({required firebase.FirebaseFirestore db}) : _db = db;

  @override
  FutureEither<firebase.DocumentSnapshot<Map<String, dynamic>>> shareTweet(
      Tweet tweet) async {
    try {
      final doc = await _tweets.add(tweet.toMap());
      return right(await doc.get());
    } on Exception catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  Future<List<firebase.DocumentSnapshot>> getTweets() async {
    final snapshot = await _tweets.orderBy('tweetedAt', descending: true).get();
    return snapshot.docs;
  }

  @override
  Stream<firebase.DocumentSnapshot> getLatestTweet() {
    return _tweets.snapshots(includeMetadataChanges: true).map((snapshot) {
      return snapshot.docs.first;
    });
  }

  @override
  FutureEitherVoid likeTweet(Tweet tweet) async {
    try {
      await _tweets.doc(tweet.id).update({
        'likes': tweet.likes,
      });
    } on Exception catch (e, st) {
      return left(Failure(e.toString(), st));
    }
    return right(null);
  }

  @override
  FutureEitherVoid updateReshareCount(Tweet tweet) async {
    try {
      await _tweets.doc(tweet.id).update({
        'reshareCount': tweet.reshareCount,
      });
    } on Exception catch (e, st) {
      return left(Failure(e.toString(), st));
    }
    return right(null);
  }

  @override
  Future<List<firebase.DocumentSnapshot>> getRepliesToTweet(Tweet tweet) async {
    final snapshot = await _db
        .collection('tweets')
        .where('repliedTo', isEqualTo: tweet.id)
        .orderBy('tweetedAt', descending: true)
        .get();
    return snapshot.docs;
  }

  @override
  Future<firebase.DocumentSnapshot> getTweetById(String id) async {
    return await _db.collection('tweets').doc(id).get();
  }

  @override
  Future<List<firebase.DocumentSnapshot>> getUserTweets(String uid) async {
    final snapshot = await _db
        .collection('tweets')
        .where('uid', isEqualTo: uid)
        .orderBy('tweetedAt', descending: true)
        .get();
    return snapshot.docs;
  }

  @override
  Future<List<firebase.DocumentSnapshot>> getTweetsByHashtag(
      String hashtag) async {
    final snapshot = await _db
        .collection('tweets')
        .where('hashtags', arrayContains: hashtag)
        .orderBy('tweetedAt', descending: true)
        .get();
    return snapshot.docs;
  }
}
