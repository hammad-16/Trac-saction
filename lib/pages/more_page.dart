import 'package:flutter/material.dart';
import 'package:khatabook/pages/inventory.dart';
import 'package:khatabook/pages/passbook.dart';
import 'package:khatabook/pages/settings_page.dart';
import 'package:khatabook/pages/staff.dart';
import 'package:khatabook/widgets/more_page_card.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MoreCard(
                title: 'Cashbook',
                imagePath: 'assets/icons/img.png',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Passbook()),
                  );
                },
              ),
              MoreCard(
                title: 'Settings',
                imagePath: 'assets/icons/img_1.png',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsPage()),
                  );
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MoreCard(
                title: 'Staff',
                imagePath: 'assets/icons/img_2.png',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StaffPage()),
                  );
                },
              ),
              MoreCard(
                title: 'Inventory',
                imagePath: 'assets/icons/img_4.png',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Inventory()),
                  );
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
