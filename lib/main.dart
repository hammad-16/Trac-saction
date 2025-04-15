import 'package:flutter/material.dart';
import 'package:khatabook/pages/more_page.dart';
import 'package:khatabook/pages/parties_pages.dart';
import 'package:khatabook/providers/khata_provider.dart';
import 'package:khatabook/services/business_name.dart';
import 'package:provider/provider.dart';
void main() {
  runApp(
    MultiProvider(
        providers:[
          ChangeNotifierProvider(create: (_) => KhataBookProvider())
        ],
      child: const KhataBook(),
    ),
  );
}

class KhataBook extends StatefulWidget {
  const KhataBook({super.key});

  @override
  State<KhataBook> createState() => _KhataBookState();
}

class _KhataBookState extends State<KhataBook> {
   int _curIndex = 0;

   final List<Widget> _pages =[
     PartiesPages(),
     MorePage(),
   ];

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'KhataBook',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.white
      ),

      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF0D47A1),
          title: GestureDetector(
            child: Row(
              spacing: 5,
              children: [
                const Icon(Icons.book_outlined, color: Colors.white,),
                 Text(BusinessName.name,
                style: TextStyle(
                    fontSize: 18,
                  color: Colors.white
                ),),
                const Icon(Icons.edit,
                color: Colors.white,)
              ],
            ),
            onTap: (){

            },
          ),
        ),
        body: IndexedStack(
          index: _curIndex,
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: _curIndex,
          onTap: (index) => setState(
              () => _curIndex = index
          ) ,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.indigo[800],
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Parties'),
            BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'More')
          ],
        ),
      ),
    );
  }
}


