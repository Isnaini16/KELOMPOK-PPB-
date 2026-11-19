import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room.dart';

class RoomService {
  final _rooms =
      FirebaseFirestore.instance.collection('rooms');

  // Mengambil data ruangan secara realtime
  Stream<List<Room>> watch({bool activeOnly = true}) {
    final Query<Map<String, dynamic>> query =
        activeOnly
            ? _rooms.where('is_active', isEqualTo: true)
            : _rooms;

    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map(Room.fromDoc)
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name)),
    );
  }

  // Menambah atau memperbarui ruangan
  Future<void> save(Room room) async {
    final ref = room.id.isEmpty
        ? _rooms.doc()
        : _rooms.doc(room.id);

    await ref.set({
      ...room.toMap(),
      'room_id': ref.id,
    }, SetOptions(merge: true));
  }

  // Mengaktifkan atau menonaktifkan ruangan
  Future<void> setActive(String id, bool active) async {
    await _rooms.doc(id).update({
      'is_active': active,
    });
  }
}