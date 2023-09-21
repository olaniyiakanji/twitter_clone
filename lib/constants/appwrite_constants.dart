class AppwriteConstants {
  static const String databaseId = '650c678c7ac6ac69ba40';
  static const String projectId = '650c65112b86c18555eb';
  static const String endPoint = 'https://172.20.10.5:443/v1';


  static const String usersCollection = '650c67914f9943b664a2';
  static const String tweetsCollection = '650c679ad5f3b00fd551';
  static const String notificationsCollection = '650c67cc3ddfa5e4639c';

  static const String imagesBucket = '63cbdab48cdbccb6b34e';

  static String imageUrl(String imageId) =>
      '$endPoint/storage/buckets/$imagesBucket/files/$imageId/view?project=$projectId&mode=admin';
}
