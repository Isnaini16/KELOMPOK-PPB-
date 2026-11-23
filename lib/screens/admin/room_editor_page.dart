import 'package:flutter/material.dart';

import '../../core/ui_widgets.dart';
import '../../models/room.dart';
import '../../services/room_service.dart';

class RoomEditorPage extends StatefulWidget {
  final Room? room;
  const RoomEditorPage({super.key, this.room});
  @override
  State<RoomEditorPage> createState() => _RoomEditorPageState();
}

class _RoomEditorPageState extends State<RoomEditorPage> {
  final formKey = GlobalKey<FormState>();
  late final List<TextEditingController> controllers;
  late String type;
  late bool active;
  bool busy = false;
  @override
  void initState() {
    super.initState();
    final r = widget.room;
    controllers = [
      r?.name ?? '',
      r?.building ?? '',
      '${r?.floor ?? 1}',
      '${r?.capacity ?? 30}',
      r?.facilities.join(', ') ?? '',
      r?.imageUrl ?? '',
    ].map((s) => TextEditingController(text: s)).toList();
    type = r?.type ?? 'kelas';
    active = r?.active ?? true;
  }

  @override
  void dispose() {
    for (final c in controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate() || busy) return;
    setState(() => busy = true);
    try {
      await RoomService().save(
        Room(
          id: widget.room?.id ?? '',
          name: controllers[0].text.trim(),
          type: type,
          building: controllers[1].text.trim(),
          floor: int.parse(controllers[2].text),
          capacity: int.parse(controllers[3].text),
          facilities: controllers[4].text
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList(),
          imageUrl: controllers[5].text.trim(),
          active: active,
          revision: widget.room?.revision ?? 0,
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) showSnack(context, 'Gagal menyimpan ruangan: $e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.room == null ? 'Tambah Ruangan' : 'Edit Ruangan'),
    ),
    body: Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const PageSectionTitle('Informasi Ruangan'),
          for (var i = 0; i < controllers.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 13),
              child: TextFormField(
                controller: controllers[i],
                maxLength: i == 5 ? 1000 : 200,
                keyboardType: (i == 2 || i == 3)
                    ? TextInputType.number
                    : TextInputType.text,
                decoration: InputDecoration(
                  labelText: [
                    'Nama Ruangan',
                    'Gedung',
                    'Lantai',
                    'Kapasitas',
                    'Fasilitas (pisahkan koma)',
                    'URL Foto (opsional)',
                  ][i],
                  counterText: '',
                ),
                validator: (s) {
                  final v = (s ?? '').trim();
                  if (i < 4 && v.isEmpty) return 'Wajib diisi';
                  if ((i == 2 || i == 3) && (int.tryParse(v) ?? 0) < 1)
                    return 'Masukkan angka positif';
                  return null;
                },
              ),
            ),
          DropdownButtonFormField<String>(
            initialValue: type,
            decoration: const InputDecoration(labelText: 'Kategori'),
            items: [
              'kelas',
              'seminar',
              'sidang',
              'aula',
            ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (s) => setState(() => type = s ?? 'kelas'),
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            value: active,
            onChanged: (v) => setState(() => active = v),
            title: const Text('Ruangan aktif'),
            subtitle: const Text('Nonaktifkan untuk menutup peminjaman baru.'),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: busy ? null : save,
            icon: const Icon(Icons.save_outlined),
            label: Text(busy ? 'Menyimpan...' : 'Simpan Ruangan'),
          ),
        ],
      ),
    ),
  );
}
