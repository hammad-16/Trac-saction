import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:khatabook/data/models/transaction.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/contact.dart';
import '../models/inventory_transaction.dart';
import '../models/item.dart';
import 'package:khatabook/data/database/firestore_helper.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  final FirebaseHelper _firebaseHelper = FirebaseHelper();


  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'khatabook.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    // Contacts table (for both customers and suppliers)
    await db.execute('''
      CREATE TABLE contacts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firebaseId TEXT NOT NULL,
        name TEXT NOT NULL,
        phone TEXT,
        type TEXT NOT NULL,    -- 'customer' or 'supplier'
        notes TEXT,
        created_at TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''');

    // This is the Transactions table
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firebaseId TEXT NOT NULL,
        contact_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,    -- 'credit' (you'll get) or 'debit' (you'll give)
        description TEXT,
        date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        status TEXT NOT NULL,
        FOREIGN KEY (contact_id) REFERENCES contacts (id) ON DELETE CASCADE
      )
    ''');
    //This is  item table creation
    await db.execute('''
  CREATE TABLE items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    firebaseId TEXT NOT NULL,
    name TEXT NOT NULL,
    imagePath TEXT,
    primaryUnit TEXT NOT NULL,
    secondaryUnit TEXT,
    conversionRate REAL,
    salePrice REAL NOT NULL,
    purchasePrice REAL,
    taxIncluded INTEGER NOT NULL,
    openingStock REAL,
    lowStockAlert REAL,
    asOfDate TEXT NOT NULL,
    hsnCode TEXT,
    gstRate REAL,
    createdAt TEXT NOT NULL,
    status TEXT NOT NULL
  )
''');

    await db.execute('''
  CREATE TABLE InventoryTransaction (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    itemId INTEGER NOT NULL,
    quantity REAL NOT NULL,
    type TEXT NOT NULL,
    relatedTransactionId INTEGER,
    notes TEXT,
    date TEXT NOT NULL,
    createdAt TEXT NOT NULL,
    status TEXT NOT NULL,
    FOREIGN KEY (itemId) REFERENCES items(id) ON DELETE CASCADE
  )
''');

  }
  Future<int> insertContact(Contact contact) async {
    final db = await database;
    final pendingContact = contact.copyWith(status: 'pending');
    final localId = await db.insert('contacts', pendingContact.toMap());
    final connection = await Connectivity().checkConnectivity();

      if(connection.contains(ConnectivityResult.mobile) || connection.contains(ConnectivityResult.wifi)){
        try {
          await _firebaseHelper.addContact(pendingContact);
          final syncedContact = pendingContact.copyWith(status: 'synced');
          await db.update('contacts', syncedContact.toMap(), where: 'id = ?',
              whereArgs: [localId]);
        }
        catch(e){
          print("Failed to sync contact to Firestore. Status remains 'pending'.");
        }
      }
      else{
        print("Device is offline. Contact will be synced later");
      }

      return localId;

  }

  Future<Contact?> getContact(int id) async {
    final db = await database;
    final maps = await db.query(
      'contacts',
      where: 'id = ? AND status != ?',
      whereArgs: [id, 'deleted'],
    );
    if (maps.isNotEmpty) {
      return Contact.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Contact>> getContacts(String type) async {
    final db = await database;
    final maps = await db.query(
      'contacts',
      where: 'type = ? AND status != ?',
      whereArgs: [type, 'deleted'],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Contact.fromMap(maps[i]));
  }
  Future<List<Contact>> searchContacts(String query, String type) async{
    final db = await database;
    final maps = await db.query(
      'contacts',
      where: 'name LIKE ? AND type = ? AND status != ?',
      whereArgs: ['%$query%', type, 'deleted'],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (it) => Contact.fromMap(maps[it]));
  }

  Future<int> updateContact(Contact contact) async {
    final db = await database;
    final pendingContact = contact.copyWith(status: 'pending');
    final rowsAffected = await db.update('contacts', pendingContact.toMap(), where: 'id = ?', whereArgs: [contact.id]);

    final connection = await Connectivity().checkConnectivity();
    if (connection.contains(ConnectivityResult.mobile) || connection.contains(ConnectivityResult.wifi)) {
      try {
        await _firebaseHelper.updateContact(pendingContact);
        final syncedContact = pendingContact.copyWith(status: 'synced');
        await db.update('contacts', syncedContact.toMap(), where: 'id = ?', whereArgs: [contact.id]);
      } catch (e) {
        print("Failed to sync contact to Firestore: $e");
      }
    } else {
      print("Device is offline. Contact will be synced later.");
    }
    return rowsAffected;
  }

  Future<int> deleteContact(int id) async {
    final db = await database;
    final contactMap = await db.query('contacts', where: 'id = ?', whereArgs: [id]);
    final contact = contactMap.isNotEmpty ? Contact.fromMap(contactMap.first) : null;

    if (contact != null) {
      final deletedContact = contact.copyWith(status: 'deleted');
      final rowsAffected = await db.update('contacts', deletedContact.toMap(), where: 'id = ?', whereArgs: [id]);

      final connection = await Connectivity().checkConnectivity();
      if (connection.contains(ConnectivityResult.mobile) || connection.contains(ConnectivityResult.wifi)) {
        try {
          await _firebaseHelper.deleteContact(deletedContact.firebaseId);
          // Permanently delete local record after successful cloud sync
          await db.delete('contacts', where: 'id = ?', whereArgs: [id]);
        } catch (e) {
          print("Failed to sync contact deletion to Firestore. Status remains 'deleted'.");
        }
      } else {
        print("Device is offline. Contact deletion will be synced later.");
      }
      return rowsAffected;
    }
    return 0;
  }

// Transaction operations
  Future<int> insertTransaction(AppTransaction txn) async {
    final db = await database;
    final pendingTransaction = txn.copyWith(status: 'pending');
    final localId = await db.insert('transactions', pendingTransaction.toMap());

    final connection = await Connectivity().checkConnectivity();
    if (connection.contains(ConnectivityResult.mobile) || connection.contains(ConnectivityResult.wifi)) {
      try {
        await _firebaseHelper.addTransaction(pendingTransaction);
        final syncedTransaction = pendingTransaction.copyWith(status: 'synced');
        await db.update('transactions', syncedTransaction.toMap(), where: 'id = ?', whereArgs: [localId]);
      } catch (e) {
        print("Failed to sync transaction to Firestore: $e");
      }
    } else {
      print("Device is offline. Transaction will be synced later.");
    }
    return localId;
  }

  Future<List<AppTransaction>> getTransactionsForContact(int contactId) async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      where: 'contact_id = ? AND status != ?',
      whereArgs: [contactId, 'deleted'],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => AppTransaction.fromMap(maps[i]));
  }

  Future<List<AppTransaction>> getTransactionsByDate(DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().substring(0, 10); // YYYY-MM-DD

    final maps = await db.query(
      'transactions',
      where: 'date = ? AND status != ?',
      whereArgs: [dateStr, 'deleted'],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => AppTransaction.fromMap(maps[i]));
  }

// Summary statistics
  Future<Map<String, double>> getContactSummary(int contactId) async {
    final db = await database;

    // Get total amount to give (debit)
    final debitResult = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE contact_id = ? AND type = ? AND status != ?',
      [contactId, 'debit', 'deleted'],
    );

    // Get total amount to get (credit)
    final creditResult = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE contact_id = ? AND type = ? AND status != ?',
      [contactId, 'credit', 'deleted'],
    );

    double debitTotal = debitResult.first['total'] as double? ?? 0.0;
    double creditTotal = creditResult.first['total'] as double? ?? 0.0;

    return {
      'willGive': debitTotal,
      'willGet': creditTotal,
      'balance': creditTotal - debitTotal,
    };
  }

// Overall statistics for the dashboard
  Future<Map<String, double>> getOverallStats() async {
    final db = await database;

    final allTransactions = await db.query('transactions');
    //print("All transactions: $allTransactions");

    // Total amount to give (all suppliers)
    final totalGiveResult = await db.rawQuery(
        '''SELECT SUM(t.amount) as total 
       FROM transactions t
       JOIN contacts c ON t.contact_id = c.id
       WHERE t.type = 'debit' AND t.status != 'deleted
    ''');

    // Total amount to get (all customers)
    final totalGetResult = await db.rawQuery(
        '''SELECT SUM(t.amount) as total 
       FROM transactions t
       JOIN contacts c ON t.contact_id = c.id
       WHERE t.type = 'credit' AND t.status != 'deleted
    ''');

    // QR collections (could be a separate table or calculated differently)
    final qrResult = await db.rawQuery(
        '''SELECT SUM(t.amount) as total 
       FROM transactions t
       WHERE t.type = 'credit' AND t.description LIKE '%QR%' AND t.status != 'deleted
    ''');

    double totalGive = totalGiveResult.first['total'] as double? ?? 0.0;
    double totalGet = totalGetResult.first['total'] as double? ?? 0.0;
    double qrCollections = qrResult.first['total'] as double? ?? 0.0;

    return {
      'willGive': totalGive,
      'willGet': totalGet,
      'qrCollections': qrCollections,
    };
  }

  Future<List<AppTransaction>> getAllTransactions() async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      where: 'status != ?',
      whereArgs: ['deleted'],
      orderBy: 'date DESC', // Sort by latest date
    );

    return List.generate(maps.length, (i) => AppTransaction.fromMap(maps[i]));
  }

  //Item CRUD operations

Future<int> insertItem(Item item)async{
  final db = await database;
  final pendingItem = item.copyWith(status: 'pending');
  final localId = await db.insert('items', pendingItem.toMap());

  final connection = await Connectivity().checkConnectivity();
  if (connection.contains(ConnectivityResult.mobile) || connection.contains(ConnectivityResult.wifi)) {
    try {
      await _firebaseHelper.addItem(pendingItem);
      final syncedItem = pendingItem.copyWith(status: 'synced');
      await db.update('items', syncedItem.toMap(), where: 'id = ?', whereArgs: [localId]);
    } catch (e) {
      print("Failed to sync item to Firestore: $e");
    }
  } else {
    print("Device is offline. Item will be synced later.");
  }
  return localId;
}

Future<Item?> getItem(int id) async{
    final db = await database;
    final maps = await db.query(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );
    if(maps.isNotEmpty)
      {
        return Item.fromMap(maps.first);
      }
    return null;
}

  Future<List<Item>>getItems() async{
    final db = await database;
    final maps = await db.query(
      'items',
      where: 'status != ?',
      whereArgs: ['deleted'],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Item.fromMap(maps[i]));
  }

  Future <List<Item>> searchItems(String query) async{
    final db = await database;
    final maps = await db.query(
      'items',
      where: 'name LIKE ? AND status != ?',
      whereArgs: ['%$query%', 'deleted'],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Item.fromMap(maps[i]));

  }

  Future <int> updateItem(Item item) async{
    final db = await database;
    final pendingItem = item.copyWith(status: 'pending');
    final rowsAffected = await db.update('items', pendingItem.toMap(), where: 'id = ?', whereArgs: [item.id]);

    final connection = await Connectivity().checkConnectivity();
    if (connection.contains(ConnectivityResult.mobile) || connection.contains(ConnectivityResult.wifi)) {
      try {
        await _firebaseHelper.updateItem(pendingItem);
        final syncedItem = pendingItem.copyWith(status: 'synced');
        await db.update('items', syncedItem.toMap(), where: 'id = ?', whereArgs: [item.id]);
      } catch (e) {
        print("Failed to sync item to Firestore: $e");
      }
    } else {
      print("Device is offline. Item will be synced later.");
    }
    return rowsAffected;
  }

  Future <int> deleteItem(int id) async{
    final db = await database;
    final itemMap = await db.query('items', where: 'id = ?', whereArgs: [id]);
    final item = itemMap.isNotEmpty ? Item.fromMap(itemMap.first) : null;

    if (item != null) {
      final deletedItem = item.copyWith(status: 'deleted');
      final rowsAffected = await db.update('items', deletedItem.toMap(), where: 'id = ?', whereArgs: [id]);

      final connection = await Connectivity().checkConnectivity();
      if (connection.contains(ConnectivityResult.mobile) || connection.contains(ConnectivityResult.wifi)) {
        try {
          await _firebaseHelper.deleteItem(deletedItem.firebaseId);
          await db.delete('items', where: 'id = ?', whereArgs: [id]);
        } catch (e) {
          print("Failed to sync item deletion to Firestore. Status remains 'deleted'.");
        }
      } else {
        print("Device is offline. Item deletion will be synced later.");
      }
      return rowsAffected;
    }
    return 0;
  }


  //Inventory transactions

  Future<int> insertInventoryTransaction(InventoryTransaction transaction) async {
    final db = await database;
    final pendingTransaction = transaction.copyWith(status: 'pending');
    final localId = await db.insert('inventory_transactions', pendingTransaction.toMap());

    final connection = await Connectivity().checkConnectivity();
    if (connection.contains(ConnectivityResult.mobile) || connection.contains(ConnectivityResult.wifi)) {
      try {
        await _firebaseHelper.addInventoryTransaction(pendingTransaction);
        final syncedTransaction = pendingTransaction.copyWith(status: 'synced');
        await db.update('inventory_transactions', syncedTransaction.toMap(), where: 'id = ?', whereArgs: [localId]);
      } catch (e) {
        print("Failed to sync inventory transaction to Firestore: $e");
      }
    } else {
      print("Device is offline. Inventory transaction will be synced later.");
    }
    return localId;
  }

  Future<List<InventoryTransaction>> getInventoryTransactionsForItem(int itemId) async {
    final db = await database;
    final maps = await db.query(
      'inventory_transactions',
      where: 'item_id = ? AND status != ?',
      whereArgs: [itemId, 'deleted'],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => InventoryTransaction.fromMap(maps[i]));
  }

  Future<double> getCurrentStock(int itemId) async {
    final db = await database;

    // Get the opening stock
    final itemResult = await db.query(
      'items',
      columns: ['opening_stock'],
      where: 'id = ? AND status != ?',
      whereArgs: [itemId, 'deleted'],
    );

    double openingStock = 0.0;
    if (itemResult.isNotEmpty) {
      openingStock = itemResult.first['opening_stock'] as double? ?? 0.0;
    }
    // Get all inventory transactions for this item
    final transactionResults = await db.rawQuery('''
      SELECT type, SUM(quantity) as total
      FROM inventory_transactions
      WHERE item_id = ? AND status != 'deleted'
      GROUP BY type
    ''', [itemId]);

    double currentStock = openingStock;

    for (final result in transactionResults) {
      final type = result['type'] as String;
      final total = result['total'] as double? ?? 0.0;

      if (type == 'purchase') {
        currentStock += total;
      } else if (type == 'sale') {
        currentStock -= total;
      } else if (type == 'adjustment') {
        // For adjustments, the quantity can be positive or negative
        currentStock += total;
      }
    }

    return currentStock;
  }
  Future<Map<String, dynamic>> getItemStats(int itemId) async {
    final db = await database;

    // Total purchases
    final purchasesResult = await db.rawQuery('''
      SELECT SUM(quantity) as total
      FROM inventory_transactions
      WHERE item_id = ? AND type = 'purchase' AND status != 'deleted'
    ''', [itemId]);

    // Total sales
    final salesResult = await db.rawQuery('''
      SELECT SUM(quantity) as total
      FROM inventory_transactions
      WHERE item_id = ? AND type = 'sale' AND status != 'deleted'
    ''', [itemId]);

    // Current stock
    final currentStock = await getCurrentStock(itemId);

    // Get item details for valuation
    final item = await getItem(itemId);

    return {
      'purchases': purchasesResult.first['total'] as double? ?? 0.0,
      'sales': salesResult.first['total'] as double? ?? 0.0,
      'currentStock': currentStock,
      'stockValue': currentStock * (item?.purchasePrice ?? 0.0),
      'potentialSaleValue': currentStock * (item?.salePrice ?? 0.0),
    };
  }

  //LOCALLY INSERTING DATA WITHOUT ONLINE SYNC

  Future<int> insertContactLocally(Contact contact) async {
    final db = await database;
    return await db.insert('contacts', contact.toMap());
  }


  Future<int> insertTransactionLocally(AppTransaction txn) async {
    final db = await database;
    return await db.insert('transactions', txn.toMap());
  }


  Future<int> insertItemLocally(Item item) async {
    final db = await database;
    return await db.insert('items', item.toMap());
  }

  Future<int> insertInventoryTransactionLocally(InventoryTransaction transaction) async {
    final db = await database;
    return await db.insert('inventory_transactions', transaction.toMap());
  }

  // Getting 'Pending' status information.

  Future<List<Contact>> getPendingContacts() async {
    final db = await database;
    final maps = await db.query(
      'contacts',
      where: 'status = ? OR status = ?',
      whereArgs: ['pending', 'deleted'],
    );
    return List.generate(maps.length, (i) => Contact.fromMap(maps[i]));
  }

  Future<List<AppTransaction>> getPendingTransactions() async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      where: 'status = ? OR status = ?',
      whereArgs: ['pending', 'deleted'],
    );
    return List.generate(maps.length, (i) => AppTransaction.fromMap(maps[i]));
  }

  Future<List<Item>> getPendingItems() async {
    final db = await database;
    final maps = await db.query(
      'items',
      where: 'status = ? OR status = ?',
      whereArgs: ['pending', 'deleted'],
    );
    return List.generate(maps.length, (i) => Item.fromMap(maps[i]));
  }

  Future<List<InventoryTransaction>> getPendingInventoryTransactions() async {
    final db = await database;
    final maps = await db.query(
      'inventory_transactions',
      where: 'status = ? OR status = ?',
      whereArgs: ['pending', 'deleted'],
    );
    return List.generate(maps.length, (i) => InventoryTransaction.fromMap(maps[i]));
  }

  // Updating as Synced.
  Future<int> updateContactStatus(int id, String status) async {
    final db = await database;
    return await db.update(
      'contacts',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateTransactionStatus(int id, String status) async {
    final db = await database;
    return await db.update(
      'transactions',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateItemStatus(int id, String status) async {
    final db = await database;
    return await db.update(
      'items',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateInventoryTransactionStatus(int id, String status) async {
    final db = await database;
    return await db.update(
      'inventory_transactions',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Permanently deleting data from Local Storage.
  Future<void> hardDeleteContact(int id) async {
    final db = await database;
    await db.delete('contacts', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> hardDeleteTransaction(int id) async {
    final db = await database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> hardDeleteItem(int id) async {
    final db = await database;
    await db.delete('items', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> hardDeleteInventoryTransaction(int id) async {
    final db = await database;
    await db.delete('inventory_transactions', where: 'id = ?', whereArgs: [id]);
  }


  Future<int> updateContactLocally(Contact contact) async {
    final db = await database;
    return await db.update(
      'contacts',
      contact.toMap(),
      where: 'firebaseId = ?',
      whereArgs: [contact.firebaseId],
    );
  }

  Future<int> deleteContactLocally(String firebaseId) async {
    final db = await database;
    return await db.delete(
      'contacts',
      where: 'firebaseId = ?',
      whereArgs: [firebaseId],
    );
  }

  Future<int> updateTransactionLocally(AppTransaction txn) async {
    final db = await database;
    return await db.update(
      'transactions',
      txn.toMap(),
      where: 'firebaseId = ?',
      whereArgs: [txn.firebaseId],
    );
  }

  Future<int> deleteTransactionLocally(String firebaseId) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'firebaseId = ?',
      whereArgs: [firebaseId],
    );
  }
  Future<int> updateItemLocally(Item item) async {
    final db = await database;
    return await db.update(
      'items',
      item.toMap(),
      where: 'firebaseId = ?',
      whereArgs: [item.firebaseId],
    );
  }

  Future<int> deleteItemLocally(String firebaseId) async {
    final db = await database;
    return await db.delete(
      'items',
      where: 'firebaseId = ?',
      whereArgs: [firebaseId],
    );
  }
  Future<int> updateInventoryTransactionLocally(InventoryTransaction transaction) async {
    final db = await database;
    return await db.update(
      'inventory_transactions',
      transaction.toMap(),
      where: 'firebaseId = ?',
      whereArgs: [transaction.firebaseId],
    );
  }

  Future<int> deleteInventoryTransactionLocally(String firebaseId) async {
    final db = await database;
    return await db.delete(
      'inventory_transactions',
      where: 'firebaseId = ?',
      whereArgs: [firebaseId],
    );
  }


}