import 'package:flutter/material.dart';
import 'package:khatabook/widgets/item_summary.dart';

Widget buildTab(String type)
{
  return Column(
    children: [
      ItemSummary(),

      Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                  child: Container(
                    height: 48,
                      decoration: BoxDecoration(
                       border: Border.all(
                           color: Colors.grey.shade300,
                       ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search Items',
                        border: InputBorder.none,
                        prefixIcon: const Icon(Icons.search),
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        hintStyle: TextStyle(color: Colors.grey)
                      ),
                      onChanged: (value){

                      },
                    ),
                  )
              )
            ],
          ),

      )
    ],
  );
}