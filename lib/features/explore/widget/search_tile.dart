import 'package:flutter/material.dart';
import 'package:ping_post/features/users_profile/view/user_profile_view.dart';
import 'package:ping_post/theme/pallete.dart';

import '../../../models/user_model.dart';

class SearchTile extends StatelessWidget {
  final UserModel userModel;

  const SearchTile({super.key, required this.userModel});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.push(context, UserProfileView.route(userModel));
      },
      leading: CircleAvatar(
        backgroundImage: NetworkImage(userModel.profilePic),
        radius: 30,
      ),
      title: Text(
        userModel.name,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("@${userModel.name}", style: TextStyle(fontSize: 16)),
          Text(
            userModel.bio,
            style: TextStyle(fontSize: 16, color: Pallete.whiteColor),
          ),
        ],
      ),
    );
  }
}
