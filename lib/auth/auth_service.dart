

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../data/database/firestore_helper.dart';

class AuthService{
final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseHelper _firebaseHelper = FirebaseHelper();
Stream<User?> get user => _auth.authStateChanges();

// Future<UserCredential> signInWithGoogle() async{
//   final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
//   final GoogleSignInAuthentication gAuth = await gUser!.authentication;
//
//   final credential = GoogleAuthProvider.credential(
//     accessToken: gAuth.accessToken,
//     idToken: gAuth.idToken
//   );
//
//   return await _auth.signInWithCredential(credential);
// }


//For signing out
Future<void> signOut() async{
  await _auth.signOut();
}



//For signing in

Future<User?> signInWithEmailPassword(String email, String password) async{
  try{
    final userCred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    await _firebaseHelper.syncFromFirestore();
    _firebaseHelper.startContactListener();
    _firebaseHelper.startTransactionListener();
    _firebaseHelper.startItemListener();
    _firebaseHelper.startInventoryTransactionListener();

    return userCred.user;
  }
  on FirebaseAuthException
  catch(e){
    throw Exception(e.code);
  }

}

//For signing up

Future<User?> registerWithEmailPassword(String email, String password) async{
  try {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Perform initial data sync and start listeners for the new, empty account
    await _firebaseHelper.syncFromFirestore();
    _firebaseHelper.startContactListener();
    _firebaseHelper.startTransactionListener();
    _firebaseHelper.startItemListener();
    _firebaseHelper.startInventoryTransactionListener();

    return userCredential.user;
  } on FirebaseAuthException catch (e) {
    throw Exception(e.code);
  }
}

}