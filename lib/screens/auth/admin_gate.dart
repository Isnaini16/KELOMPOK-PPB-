
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/app_theme.dart';
import '../../services/auth_service.dart';
import '../admin/admin_shell.dart';
import 'admin_login_page.dart';

class AdminGate extends StatefulWidget {
  const AdminGate({super.key});
  @override State<AdminGate> createState() => _AdminGateState();
}
class _AdminGateState extends State<AdminGate> {
  final service = AuthService();
  @override Widget build(BuildContext context) => StreamBuilder<User?>(
    stream: service.users,
    builder: (context, auth) {
      if (!auth.hasData) return const AdminLoginPage();
      return FutureBuilder<bool>(
        future: service.isCurrentUserAdmin(),
        builder: (context, check) {
          if (check.hasError) return Scaffold(appBar: AppBar(title: const Text('Akses Admin')),
            body: Center(child: Text('Gagal memeriksa akun: ${check.error}')));
          if (!check.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
          if (check.data == true) return const AdminShell();
          return Scaffold(appBar: AppBar(title: const Text('Akses Ditolak')),
            body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.lock_outline, size: 54, color: Palette.danger),
              const SizedBox(height: 12),
              const Text('Akun ini bukan admin aktif.'),
              TextButton(onPressed: service.logout, child: const Text('Keluar')),
            ])));
        },
      );
    },
  );
}
