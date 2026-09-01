import 'dart:html' as html;
import 'package:flutter/material.dart';

import 'DatabaseHelper.dart';
import 'LocalConstant.dart';

String getBrowserUrl() => html.window.location.href;

void resetWebUrl() {
  html.window.history.replaceState(null, '', '/');
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

        final messageId = item['message_id']?.toString() ?? item['id']?.toString() ?? '';
        Map<String, Object> data = {
          if (messageId.isNotEmpty) 'message_id': messageId,
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
