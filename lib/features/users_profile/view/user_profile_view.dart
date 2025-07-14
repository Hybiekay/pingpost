import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ping_post/common/common.dart';
import 'package:ping_post/constants/appwrite_constants.dart';
import 'package:ping_post/features/users_profile/controller/user_profile_COntroller.dart';
import 'package:ping_post/features/users_profile/widget/user_profle.dart';
import 'package:ping_post/models/user_model.dart';

class UserProfileView extends ConsumerWidget {
  static route(UserModel userModel) => MaterialPageRoute(
    builder: (context) => UserProfileView(userModel: userModel),
  );

  final UserModel userModel;
  const UserProfileView({super.key, required this.userModel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    UserModel copyOfUser = userModel;
    return Scaffold(
      body: ref
          .watch(getLatestUserProfileDataProvider)
          .when(
            data: (data) {
              if (data.events.contains(
                "databases.*.collections.${AppwriteConstants.usersCollection}.documents.${copyOfUser.uid}.update",
              )) {
                copyOfUser = UserModel.fromMap(data.payload);
              }
              return UserProfle(user: copyOfUser);
            },
            error: (error, st) => ErrorText(error: error.toString()),
            loading: () {
              return UserProfle(user: copyOfUser);
            },
          ),
    );
  }
}
