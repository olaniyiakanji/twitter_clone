import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/common/error_page.dart';
import 'package:twitter_clone/features/user_profile/controller/user_profile_controller.dart';
import 'package:twitter_clone/features/user_profile/widget/user_profile.dart';
import 'package:twitter_clone/models/user_model.dart';

void updateUser(UserModel user, List<UserModel> userList) {
  var match = userList.where((u) => u.uid == user.uid).first;
  int matchIndex = userList.indexOf(match);
  userList.removeAt(matchIndex);

  userList.insert(matchIndex, user);
}

class UserProfileView extends ConsumerWidget {
  final UserModel userModel;
  const UserProfileView({
    super.key,
    required this.userModel,
  });

  // NOTE: may not be neccessary anymore
  // process new changes
  // void processChanges(List<UserModel> _data, List<UserModel> newData) {
  //   for (UserModel user in newData) {
  //     Iterable s = _data.where((u) => u.uid == user.uid).indexed;
  //     int index = s.first.first;
  //     UserModel u = s.first.last;

  //     _data[index] = u;
  //   }
  // }

  // final List<UserModel> _data = [];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    UserModel copyOfUser = userModel;

    return Scaffold(
      body: ref.watch(getLatestUserProfileDataProvider).when(
            data: (data) {
              // var hash = data.hashCode;
              // if (data.hashCode == hash) {
              //   copyOfUser = UserModel.fromMap(data);
              // }
              return UserProfile(user: data);
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
