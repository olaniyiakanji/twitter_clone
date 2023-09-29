import 'package:appwrite/appwrite.dart' as appwrite;
import 'package:appwrite/models.dart' as appwriteModel;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:twitter_clone/constants/constants.dart';
import 'package:twitter_clone/core/core.dart';
import 'package:twitter_clone/core/providers.dart';
import 'package:twitter_clone/models/user_model.dart';

final userAPIProvider = firebaseUserAPIProvider;

final appwriteUserAPIProvider = Provider((ref) {
  return AppwriteUserAPI(
    db: ref.watch(appwriteDatabaseProvider),
    realtime: ref.watch(appwriteRealtimeProvider),
  );
});

final firebaseUserAPIProvider = Provider((ref) {
  return FirebaseUserAPI(
      db: ref.watch(firebaseFirestoreProvider),
      instance: ref.watch(firebaseAuthProvider));
});

abstract class IAppwriteUserAPI {
  FutureEitherVoid saveUserData(UserModel userModel);
  Future<appwriteModel.Document> getUserData(String uid);
  Future<List<appwriteModel.Document>> searchUserByName(String name);
  FutureEitherVoid updateUserData(UserModel userModel);
  Stream<appwrite.RealtimeMessage> getLatestUserProfileData();
  FutureEitherVoid followUser(UserModel user);
  FutureEitherVoid addToFollowing(UserModel user);
}

abstract class IFirebaseUserAPI {
  FutureEitherVoid saveUserData(UserModel userModel);
  Future<DocumentSnapshot?> getUserData(String uid);
  Future<List<DocumentSnapshot>> searchUserByName(String name);
  FutureEitherVoid updateUserData(UserModel userModel);
  Stream<UserModel> getLatestUserProfileData();
  FutureEitherVoid followUser(UserModel user);
  FutureEitherVoid addToFollowing(UserModel user);
}

abstract class UserAPI {}

class AppwriteUserAPI extends UserAPI implements IAppwriteUserAPI {
  final appwrite.Databases _db;
  final appwrite.Realtime _realtime;
  AppwriteUserAPI({
    required appwrite.Databases db,
    required appwrite.Realtime realtime,
  })  : _realtime = realtime,
        _db = db;

  @override
  FutureEitherVoid saveUserData(UserModel userModel) async {
    try {
      await _db.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.usersCollection,
        documentId: userModel.uid,
        data: userModel.toMap(),
      );
      return right(null);
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
  Future<appwriteModel.Document> getUserData(String uid) {
    return _db.getDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.usersCollection,
      documentId: uid,
    );
  }

  @override
  Future<List<appwriteModel.Document>> searchUserByName(String name) async {
    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.usersCollection,
      queries: [
        appwrite.Query.search('name', name),
      ],
    );

    return documents.documents;
  }

  @override
  FutureEitherVoid updateUserData(UserModel userModel) async {
    try {
      await _db.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.usersCollection,
        documentId: userModel.uid,
        data: userModel.toMap(),
      );
      return right(null);
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
  Stream<appwrite.RealtimeMessage> getLatestUserProfileData() {
    return _realtime.subscribe([
      'databases.${AppwriteConstants.databaseId}.collections.${AppwriteConstants.usersCollection}.documents'
    ]).stream;
  }

  @override
  FutureEitherVoid followUser(UserModel user) async {
    try {
      await _db.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.usersCollection,
        documentId: user.uid,
        data: {
          'followers': user.followers,
        },
      );
      return right(null);
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
  FutureEitherVoid addToFollowing(UserModel user) async {
    try {
      await _db.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.usersCollection,
        documentId: user.uid,
        data: {
          'following': user.following,
        },
      );
      return right(null);
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
}

class FirebaseUserAPI extends UserAPI implements IFirebaseUserAPI {
  final FirebaseFirestore _db;
  final FirebaseAuth _instance;

  FirebaseUserAPI(
      {required FirebaseFirestore db, required FirebaseAuth instance})
      : _db = db,
        _instance = instance;
  @override
  FutureEitherVoid addToFollowing(UserModel user) async {
    late final DocumentSnapshot currentUser;
    try {
      currentUser =
          await _db.collection('users').doc(_instance.currentUser!.uid).get();
    } on Exception catch (e, st) {
      return left(Failure(e.toString(), st));
    }

    // Add the user's ID to the currentUser's following list.
    currentUser.reference.update({
      'following': FieldValue.arrayUnion([user.uid]),
    });

    // Add the currentUser's ID to the user's followers list.
    await _db.collection('users').doc(user.uid).update({
      'followers': FieldValue.arrayUnion([currentUser.id]),
    });

    return right(null);
  }

  @override
  FutureEitherVoid followUser(UserModel user) async {
    try {
      final DocumentSnapshot currentUser;
      currentUser =
          await _db.collection('users').doc(_instance.currentUser!.uid).get();

      // Add the user's ID to the currentUser's following list.
      currentUser.reference.update({
        'following': FieldValue.arrayUnion([user.uid]),
      });

      // Add the currentUser's ID to the user's followers list.
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'followers': FieldValue.arrayUnion([currentUser.id]),
      });
    } on Exception catch (e, st) {
      return left(Failure(e.toString(), st));
    }

    return right(null);
  }

  @override
  Stream<UserModel> getLatestUserProfileData() {
    final query = _db.collection('users');

    // Listen for changes to the collection and return a stream of snapshots.
    return query.snapshots(includeMetadataChanges: true).map((snapshot) {
      // Convert the snapshot to a list of UserModel objects.
      // NOTE and TODO: here,... the `.docChanges` here is dangerous and untested
      final user = snapshot.docs.map((document) {
        return UserModel.fromMap(document.data());
      }).first;

      // Return the list of UserModel objects.
      return user;
    });
  }

  @override
  Future<DocumentSnapshot?> getUserData(String uid) async {
    try {
      final documentReference = _db.collection('users').doc(uid);
      final documentSnapshot = await documentReference.get();
      return documentSnapshot;
    } on Exception {
      // do nothing
      return null;
    }
  }

  @override
  FutureEitherVoid saveUserData(UserModel userModel) async {
    try {
      final documentReference = _db.collection('users').doc(userModel.uid);
      await documentReference.set(userModel.toMap());
      return right(null);
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  Future<List<DocumentSnapshot>> searchUserByName(String name) async {
    final query = _db.collection('users').where('name', isEqualTo: name);
    final snapshot = await query.get();
    return snapshot.docs;
  }

  @override
  FutureEitherVoid updateUserData(UserModel userModel) async {
    try {
      final documentReference = _db.collection('users').doc(userModel.uid);
      await documentReference.update(userModel.toMap());
      return right(null);
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }
}
