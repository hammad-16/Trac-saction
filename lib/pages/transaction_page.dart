import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/models/contact.dart';

class TransactionPage extends StatefulWidget {
  final Contact contact;


  const TransactionPage({super.key, required this.contact});




  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {



  @override
  Widget build(BuildContext context) {

    String initials = '';
    if (widget.contact.name.isNotEmpty) {
      final nameParts = widget.contact.name.split(' ');
      if (nameParts.length > 1) {
        initials = '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
      } else {
        initials = widget.contact.name[0].toUpperCase();
      }
    }
    void makePhoneCall(String? phoneNumber) async {
      final Uri url = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw 'Could not launch $url';
      }
    }


    return Scaffold(
     appBar: AppBar(
       foregroundColor: Colors.white,
        backgroundColor:  Color(0xFF0D47A1),
       title: Row(
         children: [
           CircleAvatar(
             backgroundColor: Colors.white,
             radius: 16,
             child: Text(initials,
             style: const TextStyle(
               color: Colors.black,
               fontWeight: FontWeight.bold,
               fontSize: 14
             ),),
           ),
           const SizedBox(width: 12,),
           Expanded(
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text(widget.contact.name,
                   style: TextStyle(
                     color: Colors.white,
                     fontSize: 16,
                     fontWeight: FontWeight.bold,
                   ),
                   ),
                   const Text('View settings',
                   style: TextStyle(color: Colors.white,
                   fontSize: 14),)
                 ],
               )),
           
           InkWell(
             onTap: (){
               makePhoneCall(widget.contact.phone);
             },
               child: Icon(Icons.phone)
           )
           
         ],
       ),
     ),

    );
  }
}
