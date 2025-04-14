import 'package:flutter/material.dart';
import 'package:khatabook/data/database/database_helper.dart';
import 'package:khatabook/data/models/contact.dart';
import 'package:khatabook/data/models/customer_stats.dart';
import 'package:khatabook/data/models/transaction.dart';
import 'package:sqflite/sqflite.dart';

class KhataBookProvider extends ChangeNotifier{
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  List <Contact> _customers = [];
  List <Contact> _suppliers = [];
  List<Contact> _filteredCustomers = [];

  CustomerStats _stats = CustomerStats(willGive: 0, willGet: 0, qrCollections: 0);

  List<Contact> get customers => _customers;
  List<Contact> get suppliers => _suppliers;
  CustomerStats get stats => _stats;


    Future<void> loadCustomers() async{
      _customers = await _databaseHelper.getContacts('customer');
      notifyListeners();
    }

    Future<void> loadSuppliers() async{
      _customers = await _databaseHelper.getContacts('supplier');
      notifyListeners();
    }

    Future<void> loadStats() async{
      final stats = await _databaseHelper.getOverallStats();
      _stats = CustomerStats(
          willGive: stats['willGive'] ?? 0 ,
          willGet: stats['willGet'] ?? 0,
          qrCollections: stats['qrCollections'] ?? 0);

      _customers = await _databaseHelper.getContacts('customer');
      notifyListeners();
    }
  Future<void> loadData() async {
    await Future.wait([
      loadCustomers(),
      loadSuppliers(),
      loadStats(),
    ]);
  }

    //When we are adding customers to the user list

    Future<void> addCustomer(Contact customer) async{
      final id = await _databaseHelper.insertContact(customer);

      customer.id = id;
      _customers.add(customer);
      notifyListeners();

    }
    //When we are adding suppliers to the user list

    Future<void> addSupplier(Contact supplier) async {
      final id = await _databaseHelper.insertContact(supplier);

      supplier.id = id;
      _suppliers.add(supplier);
      notifyListeners();
    }

    //Adding user transactions

   Future<void> addTransaction(AppTransaction transaction) async{
      await _databaseHelper.insertTransaction(transaction);
      await loadStats();
   }


  Future<List<AppTransaction>> getDailyPassbook(DateTime date) async {
    return await _databaseHelper.getTransactionsByDate(date);
  }

  Future<void> searchCustomers(String query) async{
      if(query.isEmpty)
        {
          _filteredCustomers =[];
        }
      else
        {
          _filteredCustomers = await _databaseHelper.searchContacts(query,'customer');
        }
      notifyListeners();
  }


}