import 'package:flutter/material.dart';
import 'package:khatabook/providers/khata_provider.dart';
import 'package:provider/provider.dart';

import '../widgets/buildTab.dart';

class Inventory extends StatefulWidget {
  const Inventory({super.key});

  @override
  State<Inventory> createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
     _tabController = TabController(length: 2, vsync: this);
     _tabController.addListener(
         (){
           if(!_tabController.indexIsChanging){
             setState(() {
             });
           }
         }
     );
     WidgetsBinding.instance.addPostFrameCallback((_){
       Provider.of<KhataBookProvider>(context, listen: false).loadItems();
     });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        title: const Text('Items'),
        bottom: TabBar(
          controller: _tabController,
          indicatorWeight: 3,
          indicatorColor: Colors.orange,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(text: 'Products'),
            Tab(text: 'Services'),
          ],
        ),
      ),
      body: TabBarView(
          controller: _tabController,
          children: [
            buildTab('product'),
            buildTab('service')

          ]
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: (){
            // Navigator.push(context,
            // MaterialPageRoute(
            //     builder: (context)=>AddItemPage(
            //       itemType: _tabController == 0 ? 'product' : 'service',
            //     )
            // )
            // );
          },
          backgroundColor: const Color(0xFF1976D2),
         icon: const Icon(Icons.add_box_outlined),
          label: Text(_tabController.index == 0? 'ADD PRODUCT' : 'ADD SERVICE'),
          ),
    );
  }
}
