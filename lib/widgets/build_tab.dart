import 'package:flutter/material.dart';

Widget buildTab(String title, bool isSelected) {
  return Column(
    children: [
      Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      const SizedBox(height: 5),
      if (isSelected)
        Container(
          height: 3,
          width: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFFFA000),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
    ],
  );
}