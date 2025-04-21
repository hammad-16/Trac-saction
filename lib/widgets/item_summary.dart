import 'package:flutter/material.dart';

class ItemSummary extends StatefulWidget {
  const ItemSummary({super.key});

  @override
  State<ItemSummary> createState() => _ItemSummaryState();
}

class _ItemSummaryState extends State<ItemSummary> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Hello"),
                ],
              ),
            ),
            ),
            Expanded(child: Padding(
                padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text("Hello")
                ],
              ),
            )
            )
          ],
        ),
        Row(

        )
      ],
    );
  }
}
