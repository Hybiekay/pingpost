import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twiiter_clone/apis/user_api.dart';

import '../../../models/user_model.dart';

final ExploreControllerProvider = StateNotifierProvider((ref) {
  return ExploreController(
    userAPI: ref.watch(UserAPIProvider),
  );
});
final searchUserProvider = FutureProvider.family((ref, String name) async {
  final exploreController = ref.watch(ExploreControllerProvider.notifier);
  return exploreController.searchUser(name);
});

class ExploreController extends StateNotifier<bool> {
  final UserAPI _userAPI;
  ExploreController({required UserAPI userAPI})
      : _userAPI = userAPI,
        super(false);
  Future<List<UserModel>> searchUser(String name) async {
    final users = await _userAPI.searchUserByName(name);
    return users.map((e) => UserModel.fromMap(e.data)).toList();
  }
}
