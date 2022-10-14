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
  static sendEvent(String userName) async{
    await FirebaseAnalytics.instance.setUserProperty(name: 'login_user', value: userName);
  }
}