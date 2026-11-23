import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../core/time_utils.dart';
import '../../core/ui_widgets.dart';
import '../../models/room.dart';
import '../../models/schedule.dart';
import '../../services/booking_service.dart';
import '../../services/schedule_service.dart';
import 'booking_success_page.dart';

class BookingFormPage extends StatefulWidget {
  final Room room;
  final DateTime initialDate;
  final TimeSlot initialSlot;
  const BookingFormPage({super.key, required this.room, required this.initialDate, required this.initialSlot});
  @override State<BookingFormPage> createState() => _BookingFormPageState();
}


class _BookingFormPageState extends State<BookingFormPage> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final institution = TextEditingController();
  final purpose = TextEditingController();
  final attendees = TextEditingController();
  late DateTime date;
  late TimeSlot slot;
  bool saving = false;

  @override void initState() { super.initState(); date = widget.initialDate; slot = widget.initialSlot; }
  @override void dispose() {
    for (final x in [name, email, phone, institution, purpose, attendees]) { x.dispose(); }
    super.dispose();
  }
  Future<void> send() async {
    if (!formKey.currentState!.validate() || saving) return;
    setState(() => saving = true);
    try {
      final start = slot.startUtc(date);
      final end = slot.endUtc(date);
      final bookingId = await BookingService().submit(
        roomId: widget.room.id,
        name: name.text, email: email.text, phone: phone.text,
        institution: institution.text, purpose: purpose.text,
        attendees: int.parse(attendees.text), start: start, end: end,
      );
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => BookingSuccessPage(
        bookingId: bookingId, room: widget.room, date: date, slot: slot,
      )));
    } catch (e) {
      if (mounted) showSnack(context, 'Pengajuan gagal: $e');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Ajukan Peminjaman')),
    body: Form(key: formKey, child: ListView(padding: const EdgeInsets.all(16), children: [
      const GradientBanner(title: 'Form Peminjaman', subtitle: 'Isi identitas tanpa login', icon: Icons.edit_calendar),
      const SizedBox(height: 18),
      const _Label('Ruangan'),
      InputDecorator(decoration: const InputDecoration(), child: Text(widget.room.name)),
      const SizedBox(height: 13),
      const _Label('Tanggal'),
      OutlinedButton.icon(icon: const Icon(Icons.calendar_month), label: Text(dateLong(date)), onPressed: () async {
        final d = await showDatePicker(context: context, initialDate: date,
          firstDate: todayWib(), lastDate: todayWib().add(const Duration(days: 365)));
        if (d != null) setState(() => date = d);
      }),
      const SizedBox(height: 13),
      const _Label('Waktu'),
      StreamBuilder<List<Schedule>>(stream: ScheduleService().watchForRoom(widget.room.id), builder: (context, snap) {
        if (snap.hasError) return Text('Gagal membaca jadwal: ${snap.error}');
        if (!snap.hasData) return const LinearProgressIndicator();
        return Wrap(spacing: 7, runSpacing: 5, children: [
          for (final s in bookingSlots)
            ChoiceChip(label: Text(s.label, style: const TextStyle(fontSize: 11)),
              selected: s.startHour == slot.startHour,
              onSelected: s.startUtc(date).isAfter(DateTime.now()) &&
                !snap.data!.any((x) => x.blocks(s.startUtc(date), s.endUtc(date)))
                ? (_) => setState(() => slot = s) : null),
        ]);
      }),
      const SizedBox(height: 15),
      _Field(label: 'Nama Pemohon *', controller: name, hint: 'Masukkan nama lengkap'),
      _Field(label: 'Email *', controller: email, hint: 'contoh@student.uns.ac.id',
        type: TextInputType.emailAddress, validator: (v) {
          if (v == null || !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v.trim())) return 'Masukkan email yang benar';
          return null;
        }),
      _Field(label: 'Nomor WhatsApp *', controller: phone, hint: '08xxxxxxxxxx',
        type: TextInputType.phone, validator: (v) {
          if (v == null || !RegExp(r'^\+?[0-9]{9,15}$').hasMatch(v.trim())) return 'Masukkan nomor WhatsApp valid';
          return null;
        }),
      _Field(label: 'Instansi / Organisasi *', controller: institution, hint: 'Contoh: HMP PTIK'),
      _Field(label: 'Keperluan Kegiatan *', controller: purpose, hint: 'Contoh: Rapat koordinasi'),
      _Field(label: 'Jumlah Peserta *', controller: attendees,
        hint: 'Maksimal ${widget.room.capacity} orang', type: TextInputType.number,
        validator: (v) {
          final n = int.tryParse(v?.trim() ?? '');
          if (n == null || n < 1 || n > widget.room.capacity) return 'Masukkan 1–${widget.room.capacity} peserta';
          return null;
        }),
      const SizedBox(height: 12),
      FilledButton.icon(onPressed: saving ? null : send,
        icon: const Icon(Icons.send_rounded), label: Text(saving ? 'Mengirim...' : 'Kirim Pengajuan')),
      const SizedBox(height: 12),
      const Text('Pengajuan akan berstatus Menunggu sampai admin memberikan keputusan.',
        textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Palette.softInk)),
    ])),
  );
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Text(text, style: const TextStyle(fontSize: 13, color: Palette.ink, fontWeight: FontWeight.w700)),
  );
}
class _Field extends StatelessWidget {
  final String label, hint;
  final TextEditingController controller;
  final TextInputType type;
  final String? Function(String?)? validator;
  const _Field({required this.label, required this.hint, required this.controller,
    this.type = TextInputType.text, this.validator});
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 13), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        _Label(label), TextFormField(
          controller: controller, keyboardType: type, maxLength: 250,
          validator: validator ?? (v) => (v ?? '').trim().isEmpty ? 'Wajib diisi' : null,
          decoration: InputDecoration(hintText: hint, counterText: ''),
        ),
      ],
    ),
  );
}
