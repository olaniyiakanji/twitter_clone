import 'package:appwrite/appwrite.dart';
import 'package:fpdart/fpdart.dart';

abstract class IAuthAPI {
  Future<Either<Account, String>> signUp({
    required String email,
    required String password,
  });
}
