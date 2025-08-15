
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:khatabook/data/models/contact.dart';

import '../models/inventory_transaction.dart';
import '../models/item.dart';
import '../models/transaction.dart';

class FirebaseHelper{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
}



