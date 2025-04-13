class Contact {
  int? id;
  String name;
  String? phone;
  String type; // 'customer' or 'supplier'
  String? notes;
  DateTime createdAt;

  Contact({
    this.id,
    required this.name,
    this.phone,
    required this.type,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'type': type,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      type: map['type'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}