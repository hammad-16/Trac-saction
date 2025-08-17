
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:khatabook/data/database/database_helper.dart';
import 'package:khatabook/data/models/contact.dart';
import '../models/inventory_transaction.dart';
import '../models/item.dart';
import '../models/transaction.dart';

class FirebaseHelper{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _databaseHelper = DatabaseHelper();

  String? get uid => _auth.currentUser?.uid;

  CollectionReference get _userContactsCollection {
    return _firestore.collection('users').doc(uid).collection('contacts');
  }

  CollectionReference get _userTransactionsCollection =>
      _firestore.collection('users').doc(uid).collection('transactions');

  CollectionReference get _userItemsCollection =>
      _firestore.collection('users').doc(uid).collection('items');

  CollectionReference get _userInventoryTransactionsCollection =>
      _firestore.collection('users').doc(uid).collection('inventory_transactions');

  void _checkAuth() {
    if (uid == null) {
      throw Exception("User not authenticated.");
    }
  }

  //To add a contact to Firestore
  Future <void> addContact(Contact contact) async{
    if(uid == null){
      throw Exception("User not authenticated");
    }
    await _userContactsCollection.doc(contact.firebaseId).set(contact.toMap());
  }

  //To retrieve all contacts from Firestore
  Future <List<Contact>> getContacts() async{
    if(uid == null)
      throw Exception("User not authenticated");

    final snapshot = await _userContactsCollection.get();
    return snapshot.docs.map((doc) => Contact.fromMap(doc.data() as Map<String, dynamic>)).toList();
  }
  // To update a contact in Firestore
  Future<void> updateContact(Contact contact) async {
    if (uid == null) {
      throw Exception("User not authenticated.");
    }
    await _userContactsCollection.doc(contact.firebaseId).update(contact.toMap());
  }

  //To delete a contact from Firestore
  Future<void> deleteContact(String firebaseId) async {
    if (uid == null) {
      throw Exception("User not authenticated.");
    }
    await _userContactsCollection.doc(firebaseId).delete();
  }
  // Transaction operations
  Future<void> addTransaction(AppTransaction transaction) async {
    _checkAuth();
    await _userTransactionsCollection.doc(transaction.firebaseId).set(transaction.toMap());
  }

  Future<void> updateTransaction(AppTransaction transaction) async {
    _checkAuth();
    await _userTransactionsCollection.doc(transaction.firebaseId).update(transaction.toMap());
  }

  Future<void> deleteTransaction(String firebaseId) async {
    _checkAuth();
    await _userTransactionsCollection.doc(firebaseId).delete();
  }

  // Item operations
  Future<void> addItem(Item item) async {
    _checkAuth();
    await _userItemsCollection.doc(item.firebaseId).set(item.toMap());
  }

  Future<void> updateItem(Item item) async {
    _checkAuth();
    await _userItemsCollection.doc(item.firebaseId).update(item.toMap());
  }

  Future<void> deleteItem(String firebaseId) async {
    _checkAuth();
    await _userItemsCollection.doc(firebaseId).delete();
  }

  // Inventory Transaction operations
  Future<void> addInventoryTransaction(InventoryTransaction transaction) async {
    _checkAuth();
    await _userInventoryTransactionsCollection.doc(transaction.firebaseId).set(transaction.toMap());
  }

  Future<void> syncFromFirestore() async{
    _checkAuth();
    final contactsQuery = await _userContactsCollection.get();
    final transactionsQuery = await _userTransactionsCollection.get();
    final itemsQuery = await _userItemsCollection.get();
    final inventoryTransactionsQuery = await _userInventoryTransactionsCollection.get();

    final db = DatabaseHelper();
    for(var doc in contactsQuery.docs){
      final contact = Contact.fromMap(doc.data() as Map<String, dynamic>);
      await db.insertContactLocally(contact);
    }

    // Batch insert transactions
    for (var doc in transactionsQuery.docs) {
      final transaction = AppTransaction.fromMap(doc.data() as Map<String, dynamic>);
      await db.insertTransactionLocally(transaction);
    }

    // Batch insert items
    for (var doc in itemsQuery.docs) {
      final item = Item.fromMap(doc.data() as Map<String, dynamic>);
      await db.insertItemLocally(item);
    }

    // Batch insert inventory transactions
    for (var doc in inventoryTransactionsQuery.docs) {
      final invTransaction = InventoryTransaction.fromMap(doc.data() as Map<String, dynamic>);
      await db.insertInventoryTransactionLocally(invTransaction);
    }
  }

  //Listening for real-time contact changes
  void startContactListener() {
    _checkAuth();
    _userContactsCollection.snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        final contactMap = change.doc.data() as Map<String, dynamic>;
        final contact = Contact.fromMap(contactMap);
        switch (change.type) {
          case DocumentChangeType.added:
          // Insert or update locally if it doesn't exist
            _databaseHelper.insertContactLocally(contact);
            break;
          case DocumentChangeType.modified:
          // Update the local record
            _databaseHelper.updateContactLocally(contact);
            break;
          case DocumentChangeType.removed:
          // Hard delete the local record
            _databaseHelper.hardDeleteContact(contact.id!);
            break;
        }
      }
    });
  }

  void startTransactionListener() {
    _checkAuth();
    _userTransactionsCollection.snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        final transactionMap = change.doc.data() as Map<String, dynamic>;
        final transaction = AppTransaction.fromMap(transactionMap);
        switch (change.type) {
          case DocumentChangeType.added:
            _databaseHelper.insertTransactionLocally(transaction);
            break;
          case DocumentChangeType.modified:
            _databaseHelper.updateTransactionLocally(transaction);
            break;
          case DocumentChangeType.removed:
            _databaseHelper.deleteTransactionLocally(transaction.firebaseId);
            break;
        }
      }
    });
  }

  void startItemListener() {
    _checkAuth();
    _userItemsCollection.snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        final itemMap = change.doc.data() as Map<String, dynamic>;
        final item = Item.fromMap(itemMap);
        switch (change.type) {
          case DocumentChangeType.added:
            _databaseHelper.insertItemLocally(item);
            break;
          case DocumentChangeType.modified:
            _databaseHelper.updateItemLocally(item);
            break;
          case DocumentChangeType.removed:
            _databaseHelper.deleteItemLocally(item.firebaseId);
            break;
        }
      }
    });
  }

  void startInventoryTransactionListener() {
    _checkAuth();
    _userInventoryTransactionsCollection.snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        final invTxnMap = change.doc.data() as Map<String, dynamic>;
        final invTxn = InventoryTransaction.fromMap(invTxnMap);
        switch (change.type) {
          case DocumentChangeType.added:
            _databaseHelper.insertInventoryTransactionLocally(invTxn);
            break;
          case DocumentChangeType.modified:
            _databaseHelper.updateInventoryTransactionLocally(invTxn);
            break;
          case DocumentChangeType.removed:
            _databaseHelper.deleteInventoryTransactionLocally(invTxn.firebaseId);
            break;
        }
      }
    });
  }

}



