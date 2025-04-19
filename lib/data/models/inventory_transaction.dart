class InventoryTransaction {
  int? id;
  int itemId;
  double quantity;
  String type;
  int? relatedTransactionId;
  String? notes;
  DateTime date;
  DateTime createdAt;

  InventoryTransaction({
    this.id,
    required this.itemId,
    required this.quantity,
    required this.type,
    this.relatedTransactionId,
    this.notes,
    required this.date,
    required this.createdAt,
  });

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
    );
  }
}
