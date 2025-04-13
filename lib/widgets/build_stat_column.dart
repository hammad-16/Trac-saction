import 'package:flutter/material.dart';

Widget buildStatColumn(String title, String value) {
  return Column(
    children: [
      Text(
        title,
        style: TextStyle(
          color: Colors.grey[700],
          fontSize: 12,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ],
  );
}
