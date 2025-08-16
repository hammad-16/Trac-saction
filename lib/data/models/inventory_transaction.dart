import 'package:uuid/uuid.dart';

class InventoryTransaction {
  int? id;
  final String firebaseId;
  int itemId;
  double quantity;
  String type;
  int? relatedTransactionId;
  String? notes;
  DateTime date;
  DateTime createdAt;
  final String status;

  InventoryTransaction({
    this.id,
    required this.itemId,
    required this.quantity,
    required this.type,
    this.relatedTransactionId,
    this.notes,
    required this.date,
    required this.createdAt,
    String? firebaseId,
    this.status = 'synced'

  }): this.firebaseId = firebaseId ?? Uuid().v4();

  InventoryTransaction copyWith({
    int? id,
    String? firebaseId,
    int? itemId,
    double? quantity,
    String? type,
    int? relatedTransactionId,
    String? notes,
    String? date,
    String? createdAt,
    String? status,
  }) {
    return InventoryTransaction(
      id: id ?? this.id,
      firebaseId: firebaseId ?? this.firebaseId,
      itemId: itemId ?? this.itemId,
      quantity: quantity ?? this.quantity,
      type: type ?? this.type,
      relatedTransactionId: relatedTransactionId ?? this.relatedTransactionId,
      notes: notes ?? this.notes,
      date: this.date,
      createdAt: this.createdAt,
      status: status ?? this.status,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemId': itemId,
      'quantity': quantity,
      'type': type,
      'relatedTransactionId': relatedTransactionId,
      'notes': notes,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'status': status,
    };
  }

  factory InventoryTransaction.fromMap(Map<String, dynamic> map) {
    return InventoryTransaction(
      id: map['id'],
      itemId: map['itemId'],
      quantity: map['quantity'].toDouble(),
      type: map['type'],
      relatedTransactionId: map['relatedTransactionId'],
      notes: map['notes'],
      date: DateTime.parse(map['date']),
      createdAt: DateTime.parse(map['createdAt']),
      status: map['status'] ?? 'synced',
    );
  }
}
