import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:khatabook/auth/auth_service.dart';
import 'package:khatabook/pages/login_screen.dart';
import 'package:khatabook/widgets/loader.dart';

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthService auth = AuthService();
  bool _isLoading = false;

  Future <void> register() async{
    if(_formKey.currentState!.validate()){
      setState(() {
        _isLoading = true;
      });
      try{
        await auth.registerWithEmailPassword(
        emailController.text.trim(),
        passwordController.text.trim()
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!'))
        );
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
      } on FirebaseAuthException catch(e){
        String message;
        if(e.code == 'email-already-in-use'){
          message = 'The email address is already in use';
        }
        else if (e.code == 'weak-password') {
          message = 'The password is too weak.';
        } else {
          message = e.message ?? 'An unknown error occurred.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
      catch(e){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Oops! An unexpected error occured'))
        );
        print('error: $e');
      }
      finally{
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double logoHeight = size.height * 0.28;
    final double fieldSpacing = size.height * 0.025;
    final double horizontalPadding = size.width * 0.08;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Welcome to Trac-saction",
                style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold
                ),),
              SizedBox(height: size.height * 0.05),

              // App Logo
              Image.asset(
                'assets/icons/tracsaction_logo.png',
                height: logoHeight,
              ),
              SizedBox(height: fieldSpacing * 1.5),

              // Name Field
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: "Enter your name",
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) =>
                value!.isEmpty ? "Please enter your name" : null,
              ),
              SizedBox(height: fieldSpacing),

              // Email Field
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: "Enter your email",
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if(value ==  null || value.isEmpty) {
                    return "Please enter your email";
                  }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return "Please enter a valid email address";
                }
                return null;

                }
              ),
              SizedBox(height: fieldSpacing),

              // Password Field
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Enter your password",
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) =>
                value!.length < 6 ? "Password must be at least 6 characters" : null,
              ),
              SizedBox(height: fieldSpacing * 1.5),

              // Register Button
              SizedBox(
                width: double.infinity,
                height: size.height * 0.065,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    _isLoading ? null : register();
                  },
                  child: _isLoading ?
                  const Loader():
                  Text(
                    "Register",
                    style: TextStyle(
                      fontSize: size.width * 0.045,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.03),
            ],
          ),
        ),
      ),
    );
  }
}
