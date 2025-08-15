import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:khatabook/pages/registration.dart';

import '../auth/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();
  Future<void> login() async{
    try{
      final user = await _authService.signInWithEmailPassword(
        emailController.text.trim(),
      passwordController.text.trim()
      );
      if(user == null){
        throw Exception('Login failed. User is null');
      }
    }
    catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed $e"))
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(26.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Let's Start",
            style: TextStyle(
              fontSize: 33,
              fontWeight: FontWeight.bold
            ),),
            SizedBox(height : 20),
            TextField(controller: emailController,
              decoration:  InputDecoration(
                hintText: "Enter your email",
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)

                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green, width: 2.0),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.5),
                  borderRadius: BorderRadius.circular(12.0),
                ),
              )
              ,),
            SizedBox(height: 12,),
            TextField(
              controller: passwordController,
                decoration:  InputDecoration(
                  hintText: "Enter your Password",
                  prefixIcon: Icon(Icons.key),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 2.0),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.5),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                )
            ),
            const SizedBox(height: 16,),
            ElevatedButton(onPressed: login,
              child: Text("Login",
              style: TextStyle(color: Colors.white,
                fontWeight: FontWeight.bold
              ),),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.lightGreen)
              )
        ),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const Registration()));
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                Text("Don't have an account? ",
                style: TextStyle(
                  color: Colors.black
                ),),
                Text("Register",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black
                ),)
              ],),

            )
        ]
      ),
    )
    );
  }
}
