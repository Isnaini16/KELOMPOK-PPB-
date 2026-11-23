import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/schedule.dart';
import '../core/time_utils.dart';

class ScheduleService {
  final CollectionReference<Map<String, dynamic>> _collection = FirebaseFirestore.instance.collection('schedules');

  Stream<List<Schedule>> watchForRoom(String roomId) =>
    _collection.where('room_id', isEqualTo: roomId).snapshots().map(
      (snap) => snap.docs.map(Schedule.fromDoc).toList());

  Stream<List<Schedule>> watchAll() => _collection.snapshots().map(
    (snap) => snap.docs.map(Schedule.fromDoc).toList());

  Future<bool> conflicts(String roomId, DateTime start, DateTime end) async {
    final snap = await _collection.where('room_id', isEqualTo: roomId)
      .get(const GetOptions(source: Source.server));
    return snap.docs.map(Schedule.fromDoc).any((s) => s.blocks(start, end));
  }

  Future<void> blockSlot(String roomId, DateTime day, TimeSlot slot) async {
    final start = slot.startUtc(day), end = slot.endUtc(day);
    final db = FirebaseFirestore.instance;
    final rRef = db.collection('rooms').doc(roomId);
    final rSnap = await rRef.get(const GetOptions(source: Source.server));
    if (!rSnap.exists || rSnap.data()?['is_active'] != true) throw Exception('Ruangan tidak tersedia.');
    final revision = (rSnap.data()?['schedule_revision'] as num?)?.toInt() ?? 0;
    if (await conflicts(roomId, start, end)) throw Exception('Slot sudah terpakai.');
    await db.runTransaction((tx) async {
      final fresh = await tx.get(rRef);
      final currentRevision = (fresh.data()?['schedule_revision'] as num?)?.toInt() ?? 0;
      if (currentRevision != revision || fresh.data()?['is_active'] != true) throw Exception('Jadwal berubah, coba lagi.');
      final sRef = db.collection('schedules').doc();
      tx.update(rRef, {'schedule_revision': revision + 1});
      tx.set(sRef, {
        'schedule_id': sRef.id, 'room_id': roomId,
        'start_at': Timestamp.fromDate(start), 'end_at': Timestamp.fromDate(end),
        'schedule_type': 'blocked', 'status': 'occupied',
        'created_at': FieldValue.serverTimestamp(),
      });
    });
  }
}
