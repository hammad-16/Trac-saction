import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:khatabook/main.dart';
import 'package:khatabook/pages/login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          else
            if(snapshot.hasData){
              return const KhataBook();

            }
            else
              {
                return const LoginScreen();
              }
        }

    );
  }
}
