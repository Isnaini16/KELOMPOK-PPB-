import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../core/time_utils.dart';
import '../../core/ui_widgets.dart';
import '../../models/booking.dart';
import '../../services/booking_service.dart';

class BookingDetailPage extends StatefulWidget {
  final Booking booking;
  final String roomName;
  const BookingDetailPage({super.key, required this.booking, required this.roomName});
  @override State<BookingDetailPage> createState() => _BookingDetailPageState();
}
class _BookingDetailPageState extends State<BookingDetailPage> {
  bool loading = false;
  Future<void> decide(bool approve) async {
    var reason = '';
    if (!approve) {
      final ctrl = TextEditingController();
      final result = await showDialog<String>(context: context, builder: (context) => AlertDialog(
        title: const Text('Alasan Penolakan'),
        content: TextField(controller: ctrl, maxLength: 500, maxLines: 3,
          decoration: const InputDecoration(hintText: 'Contoh: Jadwal ruangan sudah digunakan.')),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()), child: const Text('Tolak Pengajuan'))],
      ));
      ctrl.dispose();
      if (result == null || result.isEmpty) {
        if (result != null && mounted) showSnack(context, 'Alasan penolakan wajib diisi.');
        return;
      }
      reason = result;
    }
    setState(() => loading = true);
    try {
      await BookingService().decide(widget.booking, approve: approve, reason: reason);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (mounted) showSnack(context, 'Tidak dapat memproses: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }
  @override Widget build(BuildContext context) {
    final b = widget.booking;
    return Scaffold(appBar: AppBar(title: const Text('Detail Pengajuan')),
      body: ListView(padding: const EdgeInsets.all(17), children: [
        Card(color: const Color(0xFFF0E9FA), child: Padding(padding: const EdgeInsets.all(18), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(widget.roomName,
                style: const TextStyle(color: Palette.primaryDark, fontWeight: FontWeight.w800, fontSize: 17))),
              StatusTag(status: b.status),
            ]),
            const SizedBox(height: 14),
            _Detail('Nama Pemohon', b.applicantName),
            _Detail('Email', b.email),
            _Detail('Nomor WhatsApp', b.phone),
            _Detail('Instansi / Organisasi', b.institution),
            _Detail('Keperluan', b.purpose),
            _Detail('Jumlah Peserta', '${b.attendees} orang'),
            _Detail('Mulai', stampLabel(b.startAt)),
            _Detail('Selesai', stampLabel(b.endAt)),
            if (b.adminNote.isNotEmpty) _Detail('Alasan Admin', b.adminNote),
          ]))),
        const SizedBox(height: 18),
        if (b.status == 'pending') Row(children: [
          Expanded(child: OutlinedButton.icon(onPressed: loading ? null : () => decide(false),
            icon: const Icon(Icons.close), label: const Text('Tolak'))),
          const SizedBox(width: 11),
          Expanded(child: FilledButton.icon(onPressed: loading ? null : () => decide(true),
            icon: const Icon(Icons.check), label: Text(loading ? 'Proses...' : 'Setujui'))),
        ]),
      ]),
    );
  }
}
class _Detail extends StatelessWidget {
  final String keyLabel, value;
  const _Detail(this.keyLabel, this.value);
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(keyLabel, style: const TextStyle(fontSize: 11, color: Palette.softInk)),
      Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
    ],
  ));
}
