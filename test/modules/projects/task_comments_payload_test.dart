import 'package:flutter_test/flutter_test.dart';
import 'package:Intranet/modules/projects/models/task_comments_payload.dart';

void main() {
  group('TaskCommentsPayload', () {
    test('merges comments and files oldest first; isMine by CreatedBy', () {
      final payload = TaskCommentsPayload.fromApiEnvelope({
        'success': 200,
        'data': [
          {
            'comments': [
              {
                'comment': 'older',
                'CreatedBy': '111',
                'CreatedDate': '2024-06-24T12:00:00.000',
                'createduser': 'Other',
                'createdtime': '12:00 PM',
              },
              {
                'comment': 'newer',
                'CreatedBy': '34350',
                'CreatedDate': '2024-06-27T13:56:02.123',
                'createduser': 'Me',
                'createdtime': '01:56 PM',
              },
            ],
            'Files': [
              {
                'file_name': '',
                'file_path':
                    'https://example.com/a.png',
                'remarks': '',
                'CreatedBy': '34350',
                'createduser': 'Me',
                'CreatedDate': '2026-07-16T15:26:46.270',
              }
            ],
          }
        ],
      });

      final timeline = payload.toTimeline(userId: 34350);
      expect(timeline.length, 3);
      expect(timeline.first.message, 'older');
      expect(timeline.first.isMine, isFalse);
      expect(timeline[1].message, 'newer');
      expect(timeline[1].isMine, isTrue);
      expect(timeline.last.attachments, isNotEmpty);
      expect(timeline.last.isMine, isTrue);
    });
  });
}
