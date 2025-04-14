import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:khatabook/main.dart';
import 'package:khatabook/services/contact_picker_service.dart';
import 'package:khatabook/widgets/build_qr_col.dart';
import 'package:khatabook/widgets/build_stat_column.dart';
import 'package:khatabook/widgets/contact_list.dart';
import 'package:provider/provider.dart';

import '../providers/khata_provider.dart';
import '../widgets/build_tab.dart';

class PartiesPages extends StatefulWidget {
  const PartiesPages({super.key});

  @override
  State<PartiesPages> createState() => _PartiesPagesState();
}

class _PartiesPagesState extends State<PartiesPages> {
  final TextEditingController _searchController = TextEditingController();
  String _searchName = '';
  bool _isCustomerTab =true;
  bool _isLoading = false;
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  void onSearch(String value)
  {
    final provider = Provider.of<KhataBookProvider>(context, listen: false);
    provider.searchCustomers(value);
  }
  Future<void> _pickContact() async {
    setState(() {
      _isLoading = true;
    });
    try{

      final contact = await ContactPickerService.pickContact();
      if(contact != null && mounted)
        {
          contact.type = _isCustomerTab ? 'customer' : 'supplier';
          final provider = Provider.of<KhataBookProvider>(context, listen: false);
          if(_isCustomerTab)
            {
              await provider.addCustomer(contact);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Customer added successfully'),
                  backgroundColor: Colors.green,
                ),

              );
              await provider.loadCustomers();
            }
          else
            {
              await provider.addSupplier(contact);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Supplier added successfully'),
                  backgroundColor: Colors.green,
                )
              );
              await provider.loadSuppliers();
            }
        }
    }
    catch(e)
    {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error Adding contact'),
          backgroundColor: Colors.red,
        )
      );
    }
    finally{
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      Provider.of<KhataBookProvider>(context, listen: false).loadData();
    });

  }
  void _changeTab(bool isCustomers)
  {
    if(_isCustomerTab != isCustomers)
      {
        setState(() {
          _isCustomerTab = isCustomers;
          _searchController.clear();
        });
        if(_isCustomerTab)
          {
            Provider.of<KhataBookProvider>(context,listen: false).loadCustomers();
          }
        else
          {
            Provider.of<KhataBookProvider>(context, listen: false).loadSuppliers();

          }
      }
  }
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<KhataBookProvider>(context);
    final stats = provider.stats;
    final contacts = _isCustomerTab ? provider.customers : provider.suppliers;
    final contactBalances = provider.contactBalances;

    return Scaffold(
      body: Column(
        children: [
          Container(
            color: const Color(0xFF0D47A1),
            child: Column(
              children: [
                Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: ()=> _changeTab(true),
                          child: buildTab('CUSTOMERS', _isCustomerTab),
                      ),
                      const SizedBox(width:16),
                      GestureDetector(
                          onTap: ()=> _changeTab(false),
                          child: buildTab('SUPPLIERS', !_isCustomerTab)
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow:[
                      BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0,2),
                    )
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Row(
                          children: [
                            Expanded(
                                child: buildStatColumn('You will give', '₹ 0')
                            ),
                            Container(
                              height: 40,
                                width: 1,
                              color: Colors.grey.withOpacity(0.3),
                            ),
                            Expanded(
                                child: buildStatColumn('You will get', '₹ 0')
                            ),
                            Container(
                              height: 40,
                              width: 1,
                              color: Colors.grey.withOpacity(0.3),
                            ),
                            Expanded(
                                child: buildQRColumn('You will get', '₹ 0')
                            ),
                          ],
                        ),




                      ),

                      InkWell(
                        onTap: (){},
                        child: Padding(padding: const EdgeInsets.symmetric(vertical: 8)
                      , child: Row(

                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.bar_chart,
                              color: Colors.blue[700],
                              size: 18),
                              const SizedBox(width: 4),
                              Text('View Reports',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 14
                              ),)

                            ],

                          ),

                        ),
                      ),


                    ],
                  ),
                )
              ],

            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.0001),
                  blurRadius: 2,
                  offset: const Offset(0,1),
                )
              ]
            ),
            child: Row(
              children: [
                Expanded(
                    child:  Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search,
                              color: Colors.blue[700],
                              size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                              child: TextField(
                                controller: _searchController ,
                                decoration: InputDecoration(
                                  hintText: _isCustomerTab?'Search Customer':'Search Supplier',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  isDense: true
                                ),
                                onChanged: onSearch,

                              )
                          ),

                        ],
                      ),
                    )
                ),
                const SizedBox(width:12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical:8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.filter_list, color:Colors.blue[700], size: 18,),
                      const SizedBox(width: 4),
                      Text(
                        'Filters',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          Expanded(child:
              contacts.isEmpty?
          Center(
            child: Text('Customer list will appear here'),
          ):
            ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (context,ind){
                  final contact = contacts[ind];
                  double amount = 0;
                  String balanceType = '';
                  if(contact.id != null && contactBalances.containsKey(contact.id))
                    {
                      final balance = contactBalances[contact.id]!;

                      if(_isCustomerTab){
                        amount = balance['balance'] ?? 0;
                        balanceType = amount >= 0 ? 'get' : 'give';
                        amount = amount.abs();
                      }
                      else
                        {
                          amount = balance['balance'] ?? 0;
                          balanceType = amount >= 0 ? 'give' : 'get';
                          amount = amount.abs();
                        }
                    }

                  return ContactListItem(
                    contact: contact,
                    amount: amount,
                    balanceType: balanceType,

                  );
                }),
          ),
          Padding(padding: const EdgeInsets.only(left:130, bottom: 30,right: 22),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(onPressed: _isLoading? null : _pickContact,
                label: Text(_isCustomerTab?'ADD CUSTOMER':'ADD SUPPLIER',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              icon: _isLoading? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ): Icon(Icons.person_add),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isCustomerTab? Color(0xFFC2185B): Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28)
                )
              ),

            ),
          ),)
        ],
      ),
    );
  }
}
