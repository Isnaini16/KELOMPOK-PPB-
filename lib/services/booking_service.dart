import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/booking.dart';
import 'schedule_service.dart';

class BookingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Booking>> watchAll() => _db.collection('bookings')
      .snapshots().map((snap) => snap.docs.map(Booking.fromDoc).toList()
        ..sort((a, b) => (b.createdAt?.millisecondsSinceEpoch ?? 0)
            .compareTo(a.createdAt?.millisecondsSinceEpoch ?? 0)));

  Future<String> submit({required String roomId, required String name,
    required String email, required String phone, required String institution,
    required String purpose, required int attendees, required DateTime start,
    required DateTime end}) async {
    if (!end.isAfter(start) || !start.isAfter(DateTime.now())) {
      throw Exception('Waktu peminjaman harus di masa mendatang.');
    }
    final roomSnap = await _db.collection('rooms').doc(roomId)
      .get(const GetOptions(source: Source.server));
    if (!roomSnap.exists || roomSnap.data()?['is_active'] != true) {
      throw Exception('Ruangan sedang tidak tersedia.');
    }
    final cap = (roomSnap.data()?['capacity'] as num?)?.toInt() ?? 0;
    if (attendees < 1 || attendees > cap) throw Exception('Jumlah peserta melebihi kapasitas ruangan.');
    if (await ScheduleService().conflicts(roomId, start, end)) {
      throw Exception('Jadwal tersebut sudah terpakai. Pilih slot lain.');
    }
    final ref = _db.collection('bookings').doc();
    await ref.set({
      'booking_id': ref.id, 'room_id': roomId,
      'nama_pemohon': name.trim(), 'email_pemohon': email.trim(),
      'kontak_pemohon': phone.trim(), 'instansi': institution.trim(),
      'keperluan': purpose.trim(), 'jumlah_peserta': attendees,
      'start_at': Timestamp.fromDate(start), 'end_at': Timestamp.fromDate(end),
      'status': 'pending', 'admin_note': '', 'processed_by': '',
      'processed_at': null, 'created_at': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  // Persetujuan memakai revisi ruangan + transaksi agar dua admin yang
  // memproses pada saat bersamaan tidak sama-sama menyetujui slot serupa.
  Future<void> decide(Booking booking, {required bool approve, String reason = ''}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Login admin terlebih dahulu.');
    if (!approve && reason.trim().isEmpty) throw Exception('Tulis alasan penolakan.');
    final bRef = _db.collection('bookings').doc(booking.id);
    final rRef = _db.collection('rooms').doc(booking.roomId);
    var expectedRevision = 0;
    if (approve) {
      final initial = await rRef.get(const GetOptions(source: Source.server));
      if (!initial.exists || initial.data()?['is_active'] != true) throw Exception('Ruangan tidak aktif.');
      expectedRevision = (initial.data()?['schedule_revision'] as num?)?.toInt() ?? 0;
      if (await ScheduleService().conflicts(booking.roomId, booking.startAt.toDate(), booking.endAt.toDate())) {
        throw Exception('Waktu bertabrakan dengan peminjaman lain.');
      }
    }
    await _db.runTransaction((tx) async {
      final latestDoc = await tx.get(bRef);
      if (!latestDoc.exists || latestDoc.data()?['status'] != 'pending') {
        throw Exception('Pengajuan sudah diproses.');
      }
      final latest = Booking.fromDoc(latestDoc);
      if (latest.roomId != booking.roomId || latest.startAt != booking.startAt || latest.endAt != booking.endAt) {
        throw Exception('Data pengajuan berubah. Muat ulang.');
      }
      if (approve) {
        final roomDoc = await tx.get(rRef);
        final revision = (roomDoc.data()?['schedule_revision'] as num?)?.toInt() ?? 0;
        if (roomDoc.data()?['is_active'] != true || revision != expectedRevision) {
          throw Exception('Jadwal berubah. Periksa ulang sebelum menyetujui.');
        }
        if (latest.startAt.toDate().isBefore(DateTime.now())) throw Exception('Jadwal sudah lewat.');
        final scheduleRef = _db.collection('schedules').doc(booking.id);
        tx.update(rRef, {'schedule_revision': revision + 1});
        tx.set(scheduleRef, {
          'schedule_id': booking.id, 'room_id': booking.roomId,
          'start_at': latest.startAt, 'end_at': latest.endAt,
          'schedule_type': 'booking', 'status': 'occupied',
          'created_at': FieldValue.serverTimestamp(),
        });
      }
      tx.update(bRef, {
        'status': approve ? 'approved' : 'rejected',
        'admin_note': approve ? '' : reason.trim(),
        'processed_by': uid, 'processed_at': FieldValue.serverTimestamp(),
      });
    });
  }
}
