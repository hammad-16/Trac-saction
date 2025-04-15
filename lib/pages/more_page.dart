import 'package:flutter/material.dart';
import 'package:khatabook/pages/passbook.dart';
import 'package:khatabook/pages/settings_page.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            spacing: 60,
            children: [
              InkWell(
                onTap: (){
      Navigator.push(context, MaterialPageRoute(
        builder: (context) => Passbook(),
      )
      );
                },
                child: Card(
                  color: Colors.white,
                  elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)
                ),
                  child: Padding(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue.shade50,
                        radius: 58,
                        child: ClipOval(
                          child: Image.asset('assets/icons/img.png',
                          height: 120,
                          width: 120,),
                        ),

                      ),
                      SizedBox(height: 12,),
                      Text(
                        'Cashbook',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ],
                  ),
                  ),
                  ),
              ),
              InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => SettingsPage(),
                  )
                  );
                },
                child: Card(
                  color: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)
                  ),
                  child: Padding(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 58,
                          child: ClipOval(
                            child: Image.asset('assets/icons/img_1.png',
                              height: 120,
                              width: 120,),
                          ),

                        ),
                        SizedBox(height: 12,),
                        Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
