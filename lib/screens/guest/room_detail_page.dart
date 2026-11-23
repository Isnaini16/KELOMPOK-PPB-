import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/time_utils.dart';
import '../../core/ui_widgets.dart';
import '../../models/room.dart';
import '../../models/schedule.dart';
import '../../services/schedule_service.dart';
import 'booking_form_page.dart';

class RoomDetailPage extends StatefulWidget {
  final Room room;
  const RoomDetailPage({super.key, required this.room});
  @override
  State<RoomDetailPage> createState() => _RoomDetailPageState();
}

class _RoomDetailPageState extends State<RoomDetailPage> {
  DateTime day = todayWib();
  @override
  Widget build(BuildContext context) {
    final room = widget.room;
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Ruangan & Jadwal')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RoomPhoto(room: room, height: 208),
          const SizedBox(height: 14),
          Text(
            room.name,
            style: const TextStyle(
              color: Palette.ink,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Wrap(
            spacing: 14,
            children: [
              Text(
                '🏢 ${room.building}',
                style: const TextStyle(fontSize: 12, color: Palette.softInk),
              ),
              Text(
                'Lantai ${room.floor}',
                style: const TextStyle(fontSize: 12, color: Palette.softInk),
              ),
              Text(
                '${room.capacity} Orang',
                style: const TextStyle(fontSize: 12, color: Palette.softInk),
              ),
            ],
          ),
          const PageSectionTitle('Fasilitas'),
          Wrap(
            spacing: 7,
            runSpacing: 4,
            children: room.facilities
                .map(
                  (item) => Chip(
                    label: Text(item, style: const TextStyle(fontSize: 12)),
                    backgroundColor: const Color(0xFFEEE5FB),
                    side: BorderSide.none,
                  ),
                )
                .toList(),
          ),
          const PageSectionTitle('Jadwal Ketersediaan'),
          OutlinedButton.icon(
            onPressed: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: day,
                firstDate: todayWib(),
                lastDate: todayWib().add(const Duration(days: 365)),
              );
              if (d != null) setState(() => day = d);
            },
            icon: const Icon(Icons.calendar_month),
            label: Text(dateLong(day)),
          ),
          const SizedBox(height: 10),
          StreamBuilder<List<Schedule>>(
            stream: ScheduleService().watchForRoom(room.id),
            builder: (context, snapshot) {
              if (snapshot.hasError)
                return Text('Gagal menampilkan jadwal: ${snapshot.error}');
              if (!snapshot.hasData)
                return const Center(child: CircularProgressIndicator());
              return Column(
                children: [
                  for (final slot in bookingSlots)
                    _SlotRow(
                      slot: slot,
                      available:
                          slot.startUtc(day).isAfter(DateTime.now()) &&
                          !snapshot.data!.any(
                            (s) =>
                                s.blocks(slot.startUtc(day), slot.endUtc(day)),
                          ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingFormPage(
                            room: room,
                            initialDate: day,
                            initialSlot: slot,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          const Text(
            'Hijau = tersedia, merah = terpakai. Pilih slot hijau untuk mengajukan peminjaman.',
            style: TextStyle(fontSize: 11, color: Palette.softInk),
          ),
        ],
      ),
    );
  }
}

class _SlotRow extends StatelessWidget {
  final TimeSlot slot;
  final bool available;
  final VoidCallback onTap;
  const _SlotRow({
    required this.slot,
    required this.available,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      dense: true,
      title: Text(
        slot.label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: available ? const Color(0xFFDCF4E5) : const Color(0xFFFFE1E3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          available ? 'Tersedia' : 'Terpakai',
          style: TextStyle(
            color: available ? Palette.success : Palette.danger,
            fontSize: 11,
          ),
        ),
      ),
      onTap: available ? onTap : null,
    ),
  );
}
