
import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/ui_widgets.dart';
import '../../models/room.dart';
import '../../models/schedule.dart';
import '../../services/room_service.dart';
import '../../services/schedule_service.dart';
import '../../core/time_utils.dart';
import '../auth/admin_gate.dart';
import 'room_detail_page.dart';

class GuestShell extends StatefulWidget {
  const GuestShell({super.key});
  @override
  State<GuestShell> createState() => _GuestShellState();
}

class _GuestShellState extends State<GuestShell> {
  int index = 0;
  String query = '';
  String category = 'semua';
  DateTime day = todayWib();

  void openRoom(Room room) => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => RoomDetailPage(room: room)),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('SIPIRANG JPTK'),
      leading: const Padding(
        padding: EdgeInsets.only(left: 12),
        child: Icon(Icons.calendar_month_rounded, color: Palette.primary),
      ),
      actions: [
        TextButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminGate()),
          ),
          icon: const Icon(Icons.admin_panel_settings_outlined, size: 17),
          label: const Text('Admin'),
        ),
      ],
    ),
    body: SafeArea(
      child: IndexedStack(
        index: index,
        children: [
          _GuestHome(
            onSearch: (text) => setState(() {
              query = text;
              index = 1;
            }),
            onCatalog: () => setState(() => index = 1),
            onSchedule: () => setState(() => index = 2),
            onRoom: openRoom,
          ),
          _GuestCatalog(
            query: query,
            category: category,
            onQuery: (s) => setState(() => query = s),
            onCategory: (s) => setState(() => category = s),
            onRoom: openRoom,
          ),
          _GuestSchedule(
            selectedDay: day,
            onDayChanged: (d) => setState(() => day = d),
          ),
        ],
      ),
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: index,
      onDestinationSelected: (n) => setState(() => index = n),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Beranda',
        ),
        NavigationDestination(
          icon: Icon(Icons.meeting_room_outlined),
          selectedIcon: Icon(Icons.meeting_room),
          label: 'Ruangan',
        ),
        NavigationDestination(
          icon: Icon(Icons.event_note_outlined),
          selectedIcon: Icon(Icons.event_note),
          label: 'Jadwal',
        ),
      ],
    ),
  );
}

class _GuestHome extends StatelessWidget {
  final ValueChanged<String> onSearch;
  final VoidCallback onCatalog;
  final VoidCallback onSchedule;
  final ValueChanged<Room> onRoom;
  const _GuestHome({
    required this.onSearch,
    required this.onCatalog,
    required this.onSchedule,
    required this.onRoom,
  });

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      const GradientBanner(
        title: 'SIPIRANG JPTK',
        subtitle: 'Sistem Pinjam Ruang JPTK',
        icon: Icons.apartment_rounded,
      ),
      const SizedBox(height: 14),
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFE7D8FB),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat datang di SIPIRANG!',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Palette.primaryDark,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Mau pinjam ruangan apa?',
              style: TextStyle(fontSize: 16, color: Palette.ink),
            ),
            SizedBox(height: 10),
            Text(
              'Cari ruangan, cek jadwal, dan ajukan peminjaman tanpa membuat akun.',
              style: TextStyle(color: Palette.softInk, fontSize: 12),
            ),
          ],
        ),
      ),
      const SizedBox(height: 15),
      TextField(
        decoration: const InputDecoration(
          hintText: 'Cari ruangan...',
          prefixIcon: Icon(Icons.search),
        ),
        onSubmitted: onSearch,
      ),
      const SizedBox(height: 14),
      Row(
        children: [
          Expanded(
            child: _Shortcut(
              icon: Icons.view_list_rounded,
              label: 'Daftar Ruangan',
              onTap: onCatalog,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _Shortcut(
              icon: Icons.calendar_month_rounded,
              label: 'Cek Jadwal',
              onTap: onSchedule,
            ),
          ),
        ],
      ),
      const PageSectionTitle('Ruangan Tersedia'),
      StreamBuilder<List<Room>>(
        stream: RoomService().watch(),
        builder: (context, snap) {
          if (snap.hasError) return Text('Gagal membaca data: ${snap.error}');
          if (!snap.hasData)
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            );
          if (snap.data!.isEmpty)
            return const Text('Belum ada data ruangan aktif.');
          return Column(
            children: snap.data!
                .take(3)
                .map((r) => RoomTile(room: r, onTap: () => onRoom(r)))
                .toList(),
          );
        },
      ),
    ],
  );
}

class _Shortcut extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _Shortcut({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xFFEFE7FC),
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: Palette.primary, size: 31),
            const SizedBox(height: 9),
            Text(
              label,
              style: const TextStyle(
                color: Palette.primaryDark,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _GuestCatalog extends StatelessWidget {
  final String query;
  final String category;
  final ValueChanged<String> onQuery;
  final ValueChanged<String> onCategory;
  final ValueChanged<Room> onRoom;
  const _GuestCatalog({
    required this.query,
    required this.category,
    required this.onQuery,
    required this.onCategory,
    required this.onRoom,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 6),
        child: Text(
          'Daftar Ruangan',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: Palette.ink,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextFormField(
          initialValue: query,
          decoration: const InputDecoration(
            hintText: 'Cari nama ruangan',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: onQuery,
        ),
      ),
      SizedBox(
        height: 54,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          scrollDirection: Axis.horizontal,
          children: [
            for (final name in ['semua', 'kelas', 'seminar', 'sidang', 'aula'])
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: ChoiceChip(
                  label: Text(
                    name == 'semua'
                        ? 'Semua'
                        : '${name[0].toUpperCase()}${name.substring(1)}',
                  ),
                  selected: category == name,
                  onSelected: (_) => onCategory(name),
                ),
              ),
          ],
        ),
      ),
      Expanded(
        child: StreamBuilder<List<Room>>(
          stream: RoomService().watch(),
          builder: (context, snap) {
            if (snap.hasError)
              return Center(
                child: Text('Gagal membaca ruangan: ${snap.error}'),
              );
            if (!snap.hasData)
              return const Center(child: CircularProgressIndicator());
            final items = snap.data!
                .where(
                  (r) =>
                      (category == 'semua' || r.type == category) &&
                      (r.name.toLowerCase().contains(query.toLowerCase()) ||
                          r.building.toLowerCase().contains(
                            query.toLowerCase(),
                          )),
                )
                .toList();
            if (items.isEmpty)
              return const Center(child: Text('Ruangan tidak ditemukan.'));
            return ListView(
              padding: const EdgeInsets.all(14),
              children: items
                  .map((r) => RoomTile(room: r, onTap: () => onRoom(r)))
                  .toList(),
            );
          },
        ),
      ),
    ],
  );
}

class _GuestSchedule extends StatelessWidget {
  final DateTime selectedDay;
  final ValueChanged<DateTime> onDayChanged;
  const _GuestSchedule({required this.selectedDay, required this.onDayChanged});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      const PageSectionTitle('Jadwal Ruangan'),
      const Text(
        'Lihat waktu yang sudah dipakai tanpa melihat data pribadi peminjam.',
        style: TextStyle(color: Palette.softInk, fontSize: 12),
      ),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: () async {
          final d = await showDatePicker(
            context: context,
            initialDate: selectedDay,
            firstDate: todayWib().subtract(const Duration(days: 30)),
            lastDate: todayWib().add(const Duration(days: 365)),
          );
          if (d != null) onDayChanged(d);
        },
        icon: const Icon(Icons.calendar_month),
        label: Text(dateLong(selectedDay)),
      ),
      StreamBuilder<List<Room>>(
        stream: RoomService().watch(),
        builder: (context, rooms) {
          if (!rooms.hasData) return const LinearProgressIndicator();
          return StreamBuilder<List<Schedule>>(
            stream: ScheduleService().watchAll(),
            builder: (context, schedules) {
              if (schedules.hasError)
                return Text('Gagal membaca jadwal: ${schedules.error}');
              if (!schedules.hasData) return const LinearProgressIndicator();
              final map = {for (final r in rooms.data!) r.id: r.name};
              final items = schedules.data!.where((s) {
                final d = toWib(s.startAt.toDate());
                return s.status == 'occupied' &&
                    d.year == selectedDay.year &&
                    d.month == selectedDay.month &&
                    d.day == selectedDay.day;
              }).toList()..sort((a, b) => a.startAt.compareTo(b.startAt));
              if (items.isEmpty)
                return const Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: Center(
                    child: Text('Belum ada jadwal terpakai pada tanggal ini.'),
                  ),
                );
              return Column(
                children: items
                    .map(
                      (s) => Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.event_busy_outlined,
                            color: Palette.primary,
                          ),
                          title: Text(map[s.roomId] ?? s.roomId),
                          subtitle: Text(
                            '${two(toWib(s.startAt.toDate()).hour)}.00 – ${two(toWib(s.endAt.toDate()).hour)}.00 WIB',
                          ),
                          trailing: const Text(
                            'Terpakai',
                            style: TextStyle(
                              color: Palette.danger,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          );
        },
      ),
    ],
  );
}
