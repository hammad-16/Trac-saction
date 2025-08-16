import 'package:uuid/uuid.dart';

class Item{
  int? id;
  final String firebaseId;
  String name;
  String? imagePath;
  String primaryUnit;
  String? secondaryUnit;
  double? conversionRate;
  double salePrice;
  double? purchasePrice;
  bool taxIncluded;
  double? openingStock;
  double? lowStockAlert;
  DateTime asOfDate;
  String? hsnCode;
  double? gstRate;
  DateTime createdAt;
  final String status;
  Item({
   this.id,
    String?firebaseId,
   required this.name,
    this.imagePath,
    required this.primaryUnit,
    this.secondaryUnit,
    this.conversionRate,
    required this.salePrice,
    this.purchasePrice,
    required this.taxIncluded,
    this.openingStock,
    this.lowStockAlert,
    required this.asOfDate,
    this.hsnCode,
    this.gstRate,
    required this.createdAt,
    this.status = 'synced'
}): this.firebaseId = firebaseId ?? Uuid().v4();

  Item copyWith({
    int? id,
    String? firebaseId,
    String? name,
    String? imagePath,
    String? primaryUnit,
    String? secondaryUnit,
    double? conversionRate,
    double? salePrice,
    double? purchasePrice,
    int? taxIncluded,
    double? openingStock,
    double? lowStockAlert,
    String? asOfDate,
    String? hsnCode,
    double? gstRate,
    String? createdAt,
    String? status,
  }) {
    return Item(
      id: id ?? this.id,
      firebaseId: firebaseId ?? this.firebaseId,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      primaryUnit: primaryUnit ?? this.primaryUnit,
      secondaryUnit: secondaryUnit ?? this.secondaryUnit,
      conversionRate: conversionRate ?? this.conversionRate,
      salePrice: salePrice ?? this.salePrice,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      taxIncluded: this.taxIncluded,
      openingStock: openingStock ?? this.openingStock,
      lowStockAlert: lowStockAlert ?? this.lowStockAlert,
      asOfDate: this.asOfDate,
      hsnCode: hsnCode ?? this.hsnCode,
      gstRate: gstRate ?? this.gstRate,
      createdAt: this.createdAt,
      status: status ?? this.status,
    );
  }
Map<String, dynamic> toMap() {
  return {
    'id': id,
    'firebaseId': firebaseId,
    'name': name,
    'imagePath': imagePath,
    'primaryUnit': primaryUnit,
    'secondaryUnit': secondaryUnit,
    'conversionRate': conversionRate,
    'salePrice': salePrice,
    'purchasePrice': purchasePrice,
    'taxIncluded': taxIncluded ? 1 : 0,
    'openingStock': openingStock,
    'lowStockAlert': lowStockAlert,
    'asOfDate': asOfDate.toIso8601String(),
    'hsnCode': hsnCode,
    'gstRate': gstRate,
    'createdAt': createdAt.toIso8601String(),
    'status': status,
  };
}

factory Item.fromMap(Map<String, dynamic> map) {
return Item(
id: map['id'],
firebaseId: map['firebaseId'],
name: map['name'],
imagePath: map['imagePath'],
primaryUnit: map['primaryUnit'],
secondaryUnit: map['secondaryUnit'],
conversionRate: map['conversionRate']?.toDouble(),
salePrice: map['salePrice'].toDouble(),
purchasePrice: map['purchasePrice']?.toDouble(),
taxIncluded: map['taxIncluded'] == 1,
openingStock: map['openingStock']?.toDouble(),
lowStockAlert: map['lowStockAlert']?.toDouble(),
asOfDate: DateTime.parse(map['asOfDate']),
hsnCode: map['hsnCode'],
gstRate: map['gstRate']?.toDouble(),
createdAt: DateTime.parse(map['createdAt']),
  status: map['status'] ?? 'synced',
);
}
}

