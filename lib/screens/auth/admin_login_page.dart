
import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../core/ui_widgets.dart';
import '../../services/auth_service.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});
  @override State<AdminLoginPage> createState() => _AdminLoginPageState();
}
class _AdminLoginPageState extends State<AdminLoginPage> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;
  bool hide = true;

  @override void dispose() { email.dispose(); password.dispose(); super.dispose(); }

  Future<void> login() async {
    if (!form.currentState!.validate() || loading) return;
    setState(() => loading = true);
    try {
      await AuthService().login(email.text, password.text);
      // AdminGate otomatis membuka dashboard ketika autentikasi berhasil.
    } catch (e) {
      if (mounted) showSnack(context, 'Login gagal: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Login Admin')),
    body: Center(child: SingleChildScrollView(child: Padding(
      padding: const EdgeInsets.all(22), child: Form(key: form, child: Column(children: [
        Container(padding: const EdgeInsets.all(22), decoration: const BoxDecoration(
          color: Color(0xFFEEE2FA), shape: BoxShape.circle),
          child: const Icon(Icons.apartment_rounded, size: 78, color: Palette.primary)),
        const SizedBox(height: 18),
        const Text('SIPIRANG JPTK', style: TextStyle(color: Palette.primaryDark, fontWeight: FontWeight.w800, fontSize: 26)),
        const Text('Sistem Pinjam Ruang JPTK', style: TextStyle(color: Palette.softInk, fontSize: 12)),
        const SizedBox(height: 26),
        const Align(alignment: Alignment.centerLeft, child: Text('Login Admin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
        const SizedBox(height: 5),
        const Align(alignment: Alignment.centerLeft, child: Text('Kelola data ruangan dan peminjaman.', style: TextStyle(fontSize: 12, color: Palette.softInk))),
        const SizedBox(height: 14),
        TextFormField(controller: email, keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.mail_outline), labelText: 'Email Admin'),
          validator: (v) => (v ?? '').contains('@') ? null : 'Email tidak valid'),
        const SizedBox(height: 12),
        TextFormField(controller: password, obscureText: hide,
          decoration: InputDecoration(prefixIcon: const Icon(Icons.lock_outline), labelText: 'Password',
            suffixIcon: IconButton(onPressed: () => setState(() => hide = !hide),
              icon: Icon(hide ? Icons.visibility_off : Icons.visibility))),
          validator: (v) => (v ?? '').isEmpty ? 'Password wajib diisi' : null),
        const SizedBox(height: 18),
        SizedBox(width: double.infinity, child: FilledButton(
          onPressed: loading ? null : login,
          child: Text(loading ? 'Memeriksa...' : 'Masuk'))),
      ])),
    ))),
  );
}
