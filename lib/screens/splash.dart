import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:selaa_delivery/backend_functions/links.dart';
import 'package:selaa_delivery/screens/register/pre_auth.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

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
      Navigator.push(context, MaterialPageRoute(builder: (context) => const PreAuth()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image(
          image: AssetImage(ImagePaths().verticalLogo),
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
  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}