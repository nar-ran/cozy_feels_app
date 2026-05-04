class AppAssets {
  static const String _feelingsPath = 'assets/icons/svg/feelings';
  static const String _featuresPath = 'assets/icons/svg/features';
  
  // Emojis de sentimientos 
  static const Map<String, String> sentimentEmojis = {
    'Calm': '$_feelingsPath/sentiment_calm.svg',
    'Content': '$_feelingsPath/sentiment_content.svg',
    'Dissatisfied': '$_feelingsPath/sentiment_dissatisfied.svg',
    'Excited': '$_feelingsPath/sentiment_excited.svg',
    'Extremely Dissatisfied': '$_feelingsPath/sentiment_extremely_dissatisfied.svg',
    'Frustrated': '$_feelingsPath/sentiment_frustrated.svg',
    'Neutral': '$_feelingsPath/sentiment_neutral.svg',
    'Sad': '$_feelingsPath/sentiment_sad.svg',
    'Satisfied': '$_feelingsPath/sentiment_satisfied.svg',
    'Stressed': '$_feelingsPath/sentiment_stressed.svg',
    'Very Dissatisfied': '$_feelingsPath/sentiment_very_dissatisfied.svg',
    'Very Satisfied': '$_feelingsPath/sentiment_very_satisfied.svg',
    'Worried': '$_feelingsPath/sentiment_worried.svg',
    'Sick': '$_feelingsPath/sick.svg',
  };

  // Iconos de funcionalidades (Ajustes, Backups, etc.)
  static const Map<String, String> featureIcons = {
    'Settings': '$_featuresPath/settings_heart.svg'
  };
}