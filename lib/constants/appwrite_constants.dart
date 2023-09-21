class AppwriteConstants {
  static const String databaseId = '650a24bdcecf09c2a653';
  static const String projectId = '650a2484b1bf1ecf786b';
  static const String endPoint = 'https://192.168.77.143:443/v1';


  static const String usersCollection = '650a25772ae2370720d6';
  static const String tweetsCollection = '650a2582be76d68e8f22';
  static const String notificationsCollection = '650a25b6f1ed719c136c';

  static const String imagesBucket = '63cbdab48cdbccb6b34e';

  static String imageUrl(String imageId) =>
      '$endPoint/storage/buckets/$imagesBucket/files/$imageId/view?project=$projectId&mode=admin';
}
