import 'package:flutter/material.dart';
import 'package:khatabook/widgets/build_qr_col.dart';
import 'package:khatabook/widgets/build_stat_column.dart';
import 'package:provider/provider.dart';

import '../widgets/build_tab.dart';

class PartiesPages extends StatefulWidget {
  const PartiesPages({super.key});

  @override
  State<PartiesPages> createState() => _PartiesPagesState();
}

class _PartiesPagesState extends State<PartiesPages> {
  final TextEditingController _searchController = TextEditingController();
  String _searchName = '';
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      buildTab('CUSTOMERS', true),
                      const SizedBox(width:16),
                      buildTab('SUPPLIERS', false),
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
                                decoration: const InputDecoration(
                                  hintText: 'Search Customer',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  isDense: true
                                ),
                                onChanged: (value){
                                  setState(() {
                                    _searchName = value;
                                  });
                                },

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
          Expanded(child: Center(
            child: Text('Customer list will appear here'),
          ),
          ),
          Padding(padding: const EdgeInsets.only(left:180, bottom: 30),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(onPressed: (){},
                label: const Text('ADD CUSTOMER'),
              icon: Icon(Icons.person_add),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC2185B),
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
