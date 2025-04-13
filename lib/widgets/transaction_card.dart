import 'package:flutter/material.dart';

Widget buildCustomerCard(Map<String, dynamic> customer) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border(
        bottom: BorderSide(color: Colors.grey[200]!),
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Customer initials
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              customer['initials'],
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Customer name and time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  customer['timeAgo'],
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Amount
          Text(
            '₹ ${customer['amount']}',
            style: TextStyle(
              color: customer['willGive'] ? Colors.green[700] : Colors.red[700],
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    ),
  );
}
