import 'package:flutter/material.dart';

void main() => runApp(const RuangKitaApp());

class RuangKitaApp extends StatelessWidget {
  const RuangKitaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RuangKita JPTK',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFAA87DC)),
        scaffoldBackgroundColor: const Color(0xFFFBF8FF),
      ),
      home: const HalamanUtama(),
    );
  }
}

class HalamanUtama extends StatefulWidget {
  const HalamanUtama({super.key});

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  int halaman = 0;
  static const ungu = Color(0xFF7957A7);
  static const gelap = Color(0xFF403258);

  void info(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesan),
        behavior: SnackBarBehavior.floating,
        backgroundColor: ungu,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBF8FF),
        title: const Row(
          children: [
            Icon(Icons.meeting_room_rounded, color: ungu),
            SizedBox(width: 8),
            Text('RuangKita JPTK',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Tentang aplikasi',
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => info('Prototipe awal UAS Flutter - Minggu 1'),
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: halaman,
          children: [
            beranda(),
            halamanRencana(Icons.calendar_month_rounded, 'Jadwal Ruangan',
                'Kalender ketersediaan akan dibuat pada Minggu 2.'),
            halamanRencana(Icons.history_rounded, 'Riwayat Peminjaman',
                'Riwayat akan ditampilkan setelah integrasi Firestore.'),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: halaman,
        onDestinationSelected: (index) => setState(() => halaman = index),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFEBDDFF),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Beranda'),
          NavigationDestination(
              icon: Icon(Icons.calendar_month_rounded), label: 'Jadwal'),
          NavigationDestination(
              icon: Icon(Icons.history_rounded), label: 'Riwayat'),
        ],
      ),
    );
  }

  Widget beranda() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFDAC4FF), Color(0xFFB99BEF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Chip(
                label: Text('PROTOTIPE MINGGU 1',
                    style: TextStyle(color: ungu, fontSize: 11)),
                backgroundColor: Color(0xFFF7EEFF),
                side: BorderSide.none,
              ),
              SizedBox(height: 12),
              Icon(Icons.event_available_rounded, size: 42, color: gelap),
              SizedBox(height: 12),
              Text('Butuh ruangan\nuntuk kegiatanmu?',
                  style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      color: gelap)),
              SizedBox(height: 10),
              Text('Jelajahi Ruang Sidang dan Aula JPTK FKIP UNS\n'
                  'dengan lebih mudah.',
                  style: TextStyle(fontSize: 14, height: 1.5, color: gelap)),
            ],
          ),
        ),
        const SizedBox(height: 26),
        const Text('Pilihan Ruangan',
            style: TextStyle(
                fontSize: 21, fontWeight: FontWeight.bold, color: gelap)),
        const SizedBox(height: 5),
        const Text('Kenali ruangan yang akan tersedia di aplikasi.',
            style: TextStyle(color: Color(0xFF82768F))),
        const SizedBox(height: 16),
        kartuRuang('Ruang Sidang', 'Untuk rapat dan kegiatan akademik.',
            Icons.groups_rounded),
        const SizedBox(height: 14),
        kartuRuang('Aula JPTK', 'Untuk pertemuan dan kegiatan bersama.',
            Icons.apartment_rounded),
        const SizedBox(height: 18),
        const Card(
          color: Color(0xFFF1E8FF),
          elevation: 0,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline_rounded, color: ungu),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Fitur berikutnya: cek jadwal, ajukan peminjaman, '
                    'dan pantau status persetujuan.',
                    style: TextStyle(color: gelap, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget kartuRuang(String nama, String deskripsi, IconData ikon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE6D7F7)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0E5FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(ikon, size: 30, color: ungu),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nama,
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: gelap)),
                    const SizedBox(height: 4),
                    const Text('JPTK FKIP UNS',
                        style: TextStyle(color: Color(0xFF82768F))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(deskripsi,
                style: const TextStyle(color: Color(0xFF756982))),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => info('Form peminjaman $nama dibuat pada Minggu 2.'),
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Ajukan Peminjaman'),
              style: OutlinedButton.styleFrom(
                foregroundColor: ungu,
                side: const BorderSide(color: Color(0xFFD7C2F0)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget halamanRencana(IconData ikon, String judul, String deskripsi) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFECDDFF),
              radius: 42,
              child: Icon(ikon, size: 40, color: ungu),
            ),
            const SizedBox(height: 16),
            Text(judul,
                style: const TextStyle(
                    fontSize: 21, fontWeight: FontWeight.bold, color: gelap)),
            const SizedBox(height: 8),
            Text(deskripsi,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF82768F))),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => setState(() => halaman = 0),
              child: const Text('Kembali ke Beranda'),
            ),
          ],
        ),
      ),
    );
  }
}
