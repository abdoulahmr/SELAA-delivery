// ignore_for_file: use_build_context_synchronously
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:selaa_delivery/backend_functions/links.dart';
import 'package:selaa_delivery/backend_functions/load_data.dart';
import 'package:selaa_delivery/screens/register/pre_auth.dart';
import 'package:selaa_delivery/screens/user/home.dart';


class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // No internet connection
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('No Internet'),
            content: const Text('Please check your internet connection and try again.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      await Future.delayed(const Duration(milliseconds: 200));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AfterSplash()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image(
          image: AssetImage(ImagePaths().whiteVerticalLogo),
          width: 150,
          height: 150,  
        ),
      ),
    );
  }
}

class AfterSplash extends StatefulWidget {
  const AfterSplash({super.key});

  @override
  State<AfterSplash> createState() => _AfterSplashState();
}

class _AfterSplashState extends State<AfterSplash> {
  User? user = FirebaseAuth.instance.currentUser;
  String userType = "";

  @override
  void initState() {
    super.initState();
    getUserType().then((String value) {
      setState(() {
        userType = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return userType == "delivery"
      ? const HomePage()
      : const PreAuth();
  }
}
