import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/app_theme.dart';
import '../../core/time_utils.dart';
import '../../core/ui_widgets.dart';
import '../../models/booking.dart';
import '../../models/room.dart';
import '../../services/booking_service.dart';
import '../../services/room_service.dart';
import '../../services/schedule_service.dart';
import '../../services/auth_service.dart';
import 'booking_detail_page.dart';
import 'room_editor_page.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});
  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int tab = 0;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        [
          'Dashboard Admin',
          'Kelola Pengajuan',
          'Manajemen Ruangan',
          'Profil Admin',
        ][tab],
      ),
    ),
    body: SafeArea(
      child: IndexedStack(
        index: tab,
        children: [
          _Dashboard(onNavigate: (n) => setState(() => tab = n)),
          const _BookingManager(),
          const _RoomManager(),
          const _ProfilePanel(),
        ],
      ),
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: tab,
      onDestinationSelected: (i) => setState(() => tab = i),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Beranda',
        ),
        NavigationDestination(
          icon: Icon(Icons.assignment_outlined),
          selectedIcon: Icon(Icons.assignment),
          label: 'Pengajuan',
        ),
        NavigationDestination(
          icon: Icon(Icons.meeting_room_outlined),
          selectedIcon: Icon(Icons.meeting_room),
          label: 'Ruangan',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    ),
  );
}

class _Dashboard extends StatelessWidget {
  final ValueChanged<int> onNavigate;
  const _Dashboard({required this.onNavigate});
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: uid == null
              ? null
              : FirebaseFirestore.instance
                    .collection('admins')
                    .doc(uid)
                    .snapshots(),
          builder: (context, snap) => GradientBanner(
            title: 'Halo, ${snap.data?.data()?['nama'] ?? 'Admin JPTK'} 👋',
            subtitle: 'Kelola peminjaman ruangan di sini.',
            icon: Icons.admin_panel_settings_rounded,
          ),
        ),
        const PageSectionTitle('Ringkasan Pengajuan'),
        StreamBuilder<List<Booking>>(
          stream: BookingService().watchAll(),
          builder: (context, snap) {
            if (snap.hasError)
              return Text('Gagal membaca pengajuan: ${snap.error}');
            if (!snap.hasData) return const LinearProgressIndicator();
            return Row(
              children: [
                _Counter(
                  title: 'Menunggu',
                  count: snap.data!.where((b) => b.status == 'pending').length,
                  color: Palette.warning,
                ),
                _Counter(
                  title: 'Disetujui',
                  count: snap.data!.where((b) => b.status == 'approved').length,
                  color: Palette.success,
                ),
                _Counter(
                  title: 'Ditolak',
                  count: snap.data!.where((b) => b.status == 'rejected').length,
                  color: Palette.danger,
                ),
              ],
            );
          },
        ),
        const PageSectionTitle('Menu Kelola'),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.assignment, color: Palette.primary),
                title: const Text('Pengajuan Peminjaman'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => onNavigate(1),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.meeting_room, color: Palette.primary),
                title: const Text('Manajemen Ruangan'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => onNavigate(2),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(
                  Icons.calendar_month,
                  color: Palette.primary,
                ),
                title: const Text('Jadwal Ruangan'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminBlockSchedulePage(),
                  ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.bar_chart, color: Palette.primary),
                title: const Text('Laporan'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminReportPage()),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Counter extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  const _Counter({
    required this.title,
    required this.count,
    required this.color,
  });
  @override
  Widget build(BuildContext context) => Expanded(
    child: Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 3),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 10, color: Palette.softInk),
            ),
          ],
        ),
      ),
    ),
  );
}

class _BookingManager extends StatefulWidget {
  const _BookingManager();
  @override
  State<_BookingManager> createState() => _BookingManagerState();
}

class _BookingManagerState extends State<_BookingManager> {
  String status = 'pending';
  @override
  Widget build(BuildContext context) => Column(
    children: [
      const Padding(
        padding: EdgeInsets.only(top: 12),
        child: Text(
          'Pengajuan Peminjaman',
          style: TextStyle(
            color: Palette.ink,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(9),
        child: Wrap(
          spacing: 6,
          children: [
            for (final s in ['pending', 'approved', 'rejected'])
              ChoiceChip(
                label: Text(Booking.statusLabel(s)),
                selected: status == s,
                onSelected: (_) => setState(() => status = s),
              ),
          ],
        ),
      ),
      Expanded(
        child: StreamBuilder<List<Booking>>(
          stream: BookingService().watchAll(),
          builder: (context, bs) {
            if (bs.hasError)
              return Center(
                child: Text('Gagal membaca pengajuan: ${bs.error}'),
              );
            if (!bs.hasData)
              return const Center(child: CircularProgressIndicator());
            return StreamBuilder<List<Room>>(
              stream: RoomService().watch(activeOnly: false),
              builder: (context, rs) {
                if (!rs.hasData)
                  return const Center(child: CircularProgressIndicator());
                final names = {for (final r in rs.data!) r.id: r.name};
                final list = bs.data!.where((b) => b.status == status).toList();
                if (list.isEmpty)
                  return const Center(
                    child: Text('Belum ada pengajuan pada status ini.'),
                  );
                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 13),
                  children: [
                    for (final b in list)
                      Card(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(17),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookingDetailPage(
                                booking: b,
                                roomName: names[b.roomId] ?? b.roomId,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        names[b.roomId] ?? b.roomId,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    StatusTag(status: b.status),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  stampLabel(b.startAt),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Palette.softInk,
                                  ),
                                ),
                                Text(
                                  '${b.purpose} • ${b.institution}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 5),
                                const Align(
                                  alignment: Alignment.centerRight,
                                  child: Icon(
                                    Icons.chevron_right,
                                    color: Palette.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    ],
  );
}

class _RoomManager extends StatelessWidget {
  const _RoomManager();
  @override
  Widget build(BuildContext context) => StreamBuilder<List<Room>>(
    stream: RoomService().watch(activeOnly: false),
    builder: (context, snap) {
      if (snap.hasError)
        return Center(child: Text('Gagal membaca ruangan: ${snap.error}'));
      if (!snap.hasData)
        return const Center(child: CircularProgressIndicator());
      return ListView(
        padding: const EdgeInsets.all(14),
        children: [
          const PageSectionTitle('Manajemen Ruangan'),
          for (final room in snap.data!)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            room.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '${room.building} • Lantai ${room.floor} • ${room.capacity} orang',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Palette.softInk,
                            ),
                          ),
                          Text(
                            room.active ? 'Aktif' : 'Nonaktif',
                            style: TextStyle(
                              fontSize: 11,
                              color: room.active
                                  ? Palette.success
                                  : Palette.danger,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Edit ruangan',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RoomEditorPage(room: room),
                        ),
                      ),
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Palette.primary,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Nonaktifkan ruangan',
                      onPressed: !room.active
                          ? null
                          : () => _confirmDeactivate(context, room),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Palette.danger,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          FilledButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Tambah Ruangan'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RoomEditorPage()),
            ),
          ),
        ],
      );
    },
  );
  Future<void> _confirmDeactivate(BuildContext context, Room room) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nonaktifkan ruangan?'),
        content: Text(
          '${room.name} tidak ditampilkan untuk peminjaman baru. Riwayat tetap tersimpan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Nonaktifkan'),
          ),
        ],
      ),
    );
    if (yes == true) {
      try {
        await RoomService().deactivate(room.id);
      } catch (e) {
        if (context.mounted) showSnack(context, 'Gagal: $e');
      }
    }
  }
}

class _ProfilePanel extends StatelessWidget {
  const _ProfilePanel();
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text('Admin belum login.'));
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('admins')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snap) {
        final name = snap.data?.data()?['nama']?.toString() ?? 'Admin JPTK';
        return ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 47,
              backgroundColor: Color(0xFFE8D8FA),
              child: Icon(
                Icons.workspace_premium,
                color: Palette.primary,
                size: 55,
              ),
            ),
            const SizedBox(height: 11),
            Center(
              child: Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            Center(
              child: Text(
                user.email ?? '',
                style: const TextStyle(color: Palette.softInk, fontSize: 12),
              ),
            ),
            const SizedBox(height: 23),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.edit_outlined,
                      color: Palette.primary,
                    ),
                    title: const Text('Ubah Profil'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _rename(context, name),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.lock_outline,
                      color: Palette.primary,
                    ),
                    title: const Text('Ganti Password'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _reset(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Palette.danger),
                    title: const Text(
                      'Keluar',
                      style: TextStyle(color: Palette.danger),
                    ),
                    onTap: () => AuthService().logout(),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _rename(BuildContext context, String name) async {
    final ctrl = TextEditingController(text: name);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Nama Admin'),
        content: TextField(controller: ctrl, maxLength: 80),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (result == null || result.isEmpty) return;
    try {
      await AuthService().updateName(result);
    } catch (e) {
      if (context.mounted) showSnack(context, 'Gagal mengubah profil: $e');
    }
  }

  Future<void> _reset(BuildContext context) async {
    try {
      await AuthService().resetPassword();
      if (context.mounted)
        showSnack(
          context,
          'Email pengaturan ulang kata sandi sudah diminta. Periksa inbox.',
        );
    } catch (e) {
      if (context.mounted) showSnack(context, 'Gagal: $e');
    }
  }
}

class AdminBlockSchedulePage extends StatefulWidget {
  const AdminBlockSchedulePage({super.key});
  @override
  State<AdminBlockSchedulePage> createState() => _AdminBlockSchedulePageState();
}

class _AdminBlockSchedulePageState extends State<AdminBlockSchedulePage> {
  String? roomId;
  DateTime date = todayWib();
  TimeSlot slot = bookingSlots.first;
  bool busy = false;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Jadwal Ruangan')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const PageSectionTitle('Blokir Slot Ruangan'),
        const Text(
          'Gunakan untuk kegiatan internal atau perawatan. Slot yang diblokir tidak bisa diajukan tamu.',
          style: TextStyle(color: Palette.softInk, fontSize: 12),
        ),
        const SizedBox(height: 15),
        StreamBuilder<List<Room>>(
          stream: RoomService().watch(),
          builder: (context, snap) {
            if (!snap.hasData) return const LinearProgressIndicator();
            final selected = snap.data!.any((r) => r.id == roomId)
                ? roomId
                : null;
            return DropdownButtonFormField<String>(
              initialValue: selected,
              decoration: const InputDecoration(labelText: 'Pilih ruangan'),
              items: snap.data!
                  .map(
                    (r) => DropdownMenuItem(value: r.id, child: Text(r.name)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => roomId = v),
            );
          },
        ),
        const SizedBox(height: 13),
        OutlinedButton.icon(
          icon: const Icon(Icons.calendar_month),
          label: Text(dateLong(date)),
          onPressed: () async {
            final d = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: todayWib(),
              lastDate: todayWib().add(const Duration(days: 365)),
            );
            if (d != null) setState(() => date = d);
          },
        ),
        const SizedBox(height: 13),
        DropdownButtonFormField<int>(
          initialValue: slot.startHour,
          decoration: const InputDecoration(labelText: 'Slot waktu'),
          items: bookingSlots
              .map(
                (s) =>
                    DropdownMenuItem(value: s.startHour, child: Text(s.label)),
              )
              .toList(),
          onChanged: (h) => setState(
            () => slot = bookingSlots.firstWhere((s) => s.startHour == h),
          ),
        ),
        const SizedBox(height: 17),
        FilledButton.icon(
          icon: const Icon(Icons.lock_clock),
          label: Text(busy ? 'Menyimpan...' : 'Blokir Slot'),
          onPressed: busy
              ? null
              : () async {
                  if (roomId == null) {
                    showSnack(context, 'Pilih ruangan dahulu.');
                    return;
                  }
                  setState(() => busy = true);
                  try {
                    await ScheduleService().blockSlot(roomId!, date, slot);
                    if (context.mounted)
                      showSnack(context, 'Slot berhasil diblokir.');
                  } catch (e) {
                    if (context.mounted) showSnack(context, 'Gagal: $e');
                  } finally {
                    if (mounted) setState(() => busy = false);
                  }
                },
        ),
      ],
    ),
  );
}

class AdminReportPage extends StatelessWidget {
  const AdminReportPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Laporan Pengajuan')),
    body: StreamBuilder<List<Booking>>(
      stream: BookingService().watchAll(),
      builder: (context, snap) {
        if (snap.hasError) return Center(child: Text('Gagal: ${snap.error}'));
        if (!snap.hasData)
          return const Center(child: CircularProgressIndicator());
        final items = snap.data!;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const PageSectionTitle('Ringkasan Semua Pengajuan'),
            _RowReport('Total Pengajuan', items.length),
            _RowReport(
              'Menunggu',
              items.where((e) => e.status == 'pending').length,
            ),
            _RowReport(
              'Disetujui',
              items.where((e) => e.status == 'approved').length,
            ),
            _RowReport(
              'Ditolak',
              items.where((e) => e.status == 'rejected').length,
            ),
            const SizedBox(height: 14),
            const Text(
              'Ringkasan ini ditampilkan di aplikasi; ekspor laporan dapat dikembangkan berikutnya.',
              style: TextStyle(fontSize: 12, color: Palette.softInk),
            ),
          ],
        );
      },
    ),
  );
}

class _RowReport extends StatelessWidget {
  final String title;
  final int count;
  const _RowReport(this.title, this.count);
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      title: Text(title),
      trailing: Text(
        '$count',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Palette.primary,
        ),
      ),
    ),
  );
}
