import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Tetap gunakan file asli hasil flutterfire configure!
import 'core/app_theme.dart';
import 'screens/guest/guest_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const SipirangApp());
}

class SipirangApp extends StatelessWidget {
  const SipirangApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'SIPIRANG JPTK',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    home: const GuestShell(),
  );
}
