import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twiiter_clone/constants/appwrite_constants.dart';

final AppwriteClientProvider = Provider((ref) {
  Client client = Client();
  return client
      .setEndpoint(AppwriteConstants.endPoint)
      .setProject(AppwriteConstants.projectId)
      .setSelfSigned(status: true);
});

final appwriteAccountProvider = Provider((ref) {
  final client = ref.watch(AppwriteClientProvider);
  return Account(client);
});

final appwriteDatabaseProvider = Provider((ref) {
  final client = ref.watch(AppwriteClientProvider);
  return Databases(client);
});
 final appwriteStorageProvider = Provider((ref) {
  final client = ref.watch(AppwriteClientProvider);
  return Storage(client);
});
 final appwriteRealtimeProvider = Provider((ref) {
  final client = ref.watch(AppwriteClientProvider);
  return Realtime(client);
});
