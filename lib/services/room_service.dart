import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room.dart';

class RoomService {
  final CollectionReference<Map<String, dynamic>> _rooms = FirebaseFirestore.instance.collection('rooms');

  Stream<List<Room>> watch({bool activeOnly = true}) {
    final Query<Map<String, dynamic>> q = activeOnly ? _rooms.where('is_active', isEqualTo: true) : _rooms;
    return q.snapshots().map((snap) => snap.docs.map(Room.fromDoc).toList()
      ..sort((a, b) => a.name.compareTo(b.name)));
  }

  Future<Room> get(String id) async => Room.fromDoc(await _rooms.doc(id).get());

  Future<void> save(Room room) async {
    final ref = room.id.isEmpty ? _rooms.doc() : _rooms.doc(room.id);
    final fields = room.toMap();
    fields['room_id'] = ref.id;
    if (room.id.isEmpty) fields['schedule_revision'] = 0;
    await ref.set(fields, SetOptions(merge: true));
  }

  Future<void> deactivate(String id) => _rooms.doc(id).update({'is_active': false});
}
