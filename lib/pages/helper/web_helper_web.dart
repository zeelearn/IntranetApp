import 'dart:html' as html;
import 'package:flutter/material.dart';

import 'DatabaseHelper.dart';
import 'LocalConstant.dart';

String getBrowserUrl() => html.window.location.href;

void resetWebUrl() {
  html.window.history.replaceState(null, '', '/');
}

String? getWebNotificationPermissionState() => html.Notification.permission;

void closeBrowserTab() {
  try {
    html.window.open('', '_self', '');
    html.window.close();
  } catch (e) {
    // Suppress console exception
  }

  // Fallback: Replace the page with a clean, user-friendly logged out screen
  try {
    final body = html.document.body;
    if (body != null) {
      body.style.backgroundColor = '#f5f5f7';
      body.innerHtml = """
        <div style="display: flex; flex-direction: column; align-items: center; justify-content: center; height: 100vh; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: #f5f5f7; color: #1d1d1f; margin: 0; padding: 16px; box-sizing: border-box;">
          <div style="background: white; padding: 40px; border-radius: 16px; box-shadow: 0 4px 20px rgba(0,0,0,0.08); text-align: center; max-width: 400px; width: 100%; box-sizing: border-box;">
            <div style="font-size: 56px; margin-bottom: 20px; color: #34c759;">✓</div>
            <h2 style="margin: 0 0 12px 0; font-size: 24px; font-weight: 600; color: #1d1d1f;">Logged Out Successfully</h2>
            <p style="margin: 0 0 24px 0; color: #86868b; line-height: 1.5; font-size: 15px;">You have been logged out of the Intranet. You may close this tab now.</p>
            <button onclick="window.close()" style="background-color: #0071e3; color: white; border: none; padding: 12px 24px; font-size: 16px; border-radius: 8px; cursor: pointer; font-weight: 500; outline: none; transition: background-color 0.2s;">Close Tab</button>
          </div>
        </div>
      """;
    }
  } catch (e) {
    // If DOM manipulation fails, redirect to about:blank as last resort
    html.window.location.href = 'about:blank';
  }
}

Future<void> syncPendingNotifications() async {
  try {
    final idbFactory = html.window.indexedDB;
    if (idbFactory == null) return;

    // open returns a Future<Database> in Dart
    final dynamic db = await idbFactory.open('background_notifications', version: 1);
    if (db == null || !db.objectStoreNames.contains('notifications')) return;

    final transaction = db.transaction('notifications', 'readwrite');
    final store = transaction.objectStore('notifications');

    final dynamic getAllRequest = store.getAll(null);
    getAllRequest.onSuccess.listen((event) async {
      final List<dynamic> results = getAllRequest.result as List<dynamic>;
      if (results.isEmpty) return;

      final dbHelper = DBHelper();
      for (var item in results) {
        final title = item['title'] ?? '';
        final description = item['description'] ?? '';
        final type = item['type'] ?? '';
        final date = item['date'] ?? '';
        final imageurl = item['imageurl'] ?? '';
        final logoUrl = item['logoUrl'] ?? '';
        final bigImageUrl = item['bigImageUrl'] ?? '';
        final webViewLink = item['webViewLink'] ?? '';

        Map<String, Object> data = {
          'title': title,
          'description': description,
          'type': type,
          'imageurl': imageurl,
          'logoUrl': logoUrl,
          'bigImageUrl': bigImageUrl,
          'webViewLink': webViewLink,
          'date': date,
        };

        await dbHelper.insert(LocalConstant.TABLE_NOTIFICATION, data);
      }

      store.clear();
      debugPrint("Successfully synced ${results.length} background notifications to SQLite.");
    });
  } catch (e) {
    debugPrint("Error syncing background notifications: $e");
  }
}
