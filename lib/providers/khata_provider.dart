import 'package:flutter/material.dart';
import 'package:khatabook/data/database/database_helper.dart';
import 'package:khatabook/data/models/contact.dart';
import 'package:khatabook/data/models/customer_stats.dart';
import 'package:khatabook/data/models/inventory_transaction.dart';
import 'package:khatabook/data/models/transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/item.dart';


class KhataBookProvider extends ChangeNotifier{
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  final Map<int,Map<String,double>> _contactBalances ={};

  List <Contact> _customers = [];
  List <Contact> _suppliers = [];
  List<Contact> _filteredCustomers = [];
  List<Item> _items = [];
  List<Item> _filteredItems = [];


  CustomerStats _stats = CustomerStats(willGive: 0, willGet: 0, qrCollections: 0);

  List<Contact> get customers =>  _filteredCustomers.isNotEmpty ? _filteredCustomers : _customers;
  List<Contact> get suppliers => _suppliers;
  CustomerStats get stats => _stats;
  Map<int, Map<String, double>> get contactBalances => _contactBalances;
  List<Item> get items => _filteredItems.isNotEmpty ? _filteredItems : _items;

  String _name = 'My Business';
  String get name => _name;

  KhataBookProvider(){
    _loadName();
  }

  void setName(String value) async {
    _name = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('business_name', value);
  }

  void _loadName() async {
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString('business_name') ?? '';
    notifyListeners();
  }

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


  //Providers related to Inventory Management


  Future<void> loadItems() async{
    _items = await _databaseHelper.getItems();
    notifyListeners();
  }

  Future <void> addItems(Item item) async
  {
    final id = await _databaseHelper.insertItem(item);
    item.id = id;
    _items.add(item);
    notifyListeners();
  }

  Future <void> updateItem(Item item) async{
    await _databaseHelper.updateItem(item);
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _items[index] = item;
      notifyListeners();
    }
  }
  Future <void> deleteItem(int id) async{
    await _databaseHelper.deleteItem(id);
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }
  Future <void> searchItems(String query) async{
    if(query.isEmpty){
      _filteredItems = [];
    }
    else{
      _filteredItems = _items.where((item)=>
      item.name.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }
    notifyListeners();
  }
  Future <void> addInventoryTransactions(InventoryTransaction transaction)async{
    await _databaseHelper.insertInventoryTransaction(transaction);
    notifyListeners();
  }
  Future<double> getCurrentStock(int itemId) async {
    return await _databaseHelper.getCurrentStock(itemId);
  }
}