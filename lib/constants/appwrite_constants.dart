class AppwriteConstants {
  static const String databaseId = '6798ec9d0025a0eb6e1c';
  static const String projectId = '6798d4a60003e31ba17d';
  static const String endPoint = 'https://cloud.appwrite.io/v1';

  static const String usersCollection = '67a358f0002d2d228a52';
  static const String tweetsCollection = '67ab336800146f4238c3';
  static const String notificationsCollection = '67ffb24d002c1005dda5';

  static const String imagesBucket = '67e551670021d8af23b6';

  static String imageUrl(String imageId) =>
      "$endPoint/storage/buckets/$imagesBucket/files/$imageId/view?project=$projectId&mode=admin";
}
