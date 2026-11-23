import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../core/time_utils.dart';
import '../../models/room.dart';

class BookingSuccessPage extends StatelessWidget {
  final String bookingId;
  final Room room;
  final DateTime date;
  final TimeSlot slot;
  const BookingSuccessPage({super.key, required this.bookingId, required this.room, required this.date, required this.slot});
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Konfirmasi Pengajuan')),
    body: Center(child: SingleChildScrollView(child: Padding(
      padding: const EdgeInsets.all(22), child: Column(children: [
        Container(padding: const EdgeInsets.all(25), decoration: const BoxDecoration(
          color: Color(0xFFEFE4FC), shape: BoxShape.circle),
          child: const Icon(Icons.event_available_rounded, size: 79, color: Palette.primary)),
        const SizedBox(height: 17),
        const Text('Pengajuan Terkirim!', textAlign: TextAlign.center,
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: Palette.primaryDark)),
        const SizedBox(height: 10),
        const Text('Permohonan peminjaman berhasil dikirim. Silakan tunggu konfirmasi dari admin JPTK.',
          textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Palette.softInk)),
        const SizedBox(height: 23),
        Card(color: const Color(0xFFF0EAFB), child: Padding(
          padding: const EdgeInsets.all(16), child: Column(children: [
            const Text('Detail Pengajuan', style: TextStyle(fontWeight: FontWeight.bold, color: Palette.primaryDark)),
            const SizedBox(height: 12),
            _Detail(label: 'Ruangan', value: room.name),
            _Detail(label: 'Tanggal', value: dateLong(date)),
            _Detail(label: 'Waktu', value: '${slot.label} WIB'),
            const SizedBox(height: 10),
            const Text('Kode pengajuan (simpan):', style: TextStyle(color: Palette.softInk, fontSize: 11)),
            SelectableText(bookingId, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11)),
          ]),
        )),
        const SizedBox(height: 14),
        const Text('Status saat ini: MENUNGGU. Pengajuan belum otomatis disetujui.',
          style: TextStyle(color: Palette.warning, fontWeight: FontWeight.w700, fontSize: 11), textAlign: TextAlign.center),
        const SizedBox(height: 18),
        SizedBox(width: double.infinity, child: OutlinedButton(
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          child: const Text('Kembali ke Beranda'),
        )),
      ]),
    ))),
  );
}
class _Detail extends StatelessWidget {
  final String label, value;
  const _Detail({required this.label, required this.value});
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [
      Text('$label  : ', style: const TextStyle(fontSize: 12, color: Palette.softInk)),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
    ]),
  );
}

