import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/time_utils.dart';

class Schedule {
  final String id;
  final String roomId;
  final String type;
  final String status;
  final Timestamp startAt;
  final Timestamp endAt;
  const Schedule({required this.id, required this.roomId, required this.type,
    required this.status, required this.startAt, required this.endAt});

  factory Schedule.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Schedule(id: doc.id,
      roomId: d['room_id']?.toString() ?? '',
      type: d['schedule_type']?.toString() ?? 'booking',
      status: d['status']?.toString() ?? 'occupied',
      startAt: d['start_at'] as Timestamp,
      endAt: d['end_at'] as Timestamp,
    );
  }
  bool blocks(DateTime startUtc, DateTime endUtc) =>
      status == 'occupied' && overlaps(startAt.toDate(), endAt.toDate(), startUtc, endUtc);
}
