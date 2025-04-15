import 'package:flutter/material.dart';
import 'package:khatabook/data/database/database_helper.dart';
import 'package:khatabook/data/models/contact.dart';
import 'package:khatabook/data/models/customer_stats.dart';
import 'package:khatabook/data/models/transaction.dart';
import 'package:sqflite/sqflite.dart';

class KhataBookProvider extends ChangeNotifier{
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  final Map<int,Map<String,double>> _contactBalances ={};

  List <Contact> _customers = [];
  List <Contact> _suppliers = [];
  List<Contact> _filteredCustomers = [];


  CustomerStats _stats = CustomerStats(willGive: 0, willGet: 0, qrCollections: 0);

  List<Contact> get customers =>  _filteredCustomers.isNotEmpty ? _filteredCustomers : _customers;
  List<Contact> get suppliers => _suppliers;
  CustomerStats get stats => _stats;
  Map<int, Map<String, double>> get contactBalances => _contactBalances;


    Future<void> loadCustomers() async{
      _customers = await _databaseHelper.getContacts('customer');
      notifyListeners();
    }

    Future<void> loadSuppliers() async{
      _suppliers = await _databaseHelper.getContacts('supplier');
      notifyListeners();
    }

    Future<void> loadStats() async{
      final stats = await _databaseHelper.getOverallStats();
      print("DEBUG - Stats loaded: $stats");
      _stats = CustomerStats(
          willGive: stats['willGive'] ?? 0 ,
          willGet: stats['willGet'] ?? 0,
          qrCollections: stats['qrCollections'] ?? 0);

      notifyListeners();
    }

    Future<void> loadContactBalances() async{
      final customers = await _databaseHelper.getContacts('customer');
      final suppliers = await _databaseHelper.getContacts('supplier');
      final allContacts = [...customers, ...suppliers];

      for(final contact in allContacts)
        {
          if(contact.id != null)
            {
              try{
                final summary = await _databaseHelper.getContactSummary(contact.id!);
                _contactBalances[contact.id!] =summary;
              }
              catch(e)
      {
        print('Error loading balance for contact ${contact.id} $e');

      }
            }
        }
      notifyListeners();

    }
  Future<void> loadData() async {
    await Future.wait([
      loadCustomers(),
      loadSuppliers(),
      loadStats(),
    ]);

    await loadContactBalances();
  }



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
      await loadContactBalances();
      if(transaction.contactId != null)
        {
          final summary = await _databaseHelper.getContactSummary(transaction.contactId);
          _contactBalances[transaction.contactId] = summary;
          notifyListeners();
        }
   }


  Future<List<AppTransaction>> getDailyPassbook(DateTime date) async {
    return await _databaseHelper.getTransactionsByDate(date);
  }
  Future<List<AppTransaction>> getOverallPassbook() async {
    return await _databaseHelper.getAllTransactions();
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

  Future<List<AppTransaction>> getTransactionsForContact(int contactId) async {
    return await _databaseHelper.getTransactionsForContact(contactId);
  }

  Future<Map<String, double>> getContactSummary(int contactId) async {
    return await _databaseHelper.getContactSummary(contactId);
  }


}