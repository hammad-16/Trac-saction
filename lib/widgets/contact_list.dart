import 'package:flutter/material.dart';
import 'package:khatabook/pages/transaction_page.dart';

import '../data/models/contact.dart';

class ContactListItem extends StatelessWidget {
  final Contact contact;
  final double amount;
  const ContactListItem({Key? key, required this.contact, required this.amount}) : super(key: key);

  //Helper function to get the initials
  String _getInitials() {
    if (contact.name.isEmpty) return '?';

    final nameParts = contact.name.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else {
      return contact.name[0].toUpperCase();
    }
  }
  //Helper function to get the time since last interaction
  String _getTime() {
    final now = DateTime.now();
    final difference = now.difference(contact.createdAt);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => TransactionPage(contact: contact,)
        ));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
          decoration:  BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade200,
                width: 1
              )
            )
          ),
        child: Row(
          children: [
            Container(
              width: 40,
                height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle
              ),
              alignment: Alignment.center,
              child: Text(
                _getInitials(),
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16
                ),
              ),
            ),
            Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16
                      ),
                    ),
                    const SizedBox(height:4),
                    Text(_getTime(),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14
                    ),
                    )
                  ],
                ),
            ),
            Container(
              padding: const EdgeInsets.only(right:16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text('₹ ${amount.toInt()}',
                       style: TextStyle(
                       fontWeight: FontWeight.bold,
                       fontSize: 16,
                       color: amount > 0 ? Colors.green : Colors.black
                       )
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        )

      ),
    );
  }
}