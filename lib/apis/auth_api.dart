import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as model;
import 'package:twitter_clone/core/core.dart';


// when you want to signup or get user account you use -> Acoount
// when you want to get user data, you use Account from model, i.e model.Account i.e a model is returned

abstract class IAuthAPI {
  FutureEither<model.Account> signUp({
    required String email,
    required String password,
  });
}

class AuthAPI implements IAuthAPI{
  final Account _account;
  AuthAPI({required Account account}) : _account = account;
  @override
  FutureEither<dynamic> signUp({required String email, required String password}) {
    // TODO: implement signUp
    throw UnimplementedError();
  } async{

  }
}
