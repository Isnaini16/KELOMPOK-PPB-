import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String roomId;
  final String applicantName;
  final String email;
  final String phone;
  final String institution;
  final String purpose;
  final int attendees;
  final Timestamp startAt;
  final Timestamp endAt;
  final String status;
  final String adminNote;
  final Timestamp? createdAt;

  const Booking({
    required this.id,
    required this.roomId,
    required this.applicantName,
    required this.email,
    required this.phone,
    required this.institution,
    required this.purpose,
    required this.attendees,
    required this.startAt,
    required this.endAt,
    required this.status,
    required this.adminNote,
    this.createdAt,
  });

  factory Booking.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Booking(
      id: doc.id,
      roomId: d['room_id']?.toString() ?? '',
      applicantName: d['nama_pemohon']?.toString() ?? '',
      email: d['email_pemohon']?.toString() ?? '',
      phone: d['kontak_pemohon']?.toString() ?? '',
      institution: d['instansi']?.toString() ?? '',
      purpose: d['keperluan']?.toString() ?? '',
      attendees: (d['jumlah_peserta'] as num?)?.toInt() ?? 0,
      startAt: d['start_at'] as Timestamp,
      endAt: d['end_at'] as Timestamp,
      status: d['status']?.toString() ?? 'pending',
      adminNote: d['admin_note']?.toString() ?? '',
      createdAt: d['created_at'] as Timestamp?,
    );
  }

  static String statusLabel(String value) => switch (value) {
    'approved' => 'Disetujui',
    'rejected' => 'Ditolak',
    _ => 'Menunggu',
  };
}
