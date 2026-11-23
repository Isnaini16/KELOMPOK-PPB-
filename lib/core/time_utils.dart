import 'package:cloud_firestore/cloud_firestore.dart';

// Semua jam yang dimasukkan oleh pengguna dianggap WIB (UTC+7).
DateTime wibToUtc(DateTime day, int hour, int minute) =>
    DateTime.utc(day.year, day.month, day.day, hour, minute).subtract(const Duration(hours: 7));
DateTime toWib(DateTime utc) => utc.toUtc().add(const Duration(hours: 7));
DateTime todayWib() {
  final d = toWib(DateTime.now());
  return DateTime(d.year, d.month, d.day);
}
String two(int value) => value.toString().padLeft(2, '0');
String dateLabel(DateTime day) => '${two(day.day)}/${two(day.month)}/${day.year}';
String dateLong(DateTime day) {
  const months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
  return '${day.day} ${months[day.month - 1]} ${day.year}';
}
String timeLabel(int hour) => '${two(hour)}.00';
String stampLabel(Timestamp t) {
  final d = toWib(t.toDate());
  return '${dateLong(d)}, ${two(d.hour)}.${two(d.minute)} WIB';
}
bool overlaps(DateTime aStart, DateTime aEnd, DateTime bStart, DateTime bEnd) =>
    aStart.isBefore(bEnd) && bStart.isBefore(aEnd);

class TimeSlot {
  final int startHour;
  final int endHour;
  const TimeSlot(this.startHour, this.endHour);
  String get label => '${timeLabel(startHour)} – ${timeLabel(endHour)}';
  DateTime startUtc(DateTime day) => wibToUtc(day, startHour, 0);
  DateTime endUtc(DateTime day) => wibToUtc(day, endHour, 0);
}

// Bisa diganti apabila jam operasional JPTK berbeda.
const bookingSlots = [
  TimeSlot(7, 9), TimeSlot(9, 11), TimeSlot(11, 13),
  TimeSlot(13, 15), TimeSlot(15, 17),
];
