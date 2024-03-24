import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:selaa_delivery/screens/register/login.dart';
import 'package:selaa_delivery/screens/user/home.dart';

Future<User?> registerWithEmailPassword({
  required String email,
  required String password,
  required String firstname,
  required String lastname,
  required String phoneNumber,
  required String dLNumber,
  required BuildContext context,
}) async {
  // Show loading alert while registering
  QuickAlert.show(
    context: context,
    type: QuickAlertType.loading,
    title: 'Loading',
    text: 'Please wait...',
  );
  try {
    // Create user with email and password
    UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    User? user = userCredential.user;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'firstname': firstname,
        'lastname': lastname,
        'email': email,
        'phoneNumber': phoneNumber,
        'driverLicenceNumber': dLNumber,
        'accountType': "delivery",
        'balance': 0,
        'check': true
      });
      // Dismiss loading alert
      Navigator.pop(context);
      // Show success alert
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: 'Success',
        text: 'Account created successfully!',
      );
      // Send email verification
      await user.sendEmailVerification();
      // Navigate to login screen
      Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
      return user;
    }
  } on FirebaseAuthException catch (e) {
    // Handle FirebaseAuth exceptions
    if (e.code == 'weak-password') {
      Fluttertoast.showToast(
        msg: "Password should be at least 8 characters. code 1-1-1",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.yellow,
        textColor: Colors.black,
        fontSize: 16.0,
      );
    } else if (e.code == 'email-already-in-use') {
      Fluttertoast.showToast(
        msg: "The account already exists for that email. code 1-1-2",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.yellow,
        textColor: Colors.black,
        fontSize: 16.0,
      );
    }
  } catch (e) {
    // Handle other exceptions
    Fluttertoast.showToast(
      msg: "Error creating account please send us a feedback code 1-1-3",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
  // Dismiss loading alert if registration failed
  Navigator.pop(context);
  return null;
}

// Function to log in with email and password
Future<User?> loginWithEmailPassword(
  String email,
  String password,
  context,
) async {
  try {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      title: 'Loading',
      text: 'Please wait...',
    );
    // Sign in with email and password
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    User? user = userCredential.user;
    if (user != null && !user.emailVerified) {
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: "Please confirm your email address! code 1-2-1",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.yellow,
        textColor: Colors.black,
        fontSize: 16.0,
      );
    } else {
      // Navigate to home screen after successful login
      Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage()));
    }
  } on FirebaseAuthException catch (e) {
    // Handle FirebaseAuth exceptions
    if (e.code == 'user-not-found') {
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: "No user found for $email. code 1-2-2",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else if (e.code == 'wrong-password') {
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: "Wrong password provided for that user. code 1-2-3",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );    
    } else {
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: "Error logging in please send us a feedback code 1-2-4",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  } catch (e) {
    Navigator.pop(context);
    Fluttertoast.showToast(
        msg: "Error logging in please send us a feedback code 1-2-5",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
  }
  return null;
}

// Function to sign out
Future<void> signOut(context) async {
  try {
    // Sign out user
    await FirebaseAuth.instance.signOut();
    // Navigate to login screen after sign out
    Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
  } catch (e) {
    // Handle errors
    Fluttertoast.showToast(
      msg: "Error logging in please send us a feedback code 1-4-1",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}

// Function to sign up with Google account
Future<User?> signInWithGoogle(BuildContext context, String accountType, ScaffoldMessengerState scaffoldMessenger) async {
  try {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut(); // Sign out the current account
    final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;
      if (user != null) {
        // Check if the user's email already exists in Firestore
        final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: user.email)
            .get();
        if (querySnapshot.docs.isEmpty) {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'firstname': user.displayName?.split(' ')[0] ?? '',
            'lastname': user.displayName?.split(' ')[1] ?? '',
            'email': user.email,
            'phoneNumber': '',
            'shippingAdress': '',
            'accountType': "delivery",
            'balance': 0,
            'check': false
          });
          // Navigate to user info screen to complete registration
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => const HomePage()));
          return null;
        }
        // Email exists, proceed with sign-in
        // Navigate to home screen after successful login
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    }
  } catch (e) {
    Fluttertoast.showToast(
        msg: "Error logging in please send us a feedback code 1-5-1",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
  }
  return null;
}
