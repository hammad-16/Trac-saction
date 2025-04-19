class Item{
  int? id;
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

  Item({
   this.id,
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
    required this.createdAt
});

Map<String, dynamic> toMap() {
  return {
    'id': id,
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
  };
}

factory Item.fromMap(Map<String, dynamic> map) {
return Item(
id: map['id'],
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
);
}
}

