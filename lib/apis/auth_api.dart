import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as appwriteModel;
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:twitter_clone/core/core.dart';
import 'package:twitter_clone/core/providers.dart';

typedef FutureEitherFFunction
    = FutureEither<Future<firebase.UserCredential> Function(String)>;
final appwriteAuthAPIProvider = Provider((ref) {
  final account = ref.watch(appwriteAccountProvider);
  return AppwriteAuthAPI(account: account);
});

final firebaseAuthAPIProvider = Provider((ref) {
  final instance = ref.watch(firebaseAuthProvider);
  return FirebaseAuthAPI(instance: instance);
});

abstract class IAppwriteAuthAPI {
  FutureEither<appwriteModel.User> signUp({
    required String email,
    required String password,
  });

  FutureEither<appwriteModel.Session> login({
    required String email,
    required String password,
  });

  Future<appwriteModel.User?> currentUserAccount();

  FutureEitherVoid logout();
}

abstract class IFirebaseAuthAPI {
  FutureEither<UserCredential> signUp({
    required String email,
    required String password,
  });

  FutureEither<firebase.UserCredential> login({
    required String email,
    required String password,
  });

  firebase.User? get currentUserAccount;

  FutureEitherVoid logout();
}

abstract class IFederatedAuthAPI {
  FutureEither<firebase.UserCredential> googleSignIn();
  FutureEitherFFunction signInWithPhone({required String phoneNumber});
}

abstract class AuthAPI {}

class AppwriteAuthAPI extends AuthAPI implements IAppwriteAuthAPI {
  final Account _account;

  AppwriteAuthAPI({required Account account}) : _account = account;

  @override
  Future<appwriteModel.User?> currentUserAccount() async {
    try {
      return await _account.get();
    } on AppwriteException {
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  FutureEither<appwriteModel.User> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final account = await _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
      );
      return right(account);
    } on AppwriteException catch (e, stackTrace) {
      return left(
        Failure(e.message ?? 'Some unexpected error occurred', stackTrace),
      );
    } catch (e, stackTrace) {
      return left(
        Failure(e.toString(), stackTrace),
      );
    }
  }

  @override
  FutureEither<appwriteModel.Session> login({
    required String email,
    required String password,
  }) async {
    try {
      final session = await _account.createEmailSession(
        email: email,
        password: password,
      );
      return right(session);
    } on AppwriteException catch (e, stackTrace) {
      return left(
        Failure(e.message ?? 'Some unexpected error occurred', stackTrace),
      );
    } catch (e, stackTrace) {
      return left(
        Failure(e.toString(), stackTrace),
      );
    }
  }

  @override
  FutureEitherVoid logout() async {
    try {
      await _account.deleteSession(
        sessionId: 'current',
      );
      return right(null);
    } on AppwriteException catch (e, stackTrace) {
      return left(
        Failure(e.message ?? 'Some unexpected error occurred', stackTrace),
      );
    } catch (e, stackTrace) {
      return left(
        Failure(e.toString(), stackTrace),
      );
    }
  }
}

class FirebaseAuthAPI extends AuthAPI
    implements IFirebaseAuthAPI, IFederatedAuthAPI {
  final FirebaseAuth _instance;

  FirebaseAuthAPI({required FirebaseAuth instance}) : _instance = instance;

  @override
  User? get currentUserAccount => _instance.currentUser;

  @override
  FutureEither<UserCredential> login(
      {required String email, required String password}) async {
    try {
      final credential = await _instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return right(credential);
    } on FirebaseAuthException catch (e, st) {
      late String m;
      if (e.code == 'weak-password') {
        m = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        m = 'The account already exists for that email.';
      }
      if (kDebugMode) {
        print(m);
      }
      return left(
        Failure(e.message ?? 'Some unexpected error occurred', st),
      );
    } catch (e, st) {
      if (kDebugMode) {
        print('unexpected error');
      }
      return left(
        Failure(e.toString(), st),
      );
    }
  }

  @override
  FutureEitherVoid logout() async {
    try {
      await _instance.signOut();
      return right(null);
    } on FirebaseAuthException catch (e, stackTrace) {
      return left(
        Failure(e.message ?? 'Some unexpected error occurred', stackTrace),
      );
    } catch (e, stackTrace) {
      return left(
        Failure(e.toString(), stackTrace),
      );
    }
  }

  @override
  FutureEither<UserCredential> signUp(
      {required String email, required String password}) async {
    late final UserCredential userCred;
    try {
      userCred = await _instance.createUserWithEmailAndPassword(
          email: email, password: password);
      return right(userCred);
    } catch (e, st) {
      return left(
        Failure(e.toString(), st),
      );
    }
  }

  @override
  FutureEither<UserCredential> googleSignIn() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    late final OAuthCredential credential;

    try {
      credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
    } catch (e, st) {
      return left(
        Failure(e.toString(), st),
      );
    }

    // Once signed in, return the UserCredential
    UserCredential userCred =
        await FirebaseAuth.instance.signInWithCredential(credential);

    return right(userCred);
  }

  @override
  FutureEitherFFunction signInWithPhone({required String phoneNumber}) async {
    ConfirmationResult verification =
        await FirebaseAuth.instance.signInWithPhoneNumber(phoneNumber);
    try {
      return right(verification.confirm);
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }
}
