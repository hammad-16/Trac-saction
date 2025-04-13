import 'package:khatabook/data/models/transaction.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/contact.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

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
        name TEXT NOT NULL,
        phone TEXT,
        type TEXT NOT NULL,    -- 'customer' or 'supplier'
        notes TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // This is the Transactions table
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        contact_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,    -- 'credit' (you'll get) or 'debit' (you'll give)
        description TEXT,
        date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (contact_id) REFERENCES contacts (id) ON DELETE CASCADE
      )
    ''');
  }
  Future<int> insertContact(Contact contact) async {
    final db = await database;
    return await db.insert('contacts', contact.toMap());
  }

  Future<Contact?> getContact(int id) async {
    final db = await database;
    final maps = await db.query(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
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
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Contact.fromMap(maps[i]));
  }

  Future<int> updateContact(Contact contact) async {
    final db = await database;
    return await db.update(
      'contacts',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  Future<int> deleteContact(int id) async {
    final db = await database;
    return await db.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

// Transaction operations
  Future<int> insertTransaction(AppTransaction txn) async {
    final db = await database;
    return await db.insert('transactions', txn.toMap());
  }

  Future<List<AppTransaction>> getTransactionsForContact(int contactId) async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      where: 'contact_id = ?',
      whereArgs: [contactId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => AppTransaction.fromMap(maps[i]));
  }

  Future<List<AppTransaction>> getTransactionsByDate(DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().substring(0, 10); // YYYY-MM-DD

    final maps = await db.query(
      'transactions',
      where: 'date = ?',
      whereArgs: [dateStr],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => AppTransaction.fromMap(maps[i]));
  }

// Summary statistics
  Future<Map<String, double>> getContactSummary(int contactId) async {
    final db = await database;

    // Get total amount to give (debit)
    final debitResult = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE contact_id = ? AND type = ?',
      [contactId, 'debit'],
    );

    // Get total amount to get (credit)
    final creditResult = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE contact_id = ? AND type = ?',
      [contactId, 'credit'],
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

    // Total amount to give (all suppliers)
    final totalGiveResult = await db.rawQuery(
        '''SELECT SUM(t.amount) as total 
       FROM transactions t
       JOIN contacts c ON t.contact_id = c.id
       WHERE t.type = 'debit' AND c.type = 'supplier'
    ''');

    // Total amount to get (all customers)
    final totalGetResult = await db.rawQuery(
        '''SELECT SUM(t.amount) as total 
       FROM transactions t
       JOIN contacts c ON t.contact_id = c.id
       WHERE t.type = 'credit' AND c.type = 'customer'
    ''');

    // QR collections (could be a separate table or calculated differently)
    final qrResult = await db.rawQuery(
        '''SELECT SUM(t.amount) as total 
       FROM transactions t
       WHERE t.type = 'credit' AND t.description LIKE '%QR%'
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

}