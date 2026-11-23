import 'package:cloud_firestore/cloud_firestore.dart';

class Room {
  final String id;
  final String name;
  final String type;
  final String building;
  final int floor;
  final int capacity;
  final List<String> facilities;
  final String imageUrl;
  final bool active;
  final int revision;

  const Room({
    required this.id,
    required this.name,
    required this.type,
    required this.building,
    required this.floor,
    required this.capacity,
    required this.facilities,
    required this.imageUrl,
    required this.active,
    this.revision = 0,
  });

  factory Room.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Room(
      id: doc.id,
      name: d['room_name']?.toString() ?? doc.id,
      type: d['room_type']?.toString() ?? 'kelas',
      building: d['building']?.toString() ?? 'Gedung JPTK',
      floor: (d['floor'] as num?)?.toInt() ?? 1,
      capacity: (d['capacity'] as num?)?.toInt() ?? 0,
      facilities:
          (d['facilities'] as List?)?.map((x) => x.toString()).toList() ?? [],
      imageUrl: d['image_url']?.toString() ?? '',
      active: d['is_active'] == true,
      revision: (d['schedule_revision'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'room_id': id,
    'room_name': name,
    'room_type': type,
    'building': building,
    'floor': floor,
    'capacity': capacity,
    'facilities': facilities,
    'image_url': imageUrl,
    'is_active': active,
  };
}
