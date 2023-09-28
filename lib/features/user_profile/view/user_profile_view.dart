import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/common/error_page.dart';
import 'package:twitter_clone/constants/constants.dart';
import 'package:twitter_clone/features/user_profile/controller/user_profile_controller.dart';
import 'package:twitter_clone/features/user_profile/widget/user_profile.dart';
import 'package:twitter_clone/models/user_model.dart';

void updateUser(UserModel user, List<UserModel> userList) {
  var match = userList.where((u) => u.uid == user.uid).first;
  userList.indexOf()

class UserProfileView extends ConsumerWidget {
  final UserModel userModel;
  const UserProfileView({
    super.key,
    required this.userModel,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    UserModel copyOfUser = userModel;

    // new abstraction added:
    final List<UserModel> _data = [];

    // process new changes
    void processChanges(List<UserModel> newData) {
      for (UserModel user in newData) {
        Iterable s = _data.where((u) => u.uid == user.uid);
      }
    }

    return Scaffold(
      body: ref.watch(getLatestUserProfileDataProvider).when(
            data: (data) {
              final d = data as Map<String, dynamic>;
              if (data.events.contains(
                'databases.*.collections.${AppwriteConstants.usersCollection}.documents.${copyOfUser.uid}.update',
              )) {
                copyOfUser = UserModel.fromMap(data.payload);
              }
              return UserProfile(user: copyOfUser);
            },
            error: (error, st) => ErrorText(
              error: error.toString(),
            ),
            loading: () {
              return UserProfile(user: copyOfUser);
            },
          ),
    );
  }

  static route(UserModel userModel) => MaterialPageRoute(
        builder: (context) => UserProfileView(
          userModel: userModel,
        ),
      );
}
