import 'package:flutter/material.dart';
import 'package:khatabook/pages/auth_gate.dart';
import 'package:khatabook/pages/login_screen.dart';
import 'package:khatabook/pages/more_page.dart';
import 'package:khatabook/pages/parties_pages.dart';
import 'package:khatabook/providers/khata_provider.dart';
import 'package:khatabook/services/connectivity_service.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final connectivityService = ConnectivityService();
  connectivityService.startListening();
  runApp(
    MultiProvider(
        providers:[
          ChangeNotifierProvider(create: (_) => KhataBookProvider())
        ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tracsaction',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.indigo,
          scaffoldBackgroundColor: Colors.white
      ),
      home: const AuthGate(),
    );
  }
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
 final  provider = Provider.of<KhataBookProvider>(context);
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

              children: [
                const Icon(Icons.book_outlined, color: Colors.white,),
                 Text(provider.name,
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


