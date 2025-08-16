import 'package:uuid/uuid.dart';

class Contact {
  int? id;
  final String firebaseId;
  String name;
  String? phone;
  String type; // 'customer' or 'supplier'
  String? notes;
  DateTime createdAt;
  final String status;

  Contact({
    this.id,
    required this.name,
    this.phone,
    required this.type,
    this.notes,
    required this.createdAt,
     String? firebaseId,
      this.status = 'synced'
  }) : this.firebaseId = firebaseId ?? Uuid().v4();

  // Add this method
  Contact copyWith({
    int? id,
    String? firebaseId,
    String? name,
    String? phone,
    String? type,
    String? notes,
    String? createdAt,
    String? status,
  }) {
    return Contact(
      id: id ?? this.id,
      firebaseId: firebaseId ?? this.firebaseId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      type: type ?? this.type,
      notes: notes ?? this.notes,
      createdAt: this.createdAt,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firebaseId': firebaseId,
      'name': name,
      'phone': phone,
      'type': type,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'status': status,
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'],
      firebaseId: map['firebaseId'],
      name: map['name'],
      phone: map['phone'],
      type: map['type'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
      status: map['status'] ?? 'synced',
    );
  }
}