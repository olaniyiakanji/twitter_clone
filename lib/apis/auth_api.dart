import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as model;
import 'package:fpdart/fpdart.dart';
import 'package:twitter_clone/core/core.dart';

// when you want to signup or get user account you use -> Acoount it is ralated to creating and mnaaging data in the server side
// when you want to get user data, you use Account from model, i.e model.User  i.e a model is returned, user related date

abstract class IAuthAPI {
  FutureEither<model.User> signUp({
    required String email,
    required String password,
  });
}

class AuthAPI implements IAuthAPI {
  final Account _account;
  AuthAPI({required Account account}) : _account = account;
  @override
  FutureEither<model.User> signUp(
      {required String email, required String password}) async {
    // TODO: implement signUp
    try {
      final account = await _account.create(
          userId: 'unique()', email: email, password: password);
      return right(account);
    } on AppwriteException catch (e, stackTrace) {
      return left(
          Failure(e.message ?? 'some unexpected error occured', stackTrace));
    } catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace));
    }
  }
}
