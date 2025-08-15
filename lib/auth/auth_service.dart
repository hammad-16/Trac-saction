

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService{
final FirebaseAuth _auth = FirebaseAuth.instance;

Stream<User?> get user => _auth.authStateChanges();

Future<UserCredential> signInWithGoogle() async{
  final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
  final GoogleSignInAuthentication gAuth = await gUser!.authentication;

  final credential = GoogleAuthProvider.credential(
    accessToken: gAuth.accessToken,
    idToken: gAuth.idToken
  );

  return await _auth.signInWithCredential(credential);
}
//For signing out
Future<void> signOut() async{
  await _auth.signOut();
}
//For signing in

Future<User?> signInWithEmailPassword(String email, String password) async{
  final check = await _auth.signInWithEmailAndPassword(email: email, password: password);
  return check.user;
}

//For signing up

Future<User?> registerWithEmailPassword(String email, String password) async{

  final check = await _auth.createUserWithEmailAndPassword(email: email, password: password);
  return check.user;
}

}