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
  });

  factory Room.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return Room(
      id: doc.id,
      name: data['room_name'] as String,
      type: data['room_type'] as String,
      building: data['building'] as String,
      floor: (data['floor'] as num).toInt(),
      capacity: (data['capacity'] as num).toInt(),
      facilities: List<String>.from(data['facilities'] as List),
      imageUrl: data['image_url'] as String,
      active: data['is_active'] == true,
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