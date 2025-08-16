import 'package:khatabook/data/database/database_helper.dart';
import 'package:khatabook/data/database/firestore_helper.dart';

class DataSyncService{
  final _databaseHelper = DatabaseHelper();
  final _firestoreHelper = FirebaseHelper();

  Future <void> syncPendingData() async{
    print("Synchronization starting");

    try{
      final pendingContacts = await _databaseHelper.getPendingContacts();
      final pendingTransactions = await _databaseHelper.getPendingTransactions();
      final pendingItems = await _databaseHelper.getPendingItems();
      final pendingInventoryTransactions = await _databaseHelper.getPendingInventoryTransactions();

      for (final contact in pendingContacts) {
        if (contact.status == 'deleted') {
          await _firestoreHelper.deleteContact(contact.firebaseId);
          await _databaseHelper.hardDeleteContact(contact.id!);
        } else {
          await _firestoreHelper.addContact(contact); // Can be add or update based on firebaseId
          await _databaseHelper.updateContactStatus(contact.id!, 'synced');
        }
      }
      for (final txn in pendingTransactions) {
        if (txn.status == 'deleted') {
          await _firestoreHelper.deleteTransaction(txn.firebaseId);
          await _databaseHelper.hardDeleteTransaction(txn.id!);
        } else {
          await _firestoreHelper.addTransaction(txn);
          await _databaseHelper.updateTransactionStatus(txn.id!, 'synced');
        }
      }

      // Step 4: Process pending items
      for (final item in pendingItems) {
        if (item.status == 'deleted') {
          await _firestoreHelper.deleteItem(item.firebaseId);
          await _databaseHelper.hardDeleteItem(item.id!);
        } else {
          await _firestoreHelper.addItem(item);
          await _databaseHelper.updateItemStatus(item.id!, 'synced');
        }
      }

      // Step 5: Process pending inventory transactions
      for (final invTxn in pendingInventoryTransactions) {
        if (invTxn.status == 'deleted') {
          // You may not have a delete function for inventory transactions, handle as appropriate.
        } else {
          await _firestoreHelper.addInventoryTransaction(invTxn);
          await _databaseHelper.updateInventoryTransactionStatus(invTxn.id!, 'synced');
        }
      }

      print("Data synchronization complete.");
    } catch (e) {
      print("Data synchronization failed: $e");
    }
  }
}

