import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ping_post/common/loading_page.dart';
import 'package:ping_post/features/auth/controller/auth_controller.dart';
import 'package:ping_post/features/users_profile/controller/user_profile_controller.dart';
import 'package:ping_post/features/users_profile/view/user_profile_view.dart';
import 'package:ping_post/theme/pallete.dart';

class SideDrawer extends ConsumerWidget {
  const SideDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserDetailsProvider).value;
    if (currentUser == null) {
      return const Loader();
    }
    return SafeArea(
      child: Drawer(
        backgroundColor: Pallete.backgroundColor,
        child: Column(
          children: [
            const SizedBox(height: 50),
            ListTile(
              leading: const Icon(Icons.person, size: 30),
              title: Text("My Profile", style: TextStyle(fontSize: 22)),
              onTap: () {
                Navigator.push(context, UserProfileView.route(currentUser));
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment, size: 30),
              title: Text("Twitter Blue", style: TextStyle(fontSize: 22)),
              onTap: () {
                ref
                    .read(UserProfileControllerProvider.notifier)
                    .updateUserProfile(
                      userModel: currentUser.copyWith(isTwitterBlue: true),
                      context: context,
                      bannerFile: null,
                      profileImageFile: null,
                    );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, size: 30),
              title: Text("Log Out", style: TextStyle(fontSize: 22)),
              onTap: () {
                ref.read(authControllerProvider.notifier).logout(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
