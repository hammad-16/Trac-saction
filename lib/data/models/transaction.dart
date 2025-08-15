import 'package:uuid/uuid.dart';

class AppTransaction {
  int? id;
  final String firebaseId;
  int contactId;
  double amount;
  String type; // 'credit' or 'debit'
  String? description;
  DateTime date;
  DateTime createdAt;

  AppTransaction({
    this.id,
    String? firebaseId,
    required this.contactId,
    required this.amount,
    required this.type,
    this.description,
    required this.date,
    required this.createdAt,
  }): this.firebaseId = firebaseId ?? Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firebaseId': firebaseId,
      'contact_id': contactId,
      'amount': amount,
      'type': type,
      'description': description,
      'date': date.toIso8601String().substring(0, 10), // YYYY-MM-DD
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory AppTransaction.fromMap(Map<String, dynamic> map) {
    return AppTransaction(
      id: map['id'],
      firebaseId: map['firebaseId'],
      contactId: map['contact_id'],
      amount: map['amount'],
      type: map['type'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}