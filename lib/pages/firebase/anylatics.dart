import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseAnalyticsUtils{
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  Future<void> sendAnalyticsEvent(String currentScreen) async {
    await analytics.setCurrentScreen(
      screenName: currentScreen,
      screenClassOverride: currentScreen,
    );
  }
  enableAnytics() async{
    await analytics.setAnalyticsCollectionEnabled(true);
  }
}