import 'package:flutter/material.dart';

import '../models/room.dart';
import '../models/booking.dart';
import 'app_theme.dart';

class GradientBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  const GradientBanner({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.apartment_rounded,
  });
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFBC98F0), Color(0xFF7952C3)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Row(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: .87), size: 45),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class RoomPhoto extends StatelessWidget {
  final Room room;
  final double height;
  const RoomPhoto({super.key, required this.room, this.height = 88});
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: SizedBox(
      height: height,
      width: double.infinity,
      child: room.imageUrl.isEmpty
          ? Container(
              color: const Color(0xFFE7DAF7),
              child: const Icon(
                Icons.meeting_room_rounded,
                size: 46,
                color: Palette.primary,
              ),
            )
          : Image.network(
              room.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFE7DAF7),
                child: const Icon(
                  Icons.meeting_room_rounded,
                  size: 46,
                  color: Palette.primary,
                ),
              ),
            ),
    ),
  );
}

class RoomTile extends StatelessWidget {
  final Room room;
  final VoidCallback onTap;
  const RoomTile({super.key, required this.room, required this.onTap});
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 11),
    child: InkWell(
      borderRadius: BorderRadius.circular(17),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(9),
        child: Row(
          children: [
            SizedBox(width: 100, child: RoomPhoto(room: room, height: 76)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.name,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Palette.ink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${room.building} • Lantai ${room.floor}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Palette.softInk,
                    ),
                  ),
                  Text(
                    'Kapasitas: ${room.capacity} orang',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Palette.softInk,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Palette.primary),
          ],
        ),
      ),
    ),
  );
}

class StatusTag extends StatelessWidget {
  final String status;
  const StatusTag({super.key, required this.status});
  @override
  Widget build(BuildContext context) {
    final Color fg;
    final Color bg;
    switch (status) {
      case 'approved':
        fg = Palette.success;
        bg = const Color(0xFFE1F6E7);
        break;
      case 'rejected':
        fg = Palette.danger;
        bg = const Color(0xFFFBE2E7);
        break;
      default:
        fg = Palette.warning;
        bg = const Color(0xFFFFF0C7);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        Booking.statusLabel(status),
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class PageSectionTitle extends StatelessWidget {
  final String title;
  const PageSectionTitle(this.title, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10, top: 12),
    child: Text(
      title,
      style: const TextStyle(
        color: Palette.ink,
        fontWeight: FontWeight.w800,
        fontSize: 16,
      ),
    ),
  );
}

void showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
