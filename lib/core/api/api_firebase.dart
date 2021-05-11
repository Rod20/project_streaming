import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ApiFirebase {


  Future<User> signInWithGoogle() async {
    print('========================');
    // Trigger the authentication flow
    GoogleSignInAccount googleUser ;
    try {
      googleUser = await GoogleSignIn().signIn();
    } catch (e) {
      print('=========== $e ==');
    }

    // Obtain the auth details from the request
    GoogleSignInAuthentication googleAuth;
    try {
      googleAuth = await googleUser.authentication;
    } catch (e) {
      print('=========== $e ==');
    }
    // Create a new credential

    GoogleAuthCredential credential ;

    try {
      credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
    } catch (e) {
      print('=========== $e ==');
    }

    // Once signed in, return the UserCredential
    var firebaseUser = (await FirebaseAuth.instance.signInWithCredential(credential)).user;
    return firebaseUser;
  }
}