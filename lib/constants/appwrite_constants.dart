class AppwriteConstants {
  static const String databaseId = '65147b403a7e08d3f757';
  static const String projectId = '651478f329bc355618c1';
  static const String endPoint = 'https://cloud.appwrite.io/v1';


  static const String usersCollection = '65147db8246726646839';
  static const String tweetsCollection = '65148550b194e3f83d5b';
  static const String notificationsCollection = '6514a64bb92bbcb9a5ee';

  static const String imagesBucket = '65148b7d4930d40908fa';

  static String imageUrl(String imageId) =>
      '$endPoint/storage/buckets/$imagesBucket/files/$imageId/view?project=$projectId&mode=admin';
}
